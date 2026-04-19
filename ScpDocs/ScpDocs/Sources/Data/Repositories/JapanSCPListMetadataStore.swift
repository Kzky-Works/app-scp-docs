import Foundation
import Observation

/// Phase 13: リモート同期タイトルと埋め込み `JapanSCPArchiveTitleData` を統合する参照ストア。
@Observable
@MainActor
final class JapanSCPListMetadataStore {
    private let cacheRepository: SCPListCacheRepository
    private var titleByMergeKey: [String: String] = [:]
    private var objectClassByMergeKey: [String: String] = [:]
    private var tagsByMergeKey: [String: [String]] = [:]
    /// ホーム「ランダムな報告書」用: 公式和訳プール（`entries` の JP 番号記事 + `hubLinkedPaths`）。
    private(set) var officialJapaneseTranslationRandomPool: [URL] = []

    init(cacheRepository: SCPListCacheRepository) {
        self.cacheRepository = cacheRepository
        reloadFromCache()
    }

    func reloadFromCache() {
        guard let payload = cacheRepository.loadPersistedPayload() else {
            titleByMergeKey = [:]
            objectClassByMergeKey = [:]
            tagsByMergeKey = [:]
            officialJapaneseTranslationRandomPool = []
            return
        }
        titleByMergeKey = Self.buildTitleIndex(from: payload)
        objectClassByMergeKey = Self.buildObjectClassIndex(from: payload)
        tagsByMergeKey = Self.buildTagsIndex(from: payload)
        officialJapaneseTranslationRandomPool = Self.buildOfficialJapaneseTranslationRandomPool(from: payload)
    }

    /// 日本支部向け: 同期済み一覧から公式和訳 URL を 1 件ランダムに選ぶ。プールが空のときは `nil`。
    func randomOfficialJapaneseTranslationURL() -> URL? {
        officialJapaneseTranslationRandomPool.randomElement()
    }

    /// リモート → 埋め込みの順で解決。どちらも無ければ `nil`（UI は `[DATA UNKNOWN]`）。
    func resolvedArticleTitle(scpNumber: Int, series: SCPJPSeries) -> String? {
        let key = Self.mergeKey(series: series, scpNumber: scpNumber)
        if let remote = titleByMergeKey[key], !remote.isEmpty {
            return remote
        }
        return JapanSCPArchiveTitleData.title(scpNumber: scpNumber, series: series)
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
            let injected = resolvedArticleTitle(scpNumber: n, series: series)
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

    /// 本家メインリストの日本語訳（`scp-jp.wikidot.com/scp-series` 系）の一覧。タイトル解決は JP アーカイヴと同一キー。
    func englishMainlistTranslationArchiveEntries(series: SCPJPSeries, segmentStart: Int) -> [JapanSCPArchiveEntry] {
        series.numbersInSegment(segmentStart: segmentStart).map { n in
            let url = series.englishMainlistTranslationArticleURL(scpNumber: n)
            let slug: String
            if n < 1000 {
                slug = String(format: "scp-%03d", n)
            } else {
                slug = "scp-\(n)"
            }
            let injected = resolvedArticleTitle(scpNumber: n, series: series)
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

    private static func buildTitleIndex(from payload: SCPListRemotePayload) -> [String: String] {
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
            let url = series.articleURL(scpNumber: e.scpNumber)
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
}
