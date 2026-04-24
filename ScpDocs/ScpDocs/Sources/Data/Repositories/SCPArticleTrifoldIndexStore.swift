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
    }

    func reloadFromCache() {
        jpTotalCount = feedCache.loadPersistedPayload(kind: .jp)?.entries.count ?? 0
        enTotalCount = feedCache.loadPersistedPayload(kind: .en)?.entries.count ?? 0
        intTotalCount = catalogEntries(for: .int).count
    }

    func catalogEntries(for kind: SCPArticleFeedKind) -> [SCPArticle] {
        let entries = feedCache.loadPersistedPayload(kind: kind)?.entries ?? []
        if kind == .int {
            return entries.filter { !InternationalBranchPortalOption.SCPIntSlugLanguageTail.isEnglishBranchCatalogEntry($0) }
        }
        return entries
    }

    func unreadCount(kind: SCPArticleFeedKind, articleRepository: ArticleRepository) -> Int {
        let entries = catalogEntries(for: kind)
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
