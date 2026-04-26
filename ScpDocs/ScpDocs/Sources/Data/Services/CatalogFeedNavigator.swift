import Foundation

/// キャッシュ済み 3 系統フィード（JP / EN / INT）内の「次の記事」「ランダム記事」を解決する。
enum CatalogFeedNavigator: Sendable {
    private static func trifoldCatalogEntries(kind: SCPArticleFeedKind, feedCache: SCPArticleFeedCacheRepository) -> [SCPArticle] {
        let entries = feedCache.loadPersistedPayload(kind: kind)?.entries ?? []
        if kind == .int {
            return entries.filter { !InternationalBranchPortalOption.SCPIntSlugLanguageTail.isEnglishBranchCatalogEntry($0) }
        }
        return entries
    }

    /// `PersonnelReadingJournal` が保持する明示コンテキストがあれば優先し、なければ URL から推定する。
    static func effectiveKind(active: SCPArticleFeedKind?, for url: URL) -> SCPArticleFeedKind? {
        if let active { return active }
        return inferCatalogFeed(for: url)
    }

    /// 閲覧中 URL からカタログ系統を推定（ホーム等からの遷移で `active` が無い場合）。
    static func inferCatalogFeed(for url: URL) -> SCPArticleFeedKind? {
        let host = url.host?.lowercased() ?? ""
        if host.contains("scp-int") { return .int }
        if host.contains("scp-wiki") { return .en }
        if host.contains("scp-jp") {
            let slug = url.lastPathComponent.lowercased()
            if slug.hasPrefix("scp-"), slug.contains("-jp") { return .jp }
            return .en
        }
        return nil
    }

    static func nextArticleURL(
        after current: URL,
        kind: SCPArticleFeedKind,
        feedCache: SCPArticleFeedCacheRepository
    ) -> URL? {
        let entries = trifoldCatalogEntries(kind: kind, feedCache: feedCache)
        let key = ArticleRepository.storageKey(for: current)
        guard let idx = entries.firstIndex(where: { SCPArticleCatalogRepository.normalizedURLKey(for: $0) == key }) else {
            return entries.first?.resolvedURL
        }
        let nextIdx = entries.index(after: idx)
        guard nextIdx < entries.endIndex else { return nil }
        return entries[nextIdx].resolvedURL
    }

    @MainActor
    static func randomArticleURL(
        excluding current: URL?,
        kind: SCPArticleFeedKind,
        feedCache: SCPArticleFeedCacheRepository,
        articleRepository: ArticleRepository
    ) -> URL? {
        let entries = trifoldCatalogEntries(kind: kind, feedCache: feedCache)
        let currentKey = current.map { ArticleRepository.storageKey(for: $0) }
        let unread = entries.filter { article in
            guard let u = article.resolvedURL else { return false }
            if currentKey == ArticleRepository.storageKey(for: u) { return false }
            return !articleRepository.isRead(url: u)
        }
        if let pick = unread.randomElement(), let u = pick.resolvedURL { return u }
        let pool = entries.compactMap(\.resolvedURL).filter { currentKey != ArticleRepository.storageKey(for: $0) }
        return pool.randomElement()
    }

    /// Step 4: マルチフォーム一覧からのランダム遷移（未読優先）。
    @MainActor
    static func randomGeneralContentURL(
        excluding current: URL?,
        kind: SCPArticleFeedKind,
        feedCache: SCPArticleFeedCacheRepository,
        articleRepository: ArticleRepository
    ) -> URL? {
        guard kind.isMultiformArchiveFeed else { return nil }
        let payload = feedCache.loadPersistedGeneralMultiformPayload(kind: kind)
        let entries = payload?.entries ?? []
        var orderedURLs: [URL] = entries.compactMap(\.resolvedURL)
        if kind == .gois, let gr = payload?.goiRegions {
            for g in gr.en + gr.jp + gr.other {
                let raw = g.u.trimmingCharacters(in: .whitespacesAndNewlines)
                if let u = URL(string: raw) { orderedURLs.append(u) }
            }
        }
        var seen = Set<String>()
        var uniqueURLs: [URL] = []
        for u in orderedURLs {
            let k = ArticleRepository.storageKey(for: u)
            if seen.insert(k).inserted { uniqueURLs.append(u) }
        }
        let currentKey = current.map { ArticleRepository.storageKey(for: $0) }
        let unread = uniqueURLs.filter { u in
            if currentKey == ArticleRepository.storageKey(for: u) { return false }
            return !articleRepository.isRead(url: u)
        }
        if let u = unread.randomElement() { return u }
        let pool = uniqueURLs.filter { currentKey != ArticleRepository.storageKey(for: $0) }
        return pool.randomElement()
    }
}
