import Foundation

/// 7 系統キャッシュ＋マニフェスト由来の索引行をまとめて検索（CPU 集約は呼び出し側でバックグラウンド推奨）。
enum GlobalCatalogSearchEngine: Sendable {
    nonisolated static func search(query: String, snapshot: CatalogSearchSnapshot, maxTotal: Int = 220) -> [CatalogSearchHitDraft] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return [] }
        let needle = q.lowercased()

        var seenURLKeys = Set<String>()
        var drafts: [CatalogSearchHitDraft] = []
        drafts.reserveCapacity(min(maxTotal, 64))

        func register(url: URL) -> Bool {
            let key = ArticleRepository.storageKey(for: url)
            return seenURLKeys.insert(key).inserted
        }

        for row in snapshot.indexedListRows.prefix(80) {
            guard drafts.count < maxTotal else { break }
            guard let url = URL(string: row.urlString) else { continue }
            guard register(url: url) else { continue }
            let title = Self.formattedScpTitle(scpNumber: row.scpNumber)
            let sub = Self.indexedSubtitle(articleTitle: row.articleTitle, objectClass: row.objectClass, tags: row.tags)
            drafts.append(
                CatalogSearchHitDraft(
                    url: url,
                    badge: .scpJpIndexedList,
                    title: title,
                    subtitle: sub,
                    tags: row.tags
                )
            )
        }

        for row in snapshot.scpRows {
            guard drafts.count < maxTotal else { break }
            guard rowMatchesSCP(row: row, needle: needle) else { continue }
            guard let url = URL(string: row.urlString.trimmingCharacters(in: .whitespacesAndNewlines)) else { continue }
            guard register(url: url) else { continue }
            let sub = [row.id, row.tags.joined(separator: " · ")]
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .joined(separator: " · ")
            drafts.append(
                CatalogSearchHitDraft(url: url, badge: row.badge, title: row.title, subtitle: sub, tags: row.tags)
            )
        }

        for row in snapshot.genRows {
            guard drafts.count < maxTotal else { break }
            guard rowMatchesGen(row: row, needle: needle) else { continue }
            guard let url = URL(string: row.urlString.trimmingCharacters(in: .whitespacesAndNewlines)) else { continue }
            guard register(url: url) else { continue }
            let author = row.author?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let sub = author.isEmpty ? row.urlString : author
            drafts.append(
                CatalogSearchHitDraft(url: url, badge: row.badge, title: row.title, subtitle: sub, tags: [])
            )
        }

        return drafts
    }

    nonisolated private static func rowMatchesSCP(row: CatalogSearchSnapshot.SCPRow, needle: String) -> Bool {
        if row.title.lowercased().contains(needle) { return true }
        if row.id.lowercased().contains(needle) { return true }
        if row.urlString.lowercased().contains(needle) { return true }
        for t in row.tags where t.lowercased().contains(needle) { return true }
        return false
    }

    nonisolated private static func rowMatchesGen(row: CatalogSearchSnapshot.GenRow, needle: String) -> Bool {
        if row.title.lowercased().contains(needle) { return true }
        if row.urlString.lowercased().contains(needle) { return true }
        if let a = row.author, a.lowercased().contains(needle) { return true }
        return false
    }

    nonisolated private static func formattedScpTitle(scpNumber: Int) -> String {
        let core = scpNumber < 1000 ? String(format: "%03d", scpNumber) : String(scpNumber)
        return "SCP-\(core)"
    }

    nonisolated private static func indexedSubtitle(articleTitle: String?, objectClass: String?, tags: [String]) -> String {
        if let t = articleTitle?.trimmingCharacters(in: .whitespacesAndNewlines), !t.isEmpty {
            return t
        }
        if let oc = objectClass?.trimmingCharacters(in: .whitespacesAndNewlines), !oc.isEmpty {
            return oc
        }
        let joined = tags.joined(separator: " · ")
        return joined
    }
}

@MainActor
enum CatalogSearchSnapshotBuilder {
    static func build(
        feedCache: SCPArticleFeedCacheRepository,
        indexedMatches: [JapanSCPArchiveEntry]
    ) -> CatalogSearchSnapshot {
        var scpRows: [CatalogSearchSnapshot.SCPRow] = []
        var genRows: [CatalogSearchSnapshot.GenRow] = []

        for kind in SCPArticleFeedKind.trifoldReportCases {
            guard let badge = GlobalSearchBadge.badge(forTrifold: kind) else { continue }
            let raw = feedCache.loadPersistedPayload(kind: kind)?.entries ?? []
            let entries: [SCPArticle] = if kind == .int {
                raw.filter { !InternationalBranchPortalOption.SCPIntSlugLanguageTail.isEnglishBranchCatalogEntry($0) }
            } else {
                raw
            }
            for a in entries {
                scpRows.append(
                    CatalogSearchSnapshot.SCPRow(
                        urlString: a.u,
                        title: a.t,
                        id: a.i,
                        tags: a.g,
                        badge: badge
                    )
                )
            }
        }

        for kind in SCPArticleFeedKind.allCases where kind.isMultiformArchiveFeed {
            guard let badge = GlobalSearchBadge.badge(forMultiform: kind) else { continue }
            let entries = feedCache.loadPersistedGeneralMultiformPayload(kind: kind)?.entries ?? []
            for g in entries {
                genRows.append(
                    CatalogSearchSnapshot.GenRow(
                        urlString: g.u,
                        title: g.t,
                        author: g.a,
                        badge: badge
                    )
                )
            }
        }

        let indexed: [CatalogSearchSnapshot.IndexedListRow] = indexedMatches.map { e in
            CatalogSearchSnapshot.IndexedListRow(
                urlString: e.url.absoluteString,
                scpNumber: e.scpNumber,
                articleTitle: e.articleTitle,
                objectClass: e.objectClass,
                tags: e.tags
            )
        }

        return CatalogSearchSnapshot(scpRows: scpRows, genRows: genRows, indexedListRows: indexed)
    }
}
