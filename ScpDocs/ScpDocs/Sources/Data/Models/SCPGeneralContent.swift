import Foundation

// MARK: - Manifest (schema 2) DTO

struct SCPGeneralContentManifestMetadata: Codable, Sendable, Equatable {
    var a: String?
    var o: String?
    var g: [String]?
    /// GoI 等: 出典分類。ハーベストで `jp` / `en` / `other` 等を格納想定（未設定時はピッカー全タブに表示）。
    var r: String?
}

private struct SCPGeneralContentLightEntryDTO: Codable, Sendable {
    let u: String
    let i: String
    let t: String
}

// MARK: - GoI manifest (schema 3) — `goi-formats-jp` 階層

/// 団体下の 1 フォーマット文書行（`goiRegions.*[].entries`）。
struct GoIFormatArticleLine: Codable, Sendable, Hashable, Equatable, Identifiable {
    var u: String
    var i: String
    var t: String

    var id: String { i }
}

/// 1 要注意団体（`h2` 相当）+ 子記事。
struct GoIFormatGroupPayload: Codable, Sendable, Hashable, Equatable, Identifiable {
    var i: String
    var t: String
    var u: String?
    var entries: [GoIFormatArticleLine]

    var id: String { i }
}

/// `en` / `jp` / `other`（`要注意団体-CN` 等はすべて other に束ねる）
struct GoIRegionsLayoutPayload: Codable, Sendable, Hashable, Equatable {
    var en: [GoIFormatGroupPayload]
    var jp: [GoIFormatGroupPayload]
    var other: [GoIFormatGroupPayload]
}

/// カノンハブ索引（`canon-hub-jp` / `canon-hub` の `div.canon-title` 由来）。行は GoI の子記事と同形。
struct CanonRegionsLayoutPayload: Codable, Sendable, Hashable, Equatable {
    var jp: [GoIFormatArticleLine]
    var en: [GoIFormatArticleLine]
}

/// 非ナンバリング記事（Tale / GoI / Canon / Joke）の 1 エントリ。配信 JSON の短縮キーに合わせる。
struct SCPGeneralContent: Codable, Sendable, Hashable, Equatable {
    /// 記事 URL（絶対 URL 文字列）。
    var u: String
    /// 表示タイトル。
    var t: String
    /// 著者（任意）。
    var a: String?
    /// 出典・系列など（任意）。
    var o: String?
    /// タグ。
    var g: [String]
    /// 安定識別子（マニフェスト `entries[].i`）。従来 JSON では省略可。
    var i: String?
    /// 出典・系列タブ用（主に GoI）。`metadata[].r` またはフラット `r`。
    var r: String?

    enum CodingKeys: String, CodingKey {
        case u
        case t
        case a
        case o
        case g
        case i
        case r
    }

    init(u: String, t: String, a: String? = nil, o: String? = nil, g: [String] = [], i: String? = nil, r: String? = nil) {
        self.u = u
        self.t = t
        self.a = Self.trimmedOptional(a)
        self.o = Self.trimmedOptional(o)
        self.g = Self.normalizedTags(g)
        self.i = Self.trimmedOptional(i)
        self.r = Self.trimmedOptional(r)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        u = try container.decode(String.self, forKey: .u)
        t = try container.decode(String.self, forKey: .t)
        a = Self.trimmedOptional(try container.decodeIfPresent(String.self, forKey: .a))
        o = Self.trimmedOptional(try container.decodeIfPresent(String.self, forKey: .o))
        g = Self.normalizedTags(try container.decodeIfPresent([String].self, forKey: .g) ?? [])
        i = Self.trimmedOptional(try container.decodeIfPresent(String.self, forKey: .i))
        r = Self.trimmedOptional(try container.decodeIfPresent(String.self, forKey: .r))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(u, forKey: .u)
        try container.encode(t, forKey: .t)
        try container.encodeIfPresent(a, forKey: .a)
        try container.encodeIfPresent(o, forKey: .o)
        if !g.isEmpty {
            try container.encode(g, forKey: .g)
        }
        try container.encodeIfPresent(i, forKey: .i)
        try container.encodeIfPresent(r, forKey: .r)
    }

