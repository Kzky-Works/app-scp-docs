import Foundation
import Observation

// MARK: - Portability boundary (Android 等へ移植する際の契約)

@MainActor
protocol ArticleRepositoryProtocol: AnyObject {
    func markAsRead(url: URL)
    func isRead(url: URL) -> Bool
    func recordHistory(url: URL)
    func recentHistoryURLs(maxCount: Int) -> [URL]
    func toggleBookmark(url: URL)
    func isBookmarked(url: URL) -> Bool
    func allBookmarks() -> [URL]
    func allHistory() -> [URL]
    func clearAllHistory()
    func clearAllBookmarks()
}

/// `UserDefaults` ベースの既読・閲覧履歴。UI は必要に応じて `ArticleRepositoryProtocol` へ差し替え可能。
@Observable
@MainActor
final class ArticleRepository: ArticleRepositoryProtocol {
    private enum StorageKey {
        static let readURLs = "article.read_urls"
        static let historyURLs = "article.history_urls"
        static let bookmarkURLs = "article.bookmark_urls"
    }

    private let defaults: UserDefaults
    private let maxHistoryEntries: Int

    private(set) var readURLKeys: Set<String>
    private(set) var historyURLKeys: [String]
    private(set) var bookmarkURLKeys: Set<String>

    init(defaults: UserDefaults = .standard, maxHistoryEntries: Int = 200) {
        self.defaults = defaults
        self.maxHistoryEntries = max(1, maxHistoryEntries)
        if let saved = defaults.array(forKey: StorageKey.readURLs) as? [String] {
            self.readURLKeys = Set(saved)
        } else {
            self.readURLKeys = []
        }
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
    }

    func markAsRead(url: URL) {
        let key = Self.storageKey(for: url)
        guard !readURLKeys.contains(key) else { return }
        var next = readURLKeys
        next.insert(key)
        readURLKeys = next
        persistReadSet()
    }

    func isRead(url: URL) -> Bool {
        readURLKeys.contains(Self.storageKey(for: url))
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

    func toggleBookmark(url: URL) {
        let key = Self.storageKey(for: url)
        var next = bookmarkURLKeys
        if next.contains(key) {
            next.remove(key)
        } else {
            next.insert(key)
        }
        bookmarkURLKeys = next
        persistBookmarks()
    }

    func isBookmarked(url: URL) -> Bool {
        bookmarkURLKeys.contains(Self.storageKey(for: url))
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
    }

    private func persistReadSet() {
        defaults.set(Array(readURLKeys).sorted(), forKey: StorageKey.readURLs)
    }

    private func persistBookmarks() {
        defaults.set(Array(bookmarkURLKeys).sorted(), forKey: StorageKey.bookmarkURLs)
    }

    /// フラグメントを除き、同一ページ判定がぶれないよう正規化したキー。
    static func storageKey(for url: URL) -> String {
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
