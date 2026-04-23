import Foundation
import Observation

/// ホーム用: 3 系統キャッシュから件数・未読推計を公開する。
@Observable
@MainActor
final class SCPArticleTrifoldIndexStore {
    private let feedCache: SCPArticleFeedCacheRepository
    private(set) var jpTotalCount: Int = 0
    private(set) var enTotalCount: Int = 0
    private(set) var intTotalCount: Int = 0

    init(feedCache: SCPArticleFeedCacheRepository) {
        self.feedCache = feedCache
        reloadFromCache()
    }

    func reloadFromCache() {
        jpTotalCount = feedCache.loadPersistedPayload(kind: .jp)?.entries.count ?? 0
        enTotalCount = feedCache.loadPersistedPayload(kind: .en)?.entries.count ?? 0
        intTotalCount = feedCache.loadPersistedPayload(kind: .int)?.entries.count ?? 0
    }

    func catalogEntries(for kind: SCPArticleFeedKind) -> [SCPArticle] {
        feedCache.loadPersistedPayload(kind: kind)?.entries ?? []
    }

    func unreadCount(kind: SCPArticleFeedKind, articleRepository: ArticleRepository) -> Int {
        guard let entries = feedCache.loadPersistedPayload(kind: kind)?.entries else { return 0 }
        var n = 0
        for article in entries {
            guard let url = article.resolvedURL else { continue }
            if !articleRepository.isRead(url: url) {
                n += 1
            }
        }
        return n
    }
}
