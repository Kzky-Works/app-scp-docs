import Foundation

/// `list/jp/jp_tag.json`（`build_jp_wikidot_tag_article_map.py` 出力）と同じ形。
struct JPTagMapPayload: Codable, Sendable, Equatable {
    var source: String?
    var tagPageRange: [Int]?
    var tags: [String]?
    var articles: [String: [String]]
}
