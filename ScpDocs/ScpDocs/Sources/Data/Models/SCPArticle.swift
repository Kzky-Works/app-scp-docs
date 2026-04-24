import Foundation

// MARK: - Manifest (schema 2) DTO

/// `manifest_*.json` の `metadata[i]` 断片。
struct SCPArticleManifestMetadata: Codable, Sendable, Equatable {
    var c: String?
    var o: String?
    var g: [String]?
}

private struct SCPArticleLightEntryDTO: Codable, Sendable {
    let u: String
    let i: String
    let t: String
}

/// 3 系統 SCP 報告書 JSON ＋ Tale / GoI / Canon / Joke マルチフォーム一覧の識別子（キャッシュキー・URL 解決に使用）。
enum SCPArticleFeedKind: String, Codable, CaseIterable, Sendable {
    case jp
    case en
    case int
    case tales
    case gois
    case canons
    case jokes

    /// ホーム Split Hero・未読集計など「報告書カタログ」のみ。
    static let trifoldReportCases: [SCPArticleFeedKind] = [.jp, .en, .int]

    var isTrifoldSCPReportFeed: Bool {
        switch self {
        case .jp, .en, .int: true
        case .tales, .gois, .canons, .jokes: false
        }
    }

    var isMultiformArchiveFeed: Bool {
        switch self {
        case .tales, .gois, .canons, .jokes: true
        case .jp, .en, .int: false
        }
    }
}

/// 3 系統 JSON（支部別 `list/<code>/scp-*.json`）の 1 エントリ。キーは配信パイプラインの短縮形。
struct SCPArticle: Codable, Sendable, Hashable, Equatable {
    /// 記事 URL（絶対 URL 文字列）。
    var u: String
    /// 安定識別子（Wikidot ページ ID やスラッグなど、配信側の定義に従う）。
    var i: String
    /// 表示タイトル。
    var t: String
    /// オブジェクトクラス等の分類（任意）。
    var c: String?
    /// 出典・系列など（任意）。
    var o: String?
    /// タグ。
    var g: [String]

    enum CodingKeys: String, CodingKey {
        case u
        case i
        case t
        case c
        case o
        case g
    }

    init(u: String, i: String, t: String, c: String? = nil, o: String? = nil, g: [String] = []) {
        self.u = u
        self.i = i
        self.t = t
        self.c = Self.trimmedOptional(c)
        self.o = Self.trimmedOptional(o)
        self.g = Self.normalizedTags(g)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        u = try container.decode(String.self, forKey: .u)
        i = try container.decode(String.self, forKey: .i)
        t = try container.decode(String.self, forKey: .t)
        c = Self.trimmedOptional(try container.decodeIfPresent(String.self, forKey: .c))
        o = Self.trimmedOptional(try container.decodeIfPresent(String.self, forKey: .o))
        g = Self.normalizedTags(try container.decodeIfPresent([String].self, forKey: .g) ?? [])
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(u, forKey: .u)
        try container.encode(i, forKey: .i)
        try container.encode(t, forKey: .t)
        try container.encodeIfPresent(c, forKey: .c)
        try container.encodeIfPresent(o, forKey: .o)
        if !g.isEmpty {
            try container.encode(g, forKey: .g)
        }
    }

    /// `ArticleRepository.storageKey(for:)` と一致させるための正規化 URL。
    var resolvedURL: URL? {
        let trimmed = u.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return URL(string: trimmed)
    }

    private static func trimmedOptional(_ raw: String?) -> String? {
        guard let raw else { return nil }
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? nil : t
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

/// 各 `manifest_scp-*.json` / 従来 `scp-*.json` のラッパー。`listVersion` で増分取得の足場とする。
struct SCPArticleListPayload: Codable, Sendable, Equatable {
    var listVersion: Int
    /// 常に `AppRemoteConfig.scpArticleFeedSchemaVersion`（1）へ正規化してキャッシュする。
    var schemaVersion: Int
    var generatedAt: Date
    var entries: [SCPArticle]

    enum CodingKeys: String, CodingKey {
        case listVersion
        case schemaVersion
        case generatedAt
        case entries
        case metadata
    }

    init(listVersion: Int, schemaVersion: Int, generatedAt: Date, entries: [SCPArticle]) {
        self.listVersion = listVersion
        self.schemaVersion = schemaVersion
        self.generatedAt = generatedAt
        self.entries = entries
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        listVersion = try c.decode(Int.self, forKey: .listVersion)
        let rawSchema = try c.decode(Int.self, forKey: .schemaVersion)
        generatedAt = try c.decode(Date.self, forKey: .generatedAt)
        if rawSchema >= 2 {
            let lights = try c.decode([SCPArticleLightEntryDTO].self, forKey: .entries)
            let meta = try c.decodeIfPresent([String: SCPArticleManifestMetadata].self, forKey: .metadata) ?? [:]
            entries = lights.map { lite in
                let m = meta[lite.i]
                return SCPArticle(
                    u: lite.u,
                    i: lite.i,
                    t: lite.t,
                    c: m?.c,
                    o: m?.o,
                    g: m?.g ?? []
                )
            }
            schemaVersion = AppRemoteConfig.scpArticleFeedSchemaVersion
        } else {
            schemaVersion = rawSchema
            entries = try c.decode([SCPArticle].self, forKey: .entries)
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(listVersion, forKey: .listVersion)
        try c.encode(schemaVersion, forKey: .schemaVersion)
        try c.encode(generatedAt, forKey: .generatedAt)
        try c.encode(entries, forKey: .entries)
    }
}
