import Foundation

/// SCP-JP サイト上の Tales-JP ハブ URL。
enum FoundationTalesJPWikiSite {
    static let root = URL(string: "https://scp-jp.wikidot.com/")!
    static let foundationTalesJPPage = URL(string: "https://scp-jp.wikidot.com/foundation-tales-jp")!
}

/// `foundation-tales-jp` 一覧の 1 作（Wikidot 上のパスと表示タイトル）。
struct FoundationTalesJPTaleLink: Identifiable, Hashable, Sendable {
    /// 一覧内で安定するキー（著者インデックス + 行インデックスベース）。
    let id: String
    let title: String
    /// サイト相対パス（`/` で始まる）または絶対 URL。
    let href: String

    func resolvedURL(siteRoot: URL) -> URL? {
        let t = href.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.hasPrefix("http://") || t.hasPrefix("https://") {
            return URL(string: t)
        }
        if t.hasPrefix("//") {
            return URL(string: "https:\(t)")
        }
        var path = t.hasPrefix("/") ? String(t.dropFirst()) : t
        path = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? path
        return siteRoot.appendingPathComponent(path)
    }
}

/// 著者セクション（`foundation-tales-jp` の著者見出し＋直後の `wiki-content-table`）。
struct FoundationTalesJPAuthor: Identifiable, Hashable, Sendable {
    let id: String
    let displayName: String
    let tales: [FoundationTalesJPTaleLink]
}

/// 一覧下段の A–Z / 0–9 / その他 ピッカー。
enum TalesJPAlphabetSegment: Hashable, Sendable {
    case letter(Character)
    case digits
    case misc

    /// ウィキの著者見出し行に合わせ、先頭文字でバケツ分けする。
    static func bucket(forAuthorDisplayName name: String) -> TalesJPAlphabetSegment {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let first = trimmed.first,
              let scalar = first.unicodeScalars.first else {
            return .misc
        }
        let v = scalar.value
        if v >= 65, v <= 90 {
            return .letter(Character(UnicodeScalar(v)!))
        }
        if v >= 97, v <= 122 {
            return .letter(Character(UnicodeScalar(v - 32)!))
        }
        if v >= 48, v <= 57 {
            return .digits
        }
        return .misc
    }

    /// A, B, … Z, 0–9, その他（計 28）。
    static let orderedPickerSegments: [TalesJPAlphabetSegment] = {
        let letters = (65 ... 90).map { code in
            TalesJPAlphabetSegment.letter(Character(UnicodeScalar(code)!))
        }
        return letters + [.digits, .misc]
    }()

    var pickerAccessibilityToken: String {
        switch self {
        case .letter(let c):
            String(c)
        case .digits:
            "0-9"
        case .misc:
            "misc"
        }
    }
}
