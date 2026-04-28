import Foundation
import Observation

/// `ContinueReadingSummary` 用: 日本支部・国際支部 Wikidot の報告書の種別と表示ヒント（フィードキャッシュ＋ `list/jp/jp_tag.json` 由来）。
struct JapanSCPListReadingHint: Sendable, Equatable {
    enum Flavor: Sendable, Equatable {
        case jpOriginal
        case mainlistTranslation
        case jokeJp
        case intInternational
    }

    let flavor: Flavor
    let mergeKey: String
    let displaySlug: String
    let objectClass: String?
    let resolvedListTitle: String?
    /// `jp_tag` ＋フィードをマージしたタグ（記事下部メタデータ用）。
    let mergedTags: [String]
}

/// 記事からアーカイヴ一覧へ遷移するときの対象（日本支部オリジナル vs 本家メイン和訳 / 国際支部）。
enum JapanTrifoldArchiveListTarget: Sendable, Equatable {
    case japanBranch
    case englishMainlistTranslation
    case internationalBranch
}

/// `ArticleView` 下部: タグチップとアーカイヴへの逆引き。
struct WikidotScpArticleMetadataStrip: Sendable, Equatable {
    let objectClassWikiTitle: String?
    let displayTags: [String]
    let archiveTarget: JapanTrifoldArchiveListTarget
}

/// マニフェスト同期済みフィード（`SCPArticleFeedCacheRepository`）と `list/jp/jp_tag.json` を統合する参照ストア。
/// - 支部オリジナル題名: `.jp` フィードの `t`、無ければ埋め込み `JapanSCPArchiveTitleData`。
/// - 本家メイン和訳一覧題名: `.en` フィードの `t` のみ（未同期時は `nil`）。
@Observable
@MainActor
final class JapanSCPListMetadataStore {
    private let jpTagMapCache: JPTagMapCacheRepository
    private let articleFeedCache: SCPArticleFeedCacheRepository?
    private var jpBranchTitleByMergeKey: [String: String] = [:]
    private var mainlistTranslationTitleByMergeKey: [String: String] = [:]
    /// スラッグ小文字 → `jp_tag.articles` のタグ配列
    private var articleTagsByLowercasedSlug: [String: [String]] = [:]
    /// ホーム「ランダムな報告書」用: 本家メインリスト和訳ページ（`scp-NNN`）の URL プール（`.en` フィード）。
    private(set) var officialJapaneseTranslationRandomPool: [URL] = []

    init(jpTagMapCache: JPTagMapCacheRepository, articleFeedCache: SCPArticleFeedCacheRepository? = nil) {
        self.jpTagMapCache = jpTagMapCache
        self.articleFeedCache = articleFeedCache
        reloadFromCache()
    }

    func reloadFromCache() {
        reloadJPTagMapIndexes()
        if let fc = articleFeedCache {
            jpBranchTitleByMergeKey = Self.buildJPBranchTitleIndexFromTrifoldFeed(fc)
            mainlistTranslationTitleByMergeKey = Self.buildMainlistTitleIndexFromTrifoldFeed(fc)
            officialJapaneseTranslationRandomPool = Self.buildOfficialJapaneseTranslationRandomPoolFromTrifoldFeed(fc)
        } else {
            jpBranchTitleByMergeKey = [:]
            mainlistTranslationTitleByMergeKey = [:]
            officialJapaneseTranslationRandomPool = []
        }
    }

    private func reloadJPTagMapIndexes() {
        guard let p = jpTagMapCache.loadPayload() else {
            articleTagsByLowercasedSlug = [:]
            return
        }
        var d: [String: [String]] = [:]
        d.reserveCapacity(p.articles.count)
        for (k, v) in p.articles {
            d[k.lowercased()] = v
        }
        articleTagsByLowercasedSlug = d
    }

    // MARK: - jp_tag 参照（一覧・メタ用）

    func tagsFromJPTagMap(articleId: String) -> [String] {
        articleTagsByLowercasedSlug[articleId.lowercased()] ?? []
    }

    private func coalescedFromMapAndFeed(mapTags: [String], feedTags: [String]) -> [String] {
        if !mapTags.isEmpty { return mapTags }
        return feedTags
    }

