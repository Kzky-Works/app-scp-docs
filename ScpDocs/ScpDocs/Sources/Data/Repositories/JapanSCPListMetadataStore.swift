import Foundation
import Observation

/// `ContinueReadingSummary` 用: 日本支部 Wikidot の SCP 記事の種別と表示ヒント（フィードキャッシュ＋ Wikidot カタログ由来）。
struct JapanSCPListReadingHint: Sendable, Equatable {
    enum Flavor: Sendable, Equatable {
        case jpOriginal
        case mainlistTranslation
        case jokeJp
    }

    let flavor: Flavor
    let mergeKey: String
    let displaySlug: String
    let objectClass: String?
    let resolvedListTitle: String?
}

/// マニフェスト同期済みフィード（`SCPArticleFeedCacheRepository`）と Wikidot カタログを統合する参照ストア。
/// - 支部オリジナル題名: `.jp` フィードの `t`、無ければ埋め込み `JapanSCPArchiveTitleData`。
/// - 本家メイン和訳一覧題名: `.en` フィードの `t` のみ（未同期時は `nil`）。
@Observable
@MainActor
final class JapanSCPListMetadataStore {
    private let wikiCatalogCacheRepository: WikiCatalogCacheRepository
    private let articleFeedCache: SCPArticleFeedCacheRepository?
    private var jpBranchTitleByMergeKey: [String: String] = [:]
    private var mainlistTranslationTitleByMergeKey: [String: String] = [:]
    /// `docs/catalog/scp_jp.json`
    private var objectClassJPByMergeKey: [String: String] = [:]
    private var tagsJPByMergeKey: [String: [String]] = [:]
    /// `docs/catalog/scp.json`（本家メイン和訳）
    private var objectClassMainlistByMergeKey: [String: String] = [:]
    private var tagsMainlistByMergeKey: [String: [String]] = [:]
    /// `docs/catalog/joke.json`
    private var objectClassJokeByMergeKey: [String: String] = [:]
    private var tagsJokeByMergeKey: [String: [String]] = [:]
    /// ホーム「ランダムな報告書」用: 本家メインリスト和訳（`scp-NNN`）の URL プール（`.en` フィード）。
    private(set) var officialJapaneseTranslationRandomPool: [URL] = []

    init(wikiCatalogCacheRepository: WikiCatalogCacheRepository, articleFeedCache: SCPArticleFeedCacheRepository? = nil) {
        self.wikiCatalogCacheRepository = wikiCatalogCacheRepository
        self.articleFeedCache = articleFeedCache
        reloadFromCache()
    }

