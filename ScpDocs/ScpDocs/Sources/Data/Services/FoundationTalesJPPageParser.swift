import Foundation

/// `foundation-tales-jp` の HTML から著者見出しと `wiki-content-table` を抽出する。
enum FoundationTalesJPPageParser: Sendable {
    private static let authorTableOpen = "<table style=\"width: 100%;margin-top:1.2em\">"
    private static let wikiTableOpen = "<table class=\"wiki-content-table\">"
    private static let userLinkPattern: NSRegularExpression = {
        let pattern = #"<a href="https?://www\.wikidot\.com/user:info/[^"]+"[^>]*>([^<]*)</a>"#
        return try! NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
    }()

    private static let errorEmPattern: NSRegularExpression = {
        let pattern = #"<span class="error-inline"[^>]*>.*?<em>([^<]+)</em>"#
        return try! NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
    }()

    private static let taleRowPattern: NSRegularExpression = {
        let pattern = #"<td><a href="([^"]+)">([^<]*)</a></td>"#
        return try! NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
    }()

    static func parseAuthors(html: String) -> [FoundationTalesJPAuthor] {
        var authors: [FoundationTalesJPAuthor] = []
        var scan = html.startIndex ..< html.endIndex
        var ordinal = 0

        while let blockStart = html.range(of: authorTableOpen, range: scan) {
            let innerBegin = blockStart.upperBound
            guard let authorTableEnd = html.range(of: "</table>", range: innerBegin ..< html.endIndex) else {
                break
            }
            let authorInner = String(html[innerBegin ..< authorTableEnd.lowerBound])

            guard let displayName = extractAuthorName(fromAuthorTableHTML: authorInner) else {
                scan = authorTableEnd.upperBound ..< html.endIndex
                continue
            }

            let tailStart = authorTableEnd.upperBound
            let nextAuthorLower = html.range(of: authorTableOpen, range: tailStart ..< html.endIndex)?.lowerBound ?? html.endIndex
            let tailSlice = html[tailStart ..< nextAuthorLower]

            let tales: [FoundationTalesJPTaleLink]
            if let wikiOpen = tailSlice.range(of: wikiTableOpen),
               let wikiClose = tailSlice.range(of: "</table>", range: wikiOpen.upperBound ..< tailSlice.endIndex) {
                let wikiBody = tailSlice[wikiOpen.upperBound ..< wikiClose.lowerBound]
                tales = extractTales(fromWikiTableHTML: String(wikiBody), authorOrdinal: ordinal)
            } else {
                tales = []
            }

            ordinal += 1
            let authorId = "foundation-tales-jp-author-\(ordinal)-\(stableHash(displayName))"
            authors.append(
                FoundationTalesJPAuthor(
                    id: authorId,
                    displayName: displayName,
                    tales: tales
                )
            )

            scan = nextAuthorLower ..< html.endIndex
        }

        return authors
    }

    private static func extractAuthorName(fromAuthorTableHTML fragment: String) -> String? {
        if let emRange = fragment.range(of: "<span class=\"error-inline\"") {
            let tail = String(fragment[emRange.lowerBound...])
            let ns = tail as NSString
            if let m = errorEmPattern.firstMatch(in: tail, options: [], range: NSRange(location: 0, length: ns.length)),
               m.numberOfRanges >= 2 {
                let r = m.range(at: 1)
                if r.location != NSNotFound {
                    let s = ns.substring(with: r).trimmingCharacters(in: .whitespacesAndNewlines)
                    if !s.isEmpty { return s }
                }
            }
        }

        let ns = fragment as NSString
        let full = NSRange(location: 0, length: ns.length)
        var lastNonEmpty: String?
        userLinkPattern.enumerateMatches(in: fragment, options: [], range: full) { match, _, _ in
            guard let match, match.numberOfRanges >= 2 else { return }
            let r = match.range(at: 1)
            if r.location == NSNotFound { return }
            let text = ns.substring(with: r).trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty {
                lastNonEmpty = text
            }
        }
        return lastNonEmpty
    }

    private static func extractTales(fromWikiTableHTML fragment: String, authorOrdinal: Int) -> [FoundationTalesJPTaleLink] {
        let ns = fragment as NSString
        let full = NSRange(location: 0, length: ns.length)
        var rows: [FoundationTalesJPTaleLink] = []
        var rowIndex = 0
        taleRowPattern.enumerateMatches(in: fragment, options: [], range: full) { match, _, _ in
            guard let match, match.numberOfRanges >= 3 else { return }
            let hrefR = match.range(at: 1)
            let titleR = match.range(at: 2)
            if hrefR.location == NSNotFound || titleR.location == NSNotFound { return }
            let href = ns.substring(with: hrefR).trimmingCharacters(in: .whitespacesAndNewlines)
            let title = ns.substring(with: titleR)
                .replacingOccurrences(of: "&amp;", with: "&")
                .replacingOccurrences(of: "&lt;", with: "<")
                .replacingOccurrences(of: "&gt;", with: ">")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if href.isEmpty { return }
            let id = "tale-\(authorOrdinal)-\(rowIndex)-\(href)"
            rows.append(FoundationTalesJPTaleLink(id: id, title: title.isEmpty ? href : title, href: href))
            rowIndex += 1
        }
        return rows
    }

    private static func stableHash(_ s: String) -> UInt64 {
        var h: UInt64 = 14_695_981_039_346_656_037
        for u in s.utf8 {
            h ^= UInt64(u)
            h &*= 1_099_511_628_211
        }
        return h
    }
}