    /// 3 系統フィード一覧行: `jp_tag` を優先し OC を解決。
    func trifoldListRowObjectClass(article: SCPArticle) -> String? {
        let mapTags = tagsFromJPTagMap(articleId: article.i)
        let merged = coalescedFromMapAndFeed(mapTags: mapTags, feedTags: article.g)
        return SCPJPTagObjectClassCatalog.resolvedWikiObjectClass(catalogOrFeedClass: article.c, tags: merged)
    }

    /// ジョーク物マニフェスト一覧: `jp_tag` 優先、`manifest_jokes` の metadata `c` を反映。
    func jokeMultiformListRowObjectClass(entry: SCPGeneralContent) -> String? {
        let slug: String
        if let i = entry.i?.trimmingCharacters(in: .whitespacesAndNewlines), !i.isEmpty {
            slug = i
        } else {
            slug = Self.slugFromMultiformURLString(entry.u)
        }
        let mapTags = tagsFromJPTagMap(articleId: slug)
        let merged = coalescedFromMapAndFeed(mapTags: mapTags, feedTags: entry.g)
        return SCPJPTagObjectClassCatalog.resolvedWikiObjectClass(catalogOrFeedClass: entry.c, tags: merged)
    }

    private static func slugFromMultiformURLString(_ raw: String) -> String {
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty, let url = URL(string: t) else { return "" }
        let parts = url.path.split(separator: "/").map(String.init).filter { !$0.isEmpty }
        return parts.last ?? ""
    }

    /// 日本支部向け: 同期済み一覧から本家メインリスト和訳ページ（`scp-jp.wikidot.com/scp-NNN`）を 1 件ランダムに選ぶ。プールが空のときは `nil`。
    func randomOfficialJapaneseTranslationURL() -> URL? {
        officialJapaneseTranslationRandomPool.randomElement()
    }

    /// 日本支部オリジナル（`scp-NNN-jp`）一覧: リモート `title` → 埋め込み `JapanSCPArchiveTitleData`。
    func resolvedJPBranchArticleTitle(scpNumber: Int, series: SCPJPSeries) -> String? {
        let key = Self.mergeKey(series: series, scpNumber: scpNumber)
        if let remote = jpBranchTitleByMergeKey[key], !remote.isEmpty {
            return remote
        }
        return JapanSCPArchiveTitleData.title(scpNumber: scpNumber, series: series)
    }

    /// 本家メインリスト和訳（`scp-NNN`）一覧: リモート `mainlistTranslationTitle` のみ。未設定は `nil`（SCP-JP の `title` や埋め込みは使わない）。
    func resolvedMainlistTranslationArticleTitle(scpNumber: Int, series: SCPJPSeries) -> String? {
        let key = Self.mergeKey(series: series, scpNumber: scpNumber)
        if let remote = mainlistTranslationTitleByMergeKey[key], !remote.isEmpty {
            return remote
        }
        return nil
    }

    /// 指定シリーズ・100 件セグメントの報告書一覧（番号順・URL・タイトル）。
    func japanSCPArchiveEntries(series: SCPJPSeries, segmentStart: Int) -> [JapanSCPArchiveEntry] {
        series.numbersInSegment(segmentStart: segmentStart).map { n in
            let url = series.articleURL(scpNumber: n)
            let slug: String
            if n < 1000 {
                slug = String(format: "scp-%03d-jp", n)
            } else {
                slug = "scp-\(n)-jp"
            }
            let injected = resolvedJPBranchArticleTitle(scpNumber: n, series: series)
            let jt = tagsFromJPTagMap(articleId: slug)
            return buildArchiveEntry(
                id: slug,
                scpNumber: n,
                url: url,
                articleTitle: injected,
                jptagTags: jt,
                feedOC: nil,
                feedTags: []
            )
        }
    }

    /// 本家メインリストの日本語訳（`scp-jp.wikidot.com/scp-series` 系）の一覧。タイトルは `mainlistTranslationTitle` のみ（SCP-JP の `title` は使わない）。
    func englishMainlistTranslationArchiveEntries(series: SCPJPSeries, segmentStart: Int) -> [JapanSCPArchiveEntry] {
        series.numbersInSegment(segmentStart: segmentStart).map { n in
            let url = series.englishMainlistTranslationArticleURL(scpNumber: n)
            let slug: String
            if n < 1000 {
                slug = String(format: "scp-%03d", n)
            } else {
                slug = "scp-\(n)"
            }
            let injected = resolvedMainlistTranslationArticleTitle(scpNumber: n, series: series)
            let jt = tagsFromJPTagMap(articleId: slug)
            return buildArchiveEntry(
                id: slug,
                scpNumber: n,
                url: url,
                articleTitle: injected,
                jptagTags: jt,
                feedOC: nil,
                feedTags: []
            )
        }
    }

