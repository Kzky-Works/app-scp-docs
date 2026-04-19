import Foundation

/// Phase 13: 外部ホストの `scp_list.json` と同一スキーマ（GitHub Pages 等）。
struct SCPListRemotePayload: Codable, Sendable, Equatable {
    /// 一覧全体の版。Wikidot 側の更新に合わせて単調増加させる。
    var listVersion: Int
    /// スキーマ互換用。現在は `1` 固定。
    var schemaVersion: Int
    /// この JSON を生成した UTC 時刻。
    var generatedAt: Date
    /// タイトル差分（または全件）。`series` + `scpNumber` で一意。
    var entries: [SCPListRemoteEntry]
    /// `scp-international` から辿った国際支部和訳（`/scp-数字-2文字`、`-jp` 以外）。メイン 001〜4999-JP は `entries` 側。
    var hubLinkedPaths: [String]

    enum CodingKeys: String, CodingKey {
        case listVersion
        case schemaVersion
        case generatedAt
        case entries
        case hubLinkedPaths
    }

    init(
        listVersion: Int,
        schemaVersion: Int,
        generatedAt: Date,
        entries: [SCPListRemoteEntry],
        hubLinkedPaths: [String] = []
    ) {
        self.listVersion = listVersion
        self.schemaVersion = schemaVersion
        self.generatedAt = generatedAt
        self.entries = entries
        self.hubLinkedPaths = hubLinkedPaths
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        listVersion = try c.decode(Int.self, forKey: .listVersion)
        schemaVersion = try c.decode(Int.self, forKey: .schemaVersion)
        generatedAt = try c.decode(Date.self, forKey: .generatedAt)
        entries = try c.decode([SCPListRemoteEntry].self, forKey: .entries)
        hubLinkedPaths = try c.decodeIfPresent([String].self, forKey: .hubLinkedPaths) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(listVersion, forKey: .listVersion)
        try c.encode(schemaVersion, forKey: .schemaVersion)
        try c.encode(generatedAt, forKey: .generatedAt)
        try c.encode(entries, forKey: .entries)
        try c.encode(hubLinkedPaths, forKey: .hubLinkedPaths)
    }
}

struct SCPListRemoteEntry: Codable, Sendable, Hashable, Equatable {
    /// `SCPJPSeries.rawValue`（0 … 4）。
    var series: Int
    var scpNumber: Int
    /// `scp-series-jp` 一覧由来。日本支部オリジナル（`scp-NNN-jp`）アーカイヴの行タイトル用。
    var title: String
    /// `scp-series` / `scp-series-2` … 一覧由来。本家メインリスト和訳（`scp-NNN`）アーカイヴの行タイトル用。未設定時は UI はタイトル不明表示（`title` にはフォールバックしない）。
    var mainlistTranslationTitle: String?
    /// 記事または一覧行の最終更新（監査用。任意）。
    var lastModified: Date?
    /// Phase 14: オブジェクトクラス（例: Safe, Euclid）。`scp_list.json` 同期で任意。
    var objectClass: String?
    /// Phase 14: 付随タグ（和文タグ名など）。同期 JSON で任意。
    var tags: [String]

    enum CodingKeys: String, CodingKey {
        case series
        case scpNumber
        case title
        case mainlistTranslationTitle
        case lastModified
        case objectClass
        case tags
    }

    /// マージキー（`series_scpNumber`）。
    var mergeKey: String { "\(series)_\(scpNumber)" }

    init(
        series: Int,
        scpNumber: Int,
        title: String,
        mainlistTranslationTitle: String? = nil,
        lastModified: Date? = nil,
        objectClass: String? = nil,
        tags: [String] = []
    ) {
        self.series = series
        self.scpNumber = scpNumber
        self.title = title
        let mt = mainlistTranslationTitle?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.mainlistTranslationTitle = (mt?.isEmpty == false) ? mt : nil
        self.lastModified = lastModified
        let oc = objectClass?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.objectClass = (oc?.isEmpty == false) ? oc : nil
        self.tags = Self.normalizedTags(tags)
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        series = try c.decode(Int.self, forKey: .series)
        scpNumber = try c.decode(Int.self, forKey: .scpNumber)
        title = try c.decode(String.self, forKey: .title)
        if let raw = try c.decodeIfPresent(String.self, forKey: .mainlistTranslationTitle) {
            let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            mainlistTranslationTitle = t.isEmpty ? nil : t
        } else {
            mainlistTranslationTitle = nil
        }
        lastModified = try c.decodeIfPresent(Date.self, forKey: .lastModified)
        if let raw = try c.decodeIfPresent(String.self, forKey: .objectClass) {
            let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            objectClass = t.isEmpty ? nil : t
        } else {
            objectClass = nil
        }
        tags = Self.normalizedTags(try c.decodeIfPresent([String].self, forKey: .tags) ?? [])
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(series, forKey: .series)
        try c.encode(scpNumber, forKey: .scpNumber)
        try c.encode(title, forKey: .title)
        try c.encodeIfPresent(mainlistTranslationTitle, forKey: .mainlistTranslationTitle)
        try c.encodeIfPresent(lastModified, forKey: .lastModified)
        try c.encodeIfPresent(objectClass, forKey: .objectClass)
        if !tags.isEmpty {
            try c.encode(tags, forKey: .tags)
        }
    }

    private static func normalizedTags(_ raw: [String]) -> [String] {
        var seen = Set<String>()
        var out: [String] = []
        for s in raw {
            let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !t.isEmpty, !seen.contains(t) else { continue }
            seen.insert(t)
            out.append(t)
        }
        return out
    }
}
