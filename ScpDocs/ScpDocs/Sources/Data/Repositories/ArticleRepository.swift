import Foundation
import Observation

// MARK: - データ供給（Step 1）
// ユーザー状態（履歴・レーティング等）はこのファイルの `ArticleRepository` が担当。
// 3 系統の記事 JSON 取得は `SCPArticleCatalogRepository`（`fetchJP` / `fetchEN` / `fetchINT`）と
// `SCPArticleTrifoldSyncService` を参照。`SCPArticle` の URL キーは `Self.storageKey(for:)` と一致させる。
//
// MARK: - Step 4（マルチフォーム）
// マルチフォーム `manifest_*.json` の取得・キャッシュは
// `SCPGeneralContentCatalogRepository` と `MultiformContentSyncService`、および
// `SCPArticleFeedCacheRepository` のマルチフォーム用ストレージが担当（本クラスは引き続きユーザー状態のみ）。

// MARK: - Portability boundary (Android 等へ移植する際の契約)

@MainActor
protocol ArticleRepositoryProtocol: AnyObject {
    func ratingScore(for url: URL) -> Double
    func setRatingScore(_ value: Double, for url: URL)
    /// 互換: `UserArticleData` の `isRead`（`ratingScore > 0`）と同値。
    func isRead(url: URL) -> Bool
    func recordHistory(url: URL)
    func isOfflineReady(url: URL) -> Bool
    /// 指定レーティング以上の URL を降順で返す（「高評価リスト」／旧お気に入り相当）。
    func urlsWithRating(atLeast threshold: Double) -> [URL]
    func allHistory() -> [URL]
    func clearAllHistory()
    func toggleReadLater(url: URL)
    func isReadLater(url: URL) -> Bool
    func allReadLater() -> [URL]
    /// `threshold`（既定 4.0）以上の評価を削除し、該当ページのオフライン HTML を削除する。
    func clearRatingsFromThresholdAndSnapshots(_ threshold: Double)
    func readingScrollDepth(for url: URL) -> Double
    func updateReadingScrollDepth(_ fraction: Double, for url: URL)
    func cachedPageTitle(for url: URL) -> String?
    func updateCachedPageTitle(_ title: String?, for url: URL)
    func cachedFirstImageURL(for url: URL) -> URL?
    func updateCachedFirstImageURL(_ imageURL: URL?, for url: URL)
}

/// `UserDefaults` ベースのレーティング・閲覧履歴。既読相当は `ratingScore > 0`。
/// 旧ブックマーク／お気に入りはレーティング ≥ 4.0 とオフライン保存へ統合した。
@Observable
@MainActor
final class ArticleRepository: ArticleRepositoryProtocol {
    private enum StorageKey {
        static let readURLs = "article.read_urls"
        static let historyURLs = "article.history_urls"
        static let readLaterURLs = "article.read_later_urls"
        static let bookmarkURLs = "article.bookmark_urls"
        static let ratingByURL = "article.rating_by_url"
        static let didMigrateToRatingV1 = "article.migrate_rating_v1"
        static let scrollDepthByURL = "article.scroll_depth_by_url"
        static let pageTitleByURL = "article.page_title_by_url"
        static let firstImageURLByURL = "article.first_image_url_by_url"
    }

    /// 書庫「高評価」とアーカイヴ「L≥4」フィルタと揃える境界。
    static let libraryHighRatedThreshold: Double = 4.0

    private let defaults: UserDefaults
    private let maxHistoryEntries: Int
    private let maxReadLaterEntries: Int
    private let offlineStore: OfflineStore

    private(set) var historyURLKeys: [String]
    /// 追加が新しい順の「後で読む」リスト。
    private(set) var readLaterURLKeys: [String]
    /// 正規化 URL キー → 0.0...5.0
    private(set) var ratingByURLKey: [String: Double]
    /// 記事 URL キー → 縦スクロール進捗 0...1（ホーム「続きから読む」用）。
    private(set) var scrollDepthByURLKey: [String: Double]
    private(set) var pageTitleByURLKey: [String: String]
    private(set) var firstImageURLStringByURLKey: [String: String]

    init(defaults: UserDefaults = .standard, maxHistoryEntries: Int = 200, offlineStore: OfflineStore = .shared) {
        self.defaults = defaults
        self.maxHistoryEntries = max(1, maxHistoryEntries)
        self.maxReadLaterEntries = max(1, maxHistoryEntries)
        self.offlineStore = offlineStore

        if let history = defaults.array(forKey: StorageKey.historyURLs) as? [String] {
            self.historyURLKeys = history
        } else {
            self.historyURLKeys = []
        }
        if let later = defaults.array(forKey: StorageKey.readLaterURLs) as? [String] {
            self.readLaterURLKeys = later
        } else {
            self.readLaterURLKeys = []
        }

        self.ratingByURLKey = Self.loadRatingDictionary(from: defaults)
        self.scrollDepthByURLKey = Self.loadStringKeyedDictionary(from: defaults, key: StorageKey.scrollDepthByURL)
        self.pageTitleByURLKey = Self.loadStringKeyedStringDictionary(from: defaults, key: StorageKey.pageTitleByURL)
        self.firstImageURLStringByURLKey = Self.loadStringKeyedStringDictionary(
            from: defaults,
            key: StorageKey.firstImageURLByURL
        )

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
        pruneReadingAuxiliaryCaches(toHistoryKeys: Set(next))
    }

    func recentHistoryURLs(maxCount: Int) -> [URL] {
        let limit = max(0, maxCount)
        return historyURLKeys.prefix(limit).compactMap { URL(string: $0) }
    }

    func isOfflineReady(url: URL) -> Bool {
        offlineStore.loadHTML(for: url) != nil
    }

