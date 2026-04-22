import Foundation

/// data-scp-docs `docs/catalog/*.json`（`build_wikidot_category_catalogs.py` 出力）と同一スキーマ。
struct WikiCategoryCatalogPayload: Codable, Sendable, Equatable {
    var kind: String
    var schemaVersion: Int
    var listVersion: Int
    var generatedAt: Date
    var entries: [WikiCategoryCatalogEntry]
}

struct WikiCategoryCatalogEntry: Codable, Sendable, Hashable, Equatable {
    var series: Int?
    var scpNumber: Int?
    var slug: String
    var url: String
    var title: String?
    var objectClass: String?
    var tags: [String]
    var tagsSyncedAt: Date?

    enum CodingKeys: String, CodingKey {
        case series
        case scpNumber
        case slug
        case url
        case title
        case objectClass
        case tags
        case tagsSyncedAt
    }
}

/// GitHub Pages 上のファイル名とキャッシュキーの対応。
enum WikiCatalogKind: String, CaseIterable, Sendable {
    case scpJp
    case scpMainlist
    case joke
    case tales
    case canon
    case goi

    var fileName: String {
        switch self {
        case .scpJp: "scp_jp.json"
        case .scpMainlist: "scp.json"
        case .joke: "joke.json"
        case .tales: "tales.json"
        case .canon: "canon.json"
        case .goi: "goi.json"
        }
    }
}
