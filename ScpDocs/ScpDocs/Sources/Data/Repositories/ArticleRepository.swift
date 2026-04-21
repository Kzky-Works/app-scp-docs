import Foundation
import Observation

// MARK: - Portability boundary (Android 等へ移植する際の契約)

@MainActor
protocol ArticleRepositoryProtocol: AnyObject {
    func ratingScore(for url: URL) -> Double
    func setRatingScore(_ value: Double, for url: URL)
    /// 互換: `UserArticleData` の `isRead`（`ratingScore > 0`）と同値。
    func isRead(url: URL) -> Bool
    func recordHistory(url: URL)
    @discardableResult
    func toggleBookmark(url: URL) -> Bool
    func isBookmarked(url: URL) -> Bool
    func isOfflineReady(url: URL) -> Bool
    func allBookmarks() -> [URL]
    func allHistory() -> [URL]
    func clearAllHistory()
    func clearAllBookmarks()
}

/// `UserDefaults` ベースのレーティング・閲覧履歴。既読相当は `ratingScore > 0`。
@Observable
@MainActor
final class ArticleRepository: ArticleRepositoryProtocol {
    private enum StorageKey {
        static let readURLs = "article.read_urls"
        static let historyURLs = "article.history_urls"
        static let bookmarkURLs = "article.bookmark_urls"
        static let ratingByURL = "article.rating_by_url"
        static let didMigrateToRatingV1 = "article.migrate_rating_v1"
    }

    private let defaults: UserDefaults
    private let maxHistoryEntries: Int
    private let offlineStore: OfflineStore

    private(set) var historyURLKeys: [String]
    private(set) var bookmarkURLKeys: Set<String>
    /// 正規化 URL キー → 0.0...5.0
    private(set) var ratingByURLKey: [String: Double]

    init(defaults: UserDefaults = .standard, maxHistoryEntries: Int = 200, offlineStore: OfflineStore = .shared) {
        self.defaults = defaults
        self.maxHistoryEntries = max(1, maxHistoryEntries)
        self.offlineStore = offlineStore

        if let history = defaults.array(forKey: StorageKey.historyURLs) as? [String] {
            self.historyURLKeys = history
        } else {
            self.historyURLKeys = []
        }
        if let marks = defaults.array(forKey: StorageKey.bookmarkURLs) as? [String] {
            self.bookmarkURLKeys = Set(marks)
        } else {
            self.bookmarkURLKeys = []
        }

        self.ratingByURLKey = Self.loadRatingDictionary(from: defaults)

        Self.migrateLegacyBinaryFlagsIntoRatingsIfNeeded(
            defaults: defaults,
            ratingByURLKey: &ratingByURLKey
        )
    }

    func ratingScore(for url: URL) -> Double {
        let key = Self.storageKey(for: url)
        return ratingByURLKey[key] ?? UserArticleData.unrated
    }

    func setRatingScore(_ value: Double, for url: URL) {
        let key = Self.storageKey(for: url)
        let clamped = UserArticleData.clampedRating(value)
        var next = ratingByURLKey
        if clamped <= UserArticleData.unrated {
            next.removeValue(forKey: key)
        } else {
            next[key] = clamped
        }
        ratingByURLKey = next
        persistRatings()
    }

    func isRead(url: URL) -> Bool {
        ratingScore(for: url) > UserArticleData.unrated
    }

    func recordHistory(url: URL) {
        let key = Self.storageKey(for: url)
        var next = historyURLKeys
        next.removeAll { $0 == key }
        next.insert(key, at: 0)
        if next.count > maxHistoryEntries {
            next = Array(next.prefix(maxHistoryEntries))
        }
        historyURLKeys = next
        defaults.set(historyURLKeys, forKey: StorageKey.historyURLs)
    }

    func recentHistoryURLs(maxCount: Int) -> [URL] {
        let limit = max(0, maxCount)
        return historyURLKeys.prefix(limit).compactMap { URL(string: $0) }
    }

    /// トグル後にお気に入りに含まれる場合は `true`（新規追加直後にスナップショット取得へ使う）。
    @discardableResult
    func toggleBookmark(url: URL) -> Bool {
        let key = Self.storageKey(for: url)
        var next = bookmarkURLKeys
        let wasBookmarked = next.contains(key)
        if wasBookmarked {
            next.remove(key)
            offlineStore.deleteHTML(for: url)
        } else {
            next.insert(key)
        }
        bookmarkURLKeys = next
        persistBookmarks()
        return !wasBookmarked
    }

    func isBookmarked(url: URL) -> Bool {
        bookmarkURLKeys.contains(Self.storageKey(for: url))
    }

    func isOfflineReady(url: URL) -> Bool {
        offlineStore.loadHTML(for: url) != nil
    }

    func allBookmarks() -> [URL] {
        bookmarkURLKeys.sorted().compactMap { URL(string: $0) }
    }

    func allHistory() -> [URL] {
        historyURLKeys.compactMap { URL(string: $0) }
    }

    func clearAllHistory() {
        historyURLKeys = []
        defaults.set([], forKey: StorageKey.historyURLs)
    }

    func clearAllBookmarks() {
        bookmarkURLKeys = []
        persistBookmarks()
        offlineStore.deleteAllSnapshots()
    }

    private func persistRatings() {
        defaults.set(ratingByURLKey, forKey: StorageKey.ratingByURL)
    }

    private func persistBookmarks() {
        defaults.set(Array(bookmarkURLKeys).sorted(), forKey: StorageKey.bookmarkURLs)
    }

    private static func loadRatingDictionary(from defaults: UserDefaults) -> [String: Double] {
        if let dict = defaults.dictionary(forKey: StorageKey.ratingByURL) as? [String: Double] {
            return dict
        }
        if let dict = defaults.dictionary(forKey: StorageKey.ratingByURL) as? [String: NSNumber] {
            var out: [String: Double] = [:]
            for (k, v) in dict {
                out[k] = v.doubleValue
            }
            return out
        }
        return [:]
    }

    /// `isRead` / `isFavorite`（ブックマーク）から `ratingScore` への一回限りの移行。
    private static func migrateLegacyBinaryFlagsIntoRatingsIfNeeded(
        defaults: UserDefaults,
        ratingByURLKey: inout [String: Double]
    ) {
        guard !defaults.bool(forKey: StorageKey.didMigrateToRatingV1) else { return }

        let readKeys: Set<String> = if let saved = defaults.array(forKey: StorageKey.readURLs) as? [String] {
            Set(saved)
        } else {
            []
        }

        let bookmarkKeys: Set<String> = if let marks = defaults.array(forKey: StorageKey.bookmarkURLs) as? [String] {
            Set(marks)
        } else {
            []
        }

        var merged = ratingByURLKey

        for key in bookmarkKeys {
            merged[key] = 5.0
        }
        for key in readKeys where merged[key] == nil {
            merged[key] = 3.0
        }

        ratingByURLKey = merged
        defaults.set(merged, forKey: StorageKey.ratingByURL)
        defaults.set(true, forKey: StorageKey.didMigrateToRatingV1)
    }

    /// フラグメントを除き、同一ページ判定がぶれないよう正規化したキー。
    nonisolated static func storageKey(for url: URL) -> String {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return url.absoluteString
        }
        components.fragment = nil
        if components.path.isEmpty {
            components.path = "/"
        }
        components.host = components.host?.lowercased()
        return components.string ?? url.absoluteString
    }
}