    func urlsWithRating(atLeast threshold: Double) -> [URL] {
        let pairs = ratingByURLKey.filter { $0.value >= threshold }
        let sortedPairs = pairs.sorted { a, b in
            if a.value != b.value {
                return a.value > b.value
            }
            return a.key < b.key
        }
        return sortedPairs.compactMap { URL(string: $0.key) }
    }

    func allHistory() -> [URL] {
        historyURLKeys.compactMap { URL(string: $0) }
    }

    func clearAllHistory() {
        historyURLKeys = []
        defaults.set([], forKey: StorageKey.historyURLs)
        scrollDepthByURLKey = [:]
        pageTitleByURLKey = [:]
        firstImageURLStringByURLKey = [:]
        persistScrollDepths()
        persistPageTitles()
        persistFirstImageURLs()
    }

    func readingScrollDepth(for url: URL) -> Double {
        scrollDepthByURLKey[Self.storageKey(for: url)] ?? 0
    }

    func updateReadingScrollDepth(_ fraction: Double, for url: URL) {
        let key = Self.storageKey(for: url)
        let clamped = min(1, max(0, fraction))
        var next = scrollDepthByURLKey
        if clamped <= 0.000_001 {
            next.removeValue(forKey: key)
        } else {
            next[key] = clamped
        }
        scrollDepthByURLKey = next
        persistScrollDepths()
    }

    func cachedPageTitle(for url: URL) -> String? {
        pageTitleByURLKey[Self.storageKey(for: url)]
    }

    func updateCachedPageTitle(_ title: String?, for url: URL) {
        let key = Self.storageKey(for: url)
        var next = pageTitleByURLKey
        let trimmed = title?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if trimmed.isEmpty {
            next.removeValue(forKey: key)
        } else {
            next[key] = trimmed
        }
        pageTitleByURLKey = next
        persistPageTitles()
    }

    func cachedFirstImageURL(for url: URL) -> URL? {
        guard let s = firstImageURLStringByURLKey[Self.storageKey(for: url)] else { return nil }
        return URL(string: s)
    }

    func updateCachedFirstImageURL(_ imageURL: URL?, for url: URL) {
        let key = Self.storageKey(for: url)
        var next = firstImageURLStringByURLKey
        if let imageURL {
            next[key] = imageURL.absoluteString
        } else {
            next.removeValue(forKey: key)
        }
        firstImageURLStringByURLKey = next
        persistFirstImageURLs()
    }

    func toggleReadLater(url: URL) {
        let key = Self.storageKey(for: url)
        var next = readLaterURLKeys
        if let idx = next.firstIndex(of: key) {
            next.remove(at: idx)
        } else {
            next.removeAll { $0 == key }
            next.insert(key, at: 0)
            if next.count > maxReadLaterEntries {
                next = Array(next.prefix(maxReadLaterEntries))
            }
        }
        readLaterURLKeys = next
        defaults.set(readLaterURLKeys, forKey: StorageKey.readLaterURLs)
    }

    func isReadLater(url: URL) -> Bool {
        readLaterURLKeys.contains(Self.storageKey(for: url))
    }

    func allReadLater() -> [URL] {
        readLaterURLKeys.compactMap { URL(string: $0) }
    }

    func clearRatingsFromThresholdAndSnapshots(_ threshold: Double) {
        let keysToStrip = ratingByURLKey.filter { $0.value >= threshold }.map(\.key)
        var next = ratingByURLKey
        for key in keysToStrip {
            next.removeValue(forKey: key)
            if let url = URL(string: key) {
                offlineStore.deleteHTML(for: url)
            }
        }
        ratingByURLKey = next
        persistRatings()
    }

    private func persistRatings() {
        defaults.set(ratingByURLKey, forKey: StorageKey.ratingByURL)
    }

    private func persistScrollDepths() {
        defaults.set(scrollDepthByURLKey, forKey: StorageKey.scrollDepthByURL)
    }

    private func persistPageTitles() {
        defaults.set(pageTitleByURLKey, forKey: StorageKey.pageTitleByURL)
    }

    private func persistFirstImageURLs() {
        defaults.set(firstImageURLStringByURLKey, forKey: StorageKey.firstImageURLByURL)
    }

    private func pruneReadingAuxiliaryCaches(toHistoryKeys allowed: Set<String>) {
        var d = scrollDepthByURLKey
        for k in d.keys where !allowed.contains(k) {
            d.removeValue(forKey: k)
        }
        scrollDepthByURLKey = d

        var t = pageTitleByURLKey
        for k in t.keys where !allowed.contains(k) {
            t.removeValue(forKey: k)
        }
        pageTitleByURLKey = t

        var i = firstImageURLStringByURLKey
        for k in i.keys where !allowed.contains(k) {
            i.removeValue(forKey: k)
        }
        firstImageURLStringByURLKey = i

        persistScrollDepths()
        persistPageTitles()
        persistFirstImageURLs()
    }

    private static func loadStringKeyedDictionary(from defaults: UserDefaults, key: String) -> [String: Double] {
        if let dict = defaults.dictionary(forKey: key) as? [String: Double] {
            return dict
        }
        if let dict = defaults.dictionary(forKey: key) as? [String: NSNumber] {
            var out: [String: Double] = [:]
            for (k, v) in dict {
                out[k] = v.doubleValue
            }
            return out
        }
        return [:]
    }

    private static func loadStringKeyedStringDictionary(from defaults: UserDefaults, key: String) -> [String: String] {
        defaults.dictionary(forKey: key) as? [String: String] ?? [:]
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
        defaults.removeObject(forKey: StorageKey.bookmarkURLs)
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
