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
    var title: String
    /// 記事または一覧行の最終更新（監査用。任意）。
    var lastModified: Date?

    /// マージキー（`series_scpNumber`）。
    var mergeKey: String { "\(series)_\(scpNumber)" }
}