    func reloadFromCache() {
        reloadWikiCatalogIndexes()
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

    private func reloadWikiCatalogIndexes() {
        if let c = wikiCatalogCacheRepository.loadWikiCatalog(kind: .scpJp) {
            tagsJPByMergeKey = Self.buildWikiTagsIndex(from: c)
            objectClassJPByMergeKey = Self.buildWikiObjectClassIndex(from: c)
        } else {
            tagsJPByMergeKey = [:]
            objectClassJPByMergeKey = [:]
        }
        if let c = wikiCatalogCacheRepository.loadWikiCatalog(kind: .scpMainlist) {
            tagsMainlistByMergeKey = Self.buildWikiTagsIndex(from: c)
            objectClassMainlistByMergeKey = Self.buildWikiObjectClassIndex(from: c)
        } else {
            tagsMainlistByMergeKey = [:]
            objectClassMainlistByMergeKey = [:]
        }
        if let c = wikiCatalogCacheRepository.loadWikiCatalog(kind: .joke) {
            tagsJokeByMergeKey = Self.buildWikiTagsIndex(from: c)
            objectClassJokeByMergeKey = Self.buildWikiObjectClassIndex(from: c)
        } else {
            tagsJokeByMergeKey = [:]
            objectClassJokeByMergeKey = [:]
        }
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
            let key = Self.mergeKey(series: series, scpNumber: n)
            let oc = objectClassJPByMergeKey[key]
            let tags = tagsJPByMergeKey[key] ?? []
            return JapanSCPArchiveEntry(
                id: slug,
                scpNumber: n,
                url: url,
                articleTitle: injected,
                objectClass: oc,
                tags: tags
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
            let key = Self.mergeKey(series: series, scpNumber: n)
            let oc = objectClassMainlistByMergeKey[key]
            let tags = tagsMainlistByMergeKey[key] ?? []
            return JapanSCPArchiveEntry(
                id: slug,
                scpNumber: n,
                url: url,
                articleTitle: injected,
                objectClass: oc,
                tags: tags
            )
        }
    }

    private static func mergeKey(series: SCPJPSeries, scpNumber: Int) -> String {
        "\(series.rawValue)_\(scpNumber)"
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
        guard !digits.isEmpty, let n = Int(String(digits)), n > 0, n <= 4999 else { return nil }
        return n
    }

    private static func scpNumberFromMainSlug(_ i: String) -> Int? {
        let lower = i.lowercased()
        guard lower.hasPrefix("scp-"), !lower.contains("-jp") else { return nil }
        let tail = String(lower.dropFirst(4))
        guard !tail.contains("-"), tail.allSatisfy(\.isNumber), let n = Int(tail), n > 0, n <= 4999 else { return nil }
        return n
    }

    private static func buildWikiTagsIndex(from catalog: WikiCategoryCatalogPayload) -> [String: [String]] {
        var out: [String: [String]] = [:]
        for e in catalog.entries {
            guard let s = e.series, let n = e.scpNumber else { continue }
            guard let series = SCPJPSeries(rawValue: s), series.scpNumberRange.contains(n) else { continue }
            out["\(s)_\(n)"] = e.tags
        }
        return out
    }

    private static func buildWikiObjectClassIndex(from catalog: WikiCategoryCatalogPayload) -> [String: String] {
        var out: [String: String] = [:]
        for e in catalog.entries {
            guard let s = e.series, let n = e.scpNumber else { continue }
            guard let series = SCPJPSeries(rawValue: s), series.scpNumberRange.contains(n) else { continue }
            guard let oc = e.objectClass?.trimmingCharacters(in: .whitespacesAndNewlines), !oc.isEmpty else { continue }
            out["\(s)_\(n)"] = oc
        }
        return out
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
        let key = Self.mergeKey(series: series, scpNumber: n)
        let slug: String
        if n < 1000 {
            slug = String(format: "scp-%03d-jp", n)
        } else {
            slug = "scp-\(n)-jp"
        }
        let oc = objectClassJPByMergeKey[key] ?? a.c
        let catalogTags = tagsJPByMergeKey[key]
        let tags = (catalogTags?.isEmpty == false) ? catalogTags! : a.g
        return JapanSCPArchiveEntry(
            id: slug,
            scpNumber: n,
            url: series.articleURL(scpNumber: n),
            articleTitle: a.t,
            objectClass: oc,
            tags: tags
        )
    }

    private func japanArchiveEntryFromMainTrifold(_ a: SCPArticle) -> JapanSCPArchiveEntry? {
        guard let n = Self.scpNumberFromMainSlug(a.i), let series = Self.scpSeries(containing: n) else { return nil }
        let key = Self.mergeKey(series: series, scpNumber: n)
        let slug: String
        if n < 1000 {
            slug = String(format: "scp-%03d", n)
        } else {
            slug = "scp-\(n)"
        }
        let oc = objectClassMainlistByMergeKey[key] ?? a.c
        let catalogTags = tagsMainlistByMergeKey[key]
        let tags = (catalogTags?.isEmpty == false) ? catalogTags! : a.g
        return JapanSCPArchiveEntry(
            id: slug,
            scpNumber: n,
            url: series.englishMainlistTranslationArticleURL(scpNumber: n),
            articleTitle: a.t,
            objectClass: oc,
            tags: tags
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
            guard let v = Int(t), v > 0, v <= 4999 else { return nil }
            return v
        }
        let lower = t.lowercased()
        if lower.hasPrefix("scp-") {
            let digits = lower.dropFirst(4).filter(\.isNumber)
            guard !digits.isEmpty, let v = Int(String(digits)), v > 0, v <= 4999 else { return nil }
            return v
        }
        return nil
    }

    // MARK: - Continue reading（日本支部 Wikidot の SCP 記事）

    /// `scp-jp.wikidot.com` の JP オリジナル／本家メイン和訳／`-J` 系のときだけ値がある。
    func readingHint(for url: URL) -> JapanSCPListReadingHint? {
        guard url.host?.caseInsensitiveCompare("scp-jp.wikidot.com") == .orderedSame else { return nil }
        let slug = url.path.split(separator: "/").map(String.init).filter { !$0.isEmpty }.last ?? ""
        guard let parsed = Self.parseJapanListSCP(slug: slug) else { return nil }
        let oc: String? = switch parsed.flavor {
        case .jpOriginal:
            objectClassJPByMergeKey[parsed.mergeKey]
        case .mainlistTranslation:
            objectClassMainlistByMergeKey[parsed.mergeKey]
        case .jokeJp:
            objectClassJokeByMergeKey[parsed.mergeKey]
        }
        let listTitle: String? = switch parsed.flavor {
        case .jpOriginal:
            resolvedJPBranchArticleTitle(scpNumber: parsed.scpNumber, series: parsed.series)
        case .mainlistTranslation:
            resolvedMainlistTranslationArticleTitle(scpNumber: parsed.scpNumber, series: parsed.series)
        case .jokeJp:
            resolvedJPBranchArticleTitle(scpNumber: parsed.scpNumber, series: parsed.series)
        }
        return JapanSCPListReadingHint(
            flavor: parsed.flavor,
            mergeKey: parsed.mergeKey,
            displaySlug: parsed.displaySlug,
            objectClass: oc,
            resolvedListTitle: listTitle
        )
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

    private struct ParsedJapanListSCP: Sendable {
        let flavor: JapanSCPListReadingHint.Flavor
        let mergeKey: String
        let series: SCPJPSeries
        let scpNumber: Int
        let displaySlug: String
    }
}
