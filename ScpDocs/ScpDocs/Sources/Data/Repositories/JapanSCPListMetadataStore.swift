import Foundation
import Observation

/// `ContinueReadingSummary` 用: `scp_list` が追える日本支部の SCP 記事の種別と表示ヒント。
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

/// Phase 13: リモート同期タイトルと埋め込み `JapanSCPArchiveTitleData` を統合する参照ストア。
/// - `title`（JSON）: SCP-JP オリジナル一覧用。埋め込み辞書はここへフォールバック。
/// - `mainlistTranslationTitle`（JSON）: 本家メインリスト和訳（`scp-series`）一覧専用。未同期時はタイトル不明（`title` にはフォールバックしない）。
@Observable
@MainActor
final class JapanSCPListMetadataStore {
    private let cacheRepository: SCPListCacheRepository
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
    /// ホーム「ランダムな報告書」用: 本家メインリスト和訳（`scp-NNN`）のプール（`entries` + `hubLinkedPaths`）。
    private(set) var officialJapaneseTranslationRandomPool: [URL] = []

    init(cacheRepository: SCPListCacheRepository) {
        self.cacheRepository = cacheRepository
        reloadFromCache()
    }

    func reloadFromCache() {
        guard let payload = cacheRepository.loadPersistedPayload() else {
            jpBranchTitleByMergeKey = [:]
            mainlistTranslationTitleByMergeKey = [:]
            clearWikiDerivedIndexes()
            officialJapaneseTranslationRandomPool = []
            return
        }
        jpBranchTitleByMergeKey = Self.buildJPBranchTitleIndex(from: payload)
        mainlistTranslationTitleByMergeKey = Self.buildMainlistTranslationTitleIndex(from: payload)
        reloadWikiCatalogIndexes()
        officialJapaneseTranslationRandomPool = Self.buildOfficialJapaneseTranslationRandomPool(from: payload)
    }

    private func clearWikiDerivedIndexes() {
        objectClassJPByMergeKey = [:]
        tagsJPByMergeKey = [:]
        objectClassMainlistByMergeKey = [:]
        tagsMainlistByMergeKey = [:]
        objectClassJokeByMergeKey = [:]
        tagsJokeByMergeKey = [:]
    }