    /// `ArticleRepository.storageKey(for:)` と一致させるための正規化 URL。
    var resolvedURL: URL? {
        let trimmed = u.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return URL(string: trimmed)
    }

    /// リスト表示用。欠損時は空ではなく呼び出し側でローカライズされた UNKNOWN を差し込む。
    var trimmedAuthor: String? {
        guard let a, !a.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        return a.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func trimmedOptional(_ raw: String?) -> String? {
        guard let raw else { return nil }
        let s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return s.isEmpty ? nil : s
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

/// `manifest_tales.json` 等 / 従来フラット JSON のラッパー。増分取得に対応。
struct SCPGeneralContentListPayload: Codable, Sendable, Equatable {
    var listVersion: Int
    /// 常に `AppRemoteConfig.scpGeneralContentFeedSchemaVersion`（1）へ正規化してキャッシュする。
    var schemaVersion: Int
    var generatedAt: Date
    var entries: [SCPGeneralContent]
    /// ネット上の `manifest_gois.json` schema 3 時のみ（団体階層）。キャッシュにも保存。
    var goiRegions: GoIRegionsLayoutPayload?
    /// `manifest_canons.json` のカノンハブ JP/EN 索引。
    var canonRegions: CanonRegionsLayoutPayload?

    enum CodingKeys: String, CodingKey {
        case listVersion
        case schemaVersion
        case generatedAt
        case entries
        case metadata
        case goiRegions
        case canonRegions
    }

    init(
        listVersion: Int,
        schemaVersion: Int,
        generatedAt: Date,
        entries: [SCPGeneralContent],
        goiRegions: GoIRegionsLayoutPayload? = nil,
        canonRegions: CanonRegionsLayoutPayload? = nil
    ) {
        self.listVersion = listVersion
        self.schemaVersion = schemaVersion
        self.generatedAt = generatedAt
        self.entries = entries
        self.goiRegions = goiRegions
        self.canonRegions = canonRegions
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        listVersion = try c.decode(Int.self, forKey: .listVersion)
        let rawSchema = try c.decode(Int.self, forKey: .schemaVersion)
        generatedAt = try c.decode(Date.self, forKey: .generatedAt)
        goiRegions = try c.decodeIfPresent(GoIRegionsLayoutPayload.self, forKey: .goiRegions)
        canonRegions = try c.decodeIfPresent(CanonRegionsLayoutPayload.self, forKey: .canonRegions)
        if rawSchema >= 2 {
            let lights = try c.decode([SCPGeneralContentLightEntryDTO].self, forKey: .entries)
            let meta = try c.decodeIfPresent([String: SCPGeneralContentManifestMetadata].self, forKey: .metadata) ?? [:]
            entries = lights.map { lite in
                let m = meta[lite.i]
                return SCPGeneralContent(
                    u: lite.u,
                    t: lite.t,
                    a: m?.a,
                    o: m?.o,
                    g: m?.g ?? [],
                    i: lite.i,
                    r: m?.r
                )
            }
            schemaVersion = AppRemoteConfig.scpGeneralContentFeedSchemaVersion
        } else {
            schemaVersion = rawSchema
            entries = try c.decode([SCPGeneralContent].self, forKey: .entries)
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(listVersion, forKey: .listVersion)
        try c.encode(schemaVersion, forKey: .schemaVersion)
        try c.encode(generatedAt, forKey: .generatedAt)
        try c.encode(entries, forKey: .entries)
        try c.encodeIfPresent(goiRegions, forKey: .goiRegions)
        try c.encodeIfPresent(canonRegions, forKey: .canonRegions)
    }
}
