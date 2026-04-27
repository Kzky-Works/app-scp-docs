import Foundation

/// 報告書カタログ一覧行の 1 段目: SCP 番号（JP / 本家 / 国際 / ジョーク）。
enum TrifoldReportFeedRowFormatter: Sendable {
    // MARK: - 3 系統フィード（`SCPArticle`）

    /// カタログ内の「次の報告書」（主番号の昇順）に用いる比較用番号。
    static func catalogOrderingNumber(article: SCPArticle, feedKind: SCPArticleFeedKind) -> Int? {
        switch feedKind {
        case .jp: return scpNumberFromJapanSlug(article.i)
        case .en: return scpNumberFromMainSlug(article.i)
        case .int: return internationalPrimaryScpNumber(article)
        case .tales, .gois, .canons, .jokes: return nil
        }
    }

    /// 閲覧中 URL のパスから `catalogOrderingNumber` と同じ規則で主番号を取る（WebView の正規化差を吸収）。
    static func catalogOrderingNumber(from url: URL, feedKind: SCPArticleFeedKind) -> Int? {
        var s = url.lastPathComponent.lowercased()
        if let h = s.firstIndex(of: "#") {
            s = String(s[..<h])
        }
        guard !s.isEmpty else { return nil }
        switch feedKind {
        case .jp: return scpNumberFromJapanSlug(s)
        case .en: return scpNumberFromMainSlug(s)
        case .int: return intPrimaryScpNumberFromSlug(s)
        case .tales, .gois, .canons, .jokes: return nil
        }
    }

    static func scpNumberLine(article: SCPArticle, feedKind: SCPArticleFeedKind) -> String {
        let n: Int?
        switch feedKind {
        case .jp:
            n = scpNumberFromJapanSlug(article.i)
        case .en:
            n = scpNumberFromMainSlug(article.i)
        case .int:
            n = internationalPrimaryScpNumber(article)
        case .tales, .gois, .canons, .jokes:
            n = nil
        }
        if let n {
            return formattedScpNumberCore(n)
        }
        return fallbackTrifoldId(article.i)
    }

    // MARK: - ジョーク（`SCPGeneralContent`）

    /// ジョーク報告書の 1 段目。`scp-NNN-j` / `scp-NNN-jp-j` から `SCP-NNN-J` を生成。
    static func jokeScpNumberLine(entry: SCPGeneralContent) -> String {
        if let n = jokeScpNumber(entry: entry) {
            return "\(formattedScpNumberCore(n))-J"
        }
        return jokeFallbackSlug(entry)
    }

    // MARK: - Internals

    private static func formattedScpNumberCore(_ n: Int) -> String {
        let core = n < 1000 ? String(format: "%03d", n) : String(n)
        return "SCP-\(core)"
    }

    private static func fallbackTrifoldId(_ raw: String) -> String {
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? "SCP" : t
    }

    private static func jokeFallbackSlug(_ entry: SCPGeneralContent) -> String {
        if let s = entry.i?.trimmingCharacters(in: .whitespacesAndNewlines), !s.isEmpty {
            return s
        }
        let t = entry.u.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty, let url = URL(string: t) else { return "SCP-J" }
        let path = url.path
        if let last = path.split(separator: "/").filter({ !$0.isEmpty }).last {
            return String(last)
        }
        return "SCP-J"
    }

    private static func scpNumberFromJapanSlug(_ i: String) -> Int? {
        let lower = i.lowercased()
        guard lower.hasSuffix("-jp") else { return nil }
        let digits = lower.dropLast(3).dropFirst(4).filter(\.isNumber)
        guard !digits.isEmpty, let n = Int(String(digits)), n > 0, n <= 4999 else { return nil }
        return n
    }

    private static func scpNumberFromMainSlug(_ i: String) -> Int? {
        let lower = i.lowercased()
        guard lower.hasPrefix("scp-"), !lower.contains("-jp") else { return nil }
        let tail = String(lower.dropFirst(4))
        guard !tail.contains("-"), tail.allSatisfy(\.isNumber), let n = Int(tail), n > 0, n <= 4999 else { return nil }
        return n
    }

    private static func internationalPrimaryScpNumber(_ article: SCPArticle) -> Int? {
        intPrimaryScpNumberFromSlug(listSlug(from: article))
    }

    private static func listSlug(from article: SCPArticle) -> String {
        if let url = article.resolvedURL {
            var s = url.lastPathComponent.lowercased()
            if let h = s.firstIndex(of: "#") {
                s = String(s[..<h])
            }
            if s.hasPrefix("scp-") {
                return s
            }
        }
        return article.i.lowercased()
    }

    /// `scp-NNN-ru` / `scp-cn-NNN` 等: 国際支部カタログの主番号。
    private static func intPrimaryScpNumberFromSlug(_ raw: String) -> Int? {
        var s = raw.lowercased()
        if let h = s.firstIndex(of: "#") {
            s = String(s[..<h])
        }
        guard s.hasPrefix("scp-") else { return nil }
        let body = String(s.dropFirst(4))
        let parts = body.split(separator: "-").map(String.init)
        guard !parts.isEmpty else { return nil }
        if parts[0].allSatisfy(\.isNumber), let n = Int(parts[0]), n > 0, n <= 999_999 {
            return n
        }
        if parts.count >= 2, parts[1].allSatisfy(\.isNumber), let n = Int(parts[1]), n > 0, n <= 999_999 {
            return n
        }
        return nil
    }

    private static func jokeScpNumber(entry: SCPGeneralContent) -> Int? {
        let slug: String
        if let s = entry.i, !s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            slug = s
        } else {
            let t = entry.u.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !t.isEmpty, let url = URL(string: t) else { return nil }
            let p = url.path.split(separator: "/").map(String.init).filter { !$0.isEmpty }
            slug = p.last ?? ""
        }
        return jokeNumberFromSlug(slug)
    }

    private static func jokeNumberFromSlug(_ slug: String) -> Int? {
        let lower = slug.lowercased()
        guard lower.hasPrefix("scp-") else { return nil }
        let rest = String(lower.dropFirst(4))
        var numDigits = ""
        for ch in rest {
            if ch.isNumber {
                numDigits.append(ch)
            } else {
                break
            }
        }
        guard !numDigits.isEmpty, let n = Int(numDigits), n > 0 else { return nil }
        return n
    }
}