    private static func mergeKey(series: SCPJPSeries, scpNumber: Int) -> String {
        "\(series.rawValue)_\(scpNumber)"
    }

    private func buildArchiveEntry(
        id: String,
        scpNumber: Int,
        url: URL,
        articleTitle: String?,
        jptagTags: [String],
        feedOC: String?,
        feedTags: [String]
    ) -> JapanSCPArchiveEntry {
        let merged = coalescedFromMapAndFeed(mapTags: jptagTags, feedTags: feedTags)
        let oc = SCPJPTagObjectClassCatalog.resolvedWikiObjectClass(catalogOrFeedClass: feedOC, tags: merged)
        let tags = SCPJPTagObjectClassCatalog.tagsStrippingObjectClassMarkers(merged)
        return JapanSCPArchiveEntry(
            id: id,
            scpNumber: scpNumber,
            url: url,
            articleTitle: articleTitle,
            objectClass: oc,
            tags: tags
        )
    }

    private func feedTagsAndClass(for parsed: ParsedJapanListSCP) -> (tags: [String], c: String?) {
        guard let fc = articleFeedCache else { return ([], nil) }
        switch parsed.flavor {
        case .jpOriginal:
            for a in fc.loadPersistedPayload(kind: .jp)?.entries ?? [] {
                guard let n = Self.scpNumberFromJapanSlug(a.i), n == parsed.scpNumber else { continue }
                return (a.g, a.c)
            }
        case .mainlistTranslation:
            for a in fc.loadPersistedPayload(kind: .en)?.entries ?? [] {
                guard let n = Self.scpNumberFromMainSlug(a.i), n == parsed.scpNumber else { continue }
                return (a.g, a.c)
            }
        case .jokeJp:
            let jpJokeIdLower: String
            let enStyleJokeIdLower: String
            if parsed.scpNumber < 1000 {
                jpJokeIdLower = String(format: "scp-%03d-jp-j", parsed.scpNumber).lowercased()
                enStyleJokeIdLower = String(format: "scp-%03d-j", parsed.scpNumber).lowercased()
            } else {
                jpJokeIdLower = "scp-\(parsed.scpNumber)-jp-j".lowercased()
                enStyleJokeIdLower = "scp-\(parsed.scpNumber)-j".lowercased()
            }
            for e in fc.loadPersistedGeneralMultiformPayload(kind: .jokes)?.entries ?? [] {
                guard let raw = e.i?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else { continue }
                let lid = raw.lowercased()
                if lid == jpJokeIdLower || lid == enStyleJokeIdLower { return (e.g, e.c) }
            }
        }
        return ([], nil)
    }

    /// `scp-jp` / `scp-int` の報告書系 URL のとき、記事下部に出すタグ・オブジェクトクラス（アーカイヴ逆引き用）。
    func wikidotTrifoldArticleMetadataStrip(for url: URL) -> WikidotScpArticleMetadataStrip? {
        guard let hint = readingHint(for: url) else { return nil }
        let stripped = SCPJPTagObjectClassCatalog.tagsStrippingObjectClassMarkers(hint.mergedTags)
        guard hint.objectClass != nil || !stripped.isEmpty else { return nil }
        let archiveTarget: JapanTrifoldArchiveListTarget = switch hint.flavor {
        case .jpOriginal, .jokeJp:
            .japanBranch
        case .mainlistTranslation:
            .englishMainlistTranslation
        case .intInternational:
            .internationalBranch
        }
        return WikidotScpArticleMetadataStrip(
            objectClassWikiTitle: hint.objectClass,
            displayTags: stripped,
            archiveTarget: archiveTarget
        )
    }

    private static func buildJPBranchTitleIndexFromTrifoldFeed(_ feed: SCPArticleFeedCacheRepository) -> [String: String] {
        var out: [String: String] = [:]
        let entries = feed.loadPersistedPayload(kind: .jp)?.entries ?? []
        out.reserveCapacity(entries.count)
        for a in entries {
            guard let n = scpNumberFromJapanSlug(a.i), let series = Self.scpSeries(containing: n) else { continue }
            let key = mergeKey(series: series, scpNumber: n)
            let t = a.t.trimmingCharacters(in: .whitespacesAndNewlines)
            if !t.isEmpty { out[key] = t }
        }
        return out
    }

