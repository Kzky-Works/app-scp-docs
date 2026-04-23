import Foundation

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

    enum CodingKeys: String, CodingKey {
        case u
        case t
        case a
        case o
        case g
    }

    init(u: String, t: String, a: String? = nil, o: String? = nil, g: [String] = []) {
        self.u = u
        self.t = t
        self.a = Self.trimmedOptional(a)
        self.o = Self.trimmedOptional(o)
        self.g = Self.normalizedTags(g)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        u = try container.decode(String.self, forKey: .u)
        t = try container.decode(String.self, forKey: .t)
        a = Self.trimmedOptional(try container.decodeIfPresent(String.self, forKey: .a))
        o = Self.trimmedOptional(try container.decodeIfPresent(String.self, forKey: .o))
        g = Self.normalizedTags(try container.decodeIfPresent([String].self, forKey: .g) ?? [])
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

/// `tales.json` / `gois.json` 等のラッパー。`SCPArticleListPayload` と同形のメタで増分取得に対応。
struct SCPGeneralContentListPayload: Codable, Sendable, Equatable {
    var listVersion: Int
    var schemaVersion: Int
    var generatedAt: Date
    var entries: [SCPGeneralContent]

    enum CodingKeys: String, CodingKey {
        case listVersion
        case schemaVersion
        case generatedAt
        case entries
    }

    init(listVersion: Int, schemaVersion: Int, generatedAt: Date, entries: [SCPGeneralContent]) {
        self.listVersion = listVersion
        self.schemaVersion = schemaVersion
        self.generatedAt = generatedAt
        self.entries = entries
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        listVersion = try c.decode(Int.self, forKey: .listVersion)
        schemaVersion = try c.decode(Int.self, forKey: .schemaVersion)
        generatedAt = try c.decode(Date.self, forKey: .generatedAt)
        entries = try c.decode([SCPGeneralContent].self, forKey: .entries)
    }
}
