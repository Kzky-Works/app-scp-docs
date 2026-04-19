import Foundation
import Observation

/// Phase 13: リモート同期タイトルと埋め込み `JapanSCPArchiveTitleData` を統合する参照ストア。
/// - `title`（JSON）: SCP-JP オリジナル一覧用。埋め込み辞書はここへフォールバック。
/// - `mainlistTranslationTitle`（JSON）: 本家メインリスト和訳（`scp-series`）一覧専用。未同期時はタイトル不明（`title` にはフォールバックしない）。
@Observable
@MainActor
final class JapanSCPListMetadataStore {
    private let cacheRepository: SCPListCacheRepository
    private var jpBranchTitleByMergeKey: [String: String] = [:]
    private var mainlistTranslationTitleByMergeKey: [String: String] = [:]
    private var objectClassByMergeKey: [String: String] = [:]
    private var tagsByMergeKey: [String: [String]] = [:]
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
            objectClassByMergeKey = [:]
            tagsByMergeKey = [:]
            officialJapaneseTranslationRandomPool = []
            return
        }
        jpBranchTitleByMergeKey = Self.buildJPBranchTitleIndex(from: payload)
        mainlistTranslationTitleByMergeKey = Self.buildMainlistTranslationTitleIndex(from: payload)
        objectClassByMergeKey = Self.buildObjectClassIndex(from: payload)
        tagsByMergeKey = Self.buildTagsIndex(from: payload)
        officialJapaneseTranslationRandomPool = Self.buildOfficialJapaneseTranslationRandomPool(from: payload)
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
            let oc = objectClassByMergeKey[key]
            let tags = tagsByMergeKey[key] ?? []
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
            let oc = objectClassByMergeKey[key]
            let tags = tagsByMergeKey[key] ?? []
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

    private static func buildObjectClassIndex(from payload: SCPListRemotePayload) -> [String: String] {
        var out: [String: String] = [:]
        for e in payload.entries {
            guard let s = SCPJPSeries(rawValue: e.series), s.scpNumberRange.contains(e.scpNumber) else { continue }
            guard let oc = e.objectClass, !oc.isEmpty else { continue }
            out[e.mergeKey] = oc
        }
        return out
    }

    private static func buildTagsIndex(from payload: SCPListRemotePayload) -> [String: [String]] {
        var out: [String: [String]] = [:]
        for e in payload.entries {
            guard let s = SCPJPSeries(rawValue: e.series), s.scpNumberRange.contains(e.scpNumber) else { continue }
            guard !e.tags.isEmpty else { continue }
            out[e.mergeKey] = e.tags
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
        let oc = objectClassByMergeKey[key] ?? remote.objectClass
        let tags = tagsByMergeKey[key] ?? remote.tags
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
}