    private func reloadWikiCatalogIndexes() {
        if let c = cacheRepository.loadWikiCatalog(kind: .scpJp) {
            tagsJPByMergeKey = Self.buildWikiTagsIndex(from: c)
            objectClassJPByMergeKey = Self.buildWikiObjectClassIndex(from: c)
        } else {
            tagsJPByMergeKey = [:]
            objectClassJPByMergeKey = [:]
        }
        if let c = cacheRepository.loadWikiCatalog(kind: .scpMainlist) {
            tagsMainlistByMergeKey = Self.buildWikiTagsIndex(from: c)
            objectClassMainlistByMergeKey = Self.buildWikiObjectClassIndex(from: c)
        } else {
            tagsMainlistByMergeKey = [:]
            objectClassMainlistByMergeKey = [:]
        }
        if let c = cacheRepository.loadWikiCatalog(kind: .joke) {
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

    private static func buildJPBranchTitleIndex(from payload: SCPListRemotePayload) -> [String: String] {
        var out: [String: String] = [:]
        out.reserveCapacity(payload.entries.count)
        for e in payload.entries {
            guard let s = SCPJPSeries(rawValue: e.series), s.scpNumberRange.contains(e.scpNumber) else { continue }
            let key = e.mergeKey
            let t = e.title.trimmingCharacters(in: .whitespacesAndNewlines)
            if !t.isEmpty {
                out[key] = t
            }
        }
        return out
    }

    private static func buildMainlistTranslationTitleIndex(from payload: SCPListRemotePayload) -> [String: String] {
        var out: [String: String] = [:]
        for e in payload.entries {
            guard let s = SCPJPSeries(rawValue: e.series), s.scpNumberRange.contains(e.scpNumber) else { continue }
            guard let raw = e.mainlistTranslationTitle else { continue }
            let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            if !t.isEmpty {
                out[e.mergeKey] = t
            }
        }
        return out
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

    private static let japanSiteBase = URL(string: "https://scp-jp.wikidot.com")!

    private static func buildOfficialJapaneseTranslationRandomPool(from payload: SCPListRemotePayload) -> [URL] {
        var seenPath = Set<String>()
        var urls: [URL] = []
        urls.reserveCapacity(payload.entries.count + payload.hubLinkedPaths.count)

        for e in payload.entries {
            guard let series = SCPJPSeries(rawValue: e.series), series.scpNumberRange.contains(e.scpNumber) else {
                continue
            }
            let url = series.englishMainlistTranslationArticleURL(scpNumber: e.scpNumber)
            let path = url.path
            guard seenPath.insert(path).inserted else { continue }
            urls.append(url)
        }

        for raw in payload.hubLinkedPaths {
            let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }
            let path = trimmed.hasPrefix("/") ? trimmed : "/\(trimmed)"
            guard seenPath.insert(path).inserted else { continue }
            guard let u = URL(string: path, relativeTo: japanSiteBase) else { continue }
            urls.append(u.absoluteURL)
        }

        return urls
    }

    /// `scp_list.json` 同期済みエントリを対象に、番号・タイトル・オブジェクトクラス・タグのいずれかに一致する報告書を返す（最大 `limit` 件）。
    func searchIndexedEntries(matching rawQuery: String, limit: Int = 200) -> [JapanSCPArchiveEntry] {
        guard let payload = cacheRepository.loadPersistedPayload() else { return [] }
        let q = rawQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return [] }

        if let dedicated = Self.parseDedicatedSCPNumber(from: q) {
            let matches: [JapanSCPArchiveEntry] = payload.entries.compactMap { remote in
                guard let series = SCPJPSeries(rawValue: remote.series),
                      series.scpNumberRange.contains(remote.scpNumber),
                      remote.scpNumber == dedicated
                else { return nil }
                return buildEnglishStyleEntryFromRemote(remote, series: series)
            }
            return Array(matches.prefix(limit))
        }

        var results: [JapanSCPArchiveEntry] = []
        results.reserveCapacity(min(limit, payload.entries.count))
        for remote in payload.entries {
            guard let series = SCPJPSeries(rawValue: remote.series),
                  series.scpNumberRange.contains(remote.scpNumber) else { continue }
            guard let entry = buildEnglishStyleEntryFromRemote(remote, series: series) else { continue }
            if entryMatchesSearch(entry: entry, remote: remote, query: q) {
                results.append(entry)
                if results.count >= limit { break }
            }
        }
        return results
    }

    private func buildEnglishStyleEntryFromRemote(_ remote: SCPListRemoteEntry, series: SCPJPSeries) -> JapanSCPArchiveEntry? {
        let n = remote.scpNumber
        let key = remote.mergeKey
        let url = series.englishMainlistTranslationArticleURL(scpNumber: n)
        let slug: String
        if n < 1000 {
            slug = String(format: "scp-%03d", n)
        } else {
            slug = "scp-\(n)"
        }
        let injected = mainlistTranslationTitleByMergeKey[key] ?? remote.mainlistTranslationTitle
        let trimmed = injected?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let title: String? = trimmed.isEmpty ? nil : trimmed
        let oc = objectClassMainlistByMergeKey[key] ?? remote.objectClass
        let tags: [String]
        if let tt = tagsMainlistByMergeKey[key], !tt.isEmpty {
            tags = tt
        } else {
            tags = remote.tags
        }
        return JapanSCPArchiveEntry(
            id: slug,
            scpNumber: n,
            url: url,
            articleTitle: title,
            objectClass: oc,
            tags: tags
        )
    }

    private func entryMatchesSearch(entry: JapanSCPArchiveEntry, remote: SCPListRemoteEntry, query: String) -> Bool {
        if entry.articleTitle?.localizedStandardContains(query) == true { return true }
        if remote.title.localizedStandardContains(query) { return true }
        if remote.mainlistTranslationTitle?.localizedStandardContains(query) == true { return true }
        if let oc = entry.objectClass, oc.localizedStandardContains(query) { return true }
        for t in entry.tags where t.localizedStandardContains(query) {
            return true
        }
        let numStr = String(remote.scpNumber)
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

    // MARK: - Continue reading（`scp_list` 同期済みの日本支部 SCP 記事）

    /// `scp-jp.wikidot.com` の `scp_list.json` 対象ページ（JP オリジナル／本家メイン和訳／`-j`）のときだけ値がある。
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