    private static func buildMainlistTitleIndexFromTrifoldFeed(_ feed: SCPArticleFeedCacheRepository) -> [String: String] {
        var out: [String: String] = [:]
        let entries = feed.loadPersistedPayload(kind: .en)?.entries ?? []
        for a in entries {
            guard let n = scpNumberFromMainSlug(a.i), let series = Self.scpSeries(containing: n) else { continue }
            let key = mergeKey(series: series, scpNumber: n)
            let t = a.t.trimmingCharacters(in: .whitespacesAndNewlines)
            if !t.isEmpty { out[key] = t }
        }
        return out
    }

    private static func buildOfficialJapaneseTranslationRandomPoolFromTrifoldFeed(_ feed: SCPArticleFeedCacheRepository) -> [URL] {
        let entries = feed.loadPersistedPayload(kind: .en)?.entries ?? []
        return entries.compactMap(\.resolvedURL)
    }

    private static func scpNumberFromJapanSlug(_ i: String) -> Int? {
        let lower = i.lowercased()
        guard lower.hasSuffix("-jp") else { return nil }
        let digits = lower.dropLast(3).dropFirst(4).filter(\.isNumber)
        guard !digits.isEmpty, let n = Int(String(digits)), n > 0, n <= SCPJPSeries.canonicalTrifoldReportNumberUpperBound else { return nil }
        return n
    }

    private static func scpNumberFromMainSlug(_ i: String) -> Int? {
        let lower = i.lowercased()
        guard lower.hasPrefix("scp-"), !lower.contains("-jp") else { return nil }
        let tail = String(lower.dropFirst(4))
        guard !tail.contains("-"), tail.allSatisfy(\.isNumber), let n = Int(tail), n > 0, n <= SCPJPSeries.canonicalTrifoldReportNumberUpperBound else { return nil }
        return n
    }

    /// マニフェスト同期済み `.jp` / `.en` フィードを対象に、番号・タイトル・オブジェクトクラス・タグのいずれかに一致する報告書を返す（最大 `limit` 件）。
    func searchIndexedEntries(matching rawQuery: String, limit: Int = 200) -> [JapanSCPArchiveEntry] {
        guard let fc = articleFeedCache else { return [] }
        let q = rawQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return [] }

        let jpArticles = fc.loadPersistedPayload(kind: .jp)?.entries ?? []
        let enArticles = fc.loadPersistedPayload(kind: .en)?.entries ?? []

        if let dedicated = Self.parseDedicatedSCPNumber(from: q) {
            var matches: [JapanSCPArchiveEntry] = []
            for a in jpArticles {
                guard let entry = japanArchiveEntryFromJPTrifold(a), entry.scpNumber == dedicated else { continue }
                matches.append(entry)
            }
            for a in enArticles {
                guard let entry = japanArchiveEntryFromMainTrifold(a), entry.scpNumber == dedicated else { continue }
                matches.append(entry)
            }
            return Array(matches.prefix(limit))
        }

        var results: [JapanSCPArchiveEntry] = []
        results.reserveCapacity(min(limit, jpArticles.count + enArticles.count))
        for a in jpArticles {
            guard let entry = japanArchiveEntryFromJPTrifold(a) else { continue }
            if entryMatchesTrifoldSearch(entry: entry, articleTitle: a.t, articleTags: a.g, query: q) {
                results.append(entry)
                if results.count >= limit { break }
            }
        }
        for a in enArticles where results.count < limit {
            guard let entry = japanArchiveEntryFromMainTrifold(a) else { continue }
            if entryMatchesTrifoldSearch(entry: entry, articleTitle: a.t, articleTags: a.g, query: q) {
                results.append(entry)
                if results.count >= limit { break }
            }
        }
        return results
    }

    private func japanArchiveEntryFromJPTrifold(_ a: SCPArticle) -> JapanSCPArchiveEntry? {
        guard let n = Self.scpNumberFromJapanSlug(a.i), let series = Self.scpSeries(containing: n) else { return nil }
        let slug: String
        if n < 1000 {
            slug = String(format: "scp-%03d-jp", n)
        } else {
            slug = "scp-\(n)-jp"
        }
        let jt = tagsFromJPTagMap(articleId: a.i)
        return buildArchiveEntry(
            id: slug,
            scpNumber: n,
            url: series.articleURL(scpNumber: n),
            articleTitle: a.t,
            jptagTags: jt,
            feedOC: a.c,
            feedTags: a.g
        )
    }

    private func japanArchiveEntryFromMainTrifold(_ a: SCPArticle) -> JapanSCPArchiveEntry? {
        guard let n = Self.scpNumberFromMainSlug(a.i), let series = Self.scpSeries(containing: n) else { return nil }
        let slug: String
        if n < 1000 {
            slug = String(format: "scp-%03d", n)
        } else {
            slug = "scp-\(n)"
        }
        let jt = tagsFromJPTagMap(articleId: a.i)
        return buildArchiveEntry(
            id: slug,
            scpNumber: n,
            url: series.englishMainlistTranslationArticleURL(scpNumber: n),
            articleTitle: a.t,
            jptagTags: jt,
            feedOC: a.c,
            feedTags: a.g
        )
    }

    private func entryMatchesTrifoldSearch(entry: JapanSCPArchiveEntry, articleTitle: String, articleTags: [String], query: String) -> Bool {
        if entry.articleTitle?.localizedStandardContains(query) == true { return true }
        if articleTitle.localizedStandardContains(query) { return true }
        if let oc = entry.objectClass, oc.localizedStandardContains(query) { return true }
        for t in entry.tags where t.localizedStandardContains(query) {
            return true
        }
        for t in articleTags where t.localizedStandardContains(query) {
            return true
        }
        let numStr = String(entry.scpNumber)
        if query.allSatisfy(\.isNumber), numStr.contains(query) { return true }
        return false
    }

    private static func parseDedicatedSCPNumber(from raw: String) -> Int? {
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return nil }
        if t.allSatisfy(\.isNumber) {
            guard let v = Int(t), v > 0, v <= SCPJPSeries.canonicalTrifoldReportNumberUpperBound else { return nil }
            return v
        }
        let lower = t.lowercased()
        if lower.hasPrefix("scp-") {
            let digits = lower.dropFirst(4).filter(\.isNumber)
            guard !digits.isEmpty, let v = Int(String(digits)), v > 0, v <= SCPJPSeries.canonicalTrifoldReportNumberUpperBound else { return nil }
            return v
        }
        return nil
    }

    // MARK: - Continue reading（`jp_tag` ＋フィード）

    /// `scp-jp` / `scp-int` 国際版の報告書系 URL のとき、続きから読む用のヒント。
    func readingHint(for url: URL) -> JapanSCPListReadingHint? {
        let host = url.host?.lowercased() ?? ""
        if host == "scp-int.wikidot.com" {
            return readingHintScpInt(url: url)
        }
        guard host == "scp-jp.wikidot.com" else { return nil }
        let slug = url.path.split(separator: "/").map(String.init).filter { !$0.isEmpty }.last ?? ""
        guard let parsed = Self.parseJapanListSCP(slug: slug) else { return nil }
        return readingHintScpJP(slug: slug, parsed: parsed)
    }

    private func readingHintScpInt(url: URL) -> JapanSCPListReadingHint? {
        let slug = url.path.split(separator: "/").map(String.init).filter { !$0.isEmpty }.last ?? ""
        guard !slug.isEmpty else { return nil }
        let mapTags = tagsFromJPTagMap(articleId: slug)
        var feedTags: [String] = []
        var feedC: String?
        var listTitle: String?
        if let fc = articleFeedCache {
            for a in fc.loadPersistedPayload(kind: .int)?.entries ?? [] {
                if a.i.lowercased() == slug.lowercased() {
                    feedTags = a.g
                    feedC = a.c
                    let trimmed = a.t.trimmingCharacters(in: .whitespacesAndNewlines)
                    listTitle = trimmed.isEmpty ? nil : trimmed
                    break
                }
            }
        }
        let merged = coalescedFromMapAndFeed(mapTags: mapTags, feedTags: feedTags)
        let resolvedOC = SCPJPTagObjectClassCatalog.resolvedWikiObjectClass(catalogOrFeedClass: feedC, tags: merged)
        return JapanSCPListReadingHint(
            flavor: .intInternational,
            mergeKey: slug,
            displaySlug: Self.scpStyleDisplayFromSlug(slug),
            objectClass: resolvedOC,
            resolvedListTitle: listTitle,
            mergedTags: merged
        )
    }

    private func readingHintScpJP(slug: String, parsed: ParsedJapanListSCP) -> JapanSCPListReadingHint? {
        let mapTags = tagsFromJPTagMap(articleId: slug)
        let feed = feedTagsAndClass(for: parsed)
        let merged = coalescedFromMapAndFeed(mapTags: mapTags, feedTags: feed.tags)
        let resolvedOC = SCPJPTagObjectClassCatalog.resolvedWikiObjectClass(catalogOrFeedClass: feed.c, tags: merged)
        let listTitle: String? = switch parsed.flavor {
        case .jpOriginal:
            resolvedJPBranchArticleTitle(scpNumber: parsed.scpNumber, series: parsed.series)
        case .mainlistTranslation:
            resolvedMainlistTranslationArticleTitle(scpNumber: parsed.scpNumber, series: parsed.series)
        case .jokeJp:
            resolvedJPBranchArticleTitle(scpNumber: parsed.scpNumber, series: parsed.series)
        }
        return JapanSCPListReadingHint(
            flavor: parsed.hintFlavor,
            mergeKey: parsed.mergeKey,
            displaySlug: parsed.displaySlug,
            objectClass: resolvedOC,
            resolvedListTitle: listTitle,
            mergedTags: merged
        )
    }

    private static func scpStyleDisplayFromSlug(_ slug: String) -> String {
        let s = slug.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.lowercased().hasPrefix("scp-") {
            return s.uppercased(with: Locale(identifier: "en"))
        }
        return s
    }

    private static func parseJapanListSCP(slug: String) -> ParsedJapanListSCP? {
        let lower = slug.lowercased()
        guard lower.hasPrefix("scp-") else { return nil }

        if lower.hasSuffix("-jp") {
            let digits = String(lower.dropLast(3).dropFirst(4)).filter(\.isNumber)
            guard let n = Int(digits), let series = scpSeries(containing: n) else { return nil }
            let mergeKey = "\(series.rawValue)_\(n)"
            return ParsedJapanListSCP(
                flavor: .jpOriginal,
                hintFlavor: .jpOriginal,
                mergeKey: mergeKey,
                series: series,
                scpNumber: n,
                displaySlug: formatScpSlug(scpNumber: n, suffix: "-JP")
            )
        }

        if lower.hasSuffix("-j"), !lower.hasSuffix("-jp") {
            let digits = String(lower.dropLast(2).dropFirst(4)).filter(\.isNumber)
            guard let n = Int(digits), let series = scpSeries(containing: n) else { return nil }
            let mergeKey = "\(series.rawValue)_\(n)"
            return ParsedJapanListSCP(
                flavor: .jokeJp,
                hintFlavor: .jokeJp,
                mergeKey: mergeKey,
                series: series,
                scpNumber: n,
                displaySlug: formatScpSlug(scpNumber: n, suffix: "-J")
            )
        }

        let tail = String(lower.dropFirst(4))
        guard tail.allSatisfy(\.isNumber), let n = Int(tail), let series = scpSeries(containing: n) else {
            return nil
        }
        let mergeKey = "\(series.rawValue)_\(n)"
        return ParsedJapanListSCP(
            flavor: .mainlistTranslation,
            hintFlavor: .mainlistTranslation,
            mergeKey: mergeKey,
            series: series,
            scpNumber: n,
            displaySlug: formatScpSlug(scpNumber: n, suffix: "")
        )
    }

    private static func scpSeries(containing scpNumber: Int) -> SCPJPSeries? {
        SCPJPSeries.allCases.first { $0.scpNumberRange.contains(scpNumber) }
    }

    private static func formatScpSlug(scpNumber: Int, suffix: String) -> String {
        let core: String
        if scpNumber < 1000 {
            core = String(format: "SCP-%03d", scpNumber)
        } else {
            core = "SCP-\(scpNumber)"
        }
        return core + suffix
    }

    private enum ParsedScpJPFlavor: Sendable, Equatable {
        case jpOriginal
        case mainlistTranslation
        case jokeJp
    }

    private struct ParsedJapanListSCP: Sendable {
        let flavor: ParsedScpJPFlavor
        let hintFlavor: JapanSCPListReadingHint.Flavor
        let mergeKey: String
        let series: SCPJPSeries
        let scpNumber: Int
        let displaySlug: String
    }
}

