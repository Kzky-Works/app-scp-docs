import Foundation

/// ホーム「続きから読む」3 行テキスト + 進捗ゲージの表示用（SwiftUI 以外の純データ）。
struct ContinueReadingRowDisplay: Sendable, Equatable {
    /// 一行目: カテゴリ（`SCP-JP` / `Tales` 等、`LocalizationKey` 経由）。
    let categoryLine: String
    /// 二行目: タイトル（JSON `t` を優先）。
    let titleLine: String
    /// 三行目: SCP 番号等の識別子（スラッグ・リスト由来）。
    let line3Identifier: String
    /// 三行目: カタログ等から取れたオブジェクトクラス。無い場合は `nil`（識別子のみ表示）。
    let line3ObjectClass: String?
    /// 四行目: 0...1 のスクロール進捗（ゲージ）。
    let scrollProgress: Double
    /// 右サムネイル用（任意）。
    let thumbnailURL: URL?
}

/// `URL` と補助情報から「続きから読む」の各行を組み立てる。
enum ContinueReadingSummaryBuilder {
    static func build(
        url: URL,
        scrollProgress: Double,
        cachedPageTitle: String?,
        thumbnailURL: URL?,
        japanListHint: JapanSCPListReadingHint?,
        listMetaTitle: String?,
        listMetaObjectClass: String?,
        localize: (String) -> String
    ) -> ContinueReadingRowDisplay {
        let slug = url.path.split(separator: "/").last.map(String.init) ?? ""
        let host = url.host?.lowercased() ?? ""

        let classification = classify(host: host, slug: slug, url: url, japanListHint: japanListHint)

        let scpOrIdentifier = resolveScpOrIdentifierLine(
            classification: classification,
            slug: slug,
            cachedPageTitle: cachedPageTitle,
            japanListHint: japanListHint
        )
        let title = resolveMetaTitle(
            listMetaTitle: listMetaTitle,
            classification: classification,
            slug: slug,
            cachedPageTitle: cachedPageTitle,
            japanListHint: japanListHint
        )
        let resolvedObjectClass = normalizedNonEmpty(listMetaObjectClass) ?? normalizedNonEmpty(japanListHint?.objectClass)
        return ContinueReadingRowDisplay(
            categoryLine: localize(categoryLocalizationKey(classification: classification, host: host)),
            titleLine: title,
            line3Identifier: scpOrIdentifier,
            line3ObjectClass: resolvedObjectClass,
            scrollProgress: min(1, max(0, scrollProgress)),
            thumbnailURL: thumbnailURL
        )
    }

    private static func normalizedNonEmpty(_ raw: String?) -> String? {
        guard let t = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !t.isEmpty else { return nil }
        return t
    }

    private static func categoryLocalizationKey(classification: Classification, host: String) -> String {
        switch classification {
        case .scpJapanOriginal, .scpJapanMainlistTranslation:
            return LocalizationKey.homeContinueCategoryScpJp
        case .scpJapanJoke:
            return LocalizationKey.homeContinueCategoryJoke
        case .scpEnglishMain:
            return LocalizationKey.homeContinueBranchScp
        case .scpEnglishJoke:
            return LocalizationKey.homeContinueCategoryJoke
        case .scpInternationalMain:
            return LocalizationKey.homeContinueCategoryScpInternational
        case .tale:
            return LocalizationKey.homeContinueCategoryTales
        case .canon:
            return LocalizationKey.homeContinueCategoryCanon
        case .goi:
            return LocalizationKey.homeContinueCategoryGoi
        case .other:
            if host == "scp-kr.wikidot.com" { return LocalizationKey.homeContinueBranchScpKo }
            return LocalizationKey.homeContinueCategoryOther
        }
    }

    // MARK: - Tale 用（タイトル確定後に著者を切り出す）

    static func taleIdentifierLine(cachedPageTitle: String?, slug: String) -> String {
        if let author = extractTaleAuthor(from: cachedPageTitle), !author.isEmpty {
            return author
        }
        return humanizedSlug(slug)
    }

    static func taleTitleLine(cachedPageTitle: String?, slug: String) -> String {
        guard let raw = cachedPageTitle?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else {
            return humanizedSlug(slug)
        }
        if let author = extractTaleAuthor(from: raw), !author.isEmpty {
            if let r = raw.range(of: author, options: .caseInsensitive) {
                var stripped = raw.replacingCharacters(in: r, with: "")
                stripped = stripped
                    .replacingOccurrences(of: "  ", with: " ")
                    .replacingOccurrences(of: " - ", with: " ")
                    .replacingOccurrences(of: " — ", with: " ")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                if stripped.isEmpty { return humanizedSlug(slug) }
                return stripped
            }
            let lowered = raw.lowercased()
            let authorLower = author.lowercased()
            if let range = lowered.range(of: "by \(authorLower)") {
                let idx = range.lowerBound
                let stripped = String(raw[..<idx]).trimmingCharacters(in: .whitespacesAndNewlines)
                if stripped.isEmpty { return humanizedSlug(slug) }
                return stripped
            }
        }
        return raw
    }

    // MARK: - Private

    private enum Classification: Equatable {
        case scpJapanOriginal
        case scpJapanMainlistTranslation
        case scpJapanJoke
        case scpEnglishMain
        case scpEnglishJoke
        case scpInternationalMain
        case tale
        case canon
        case goi
        case other
    }

    private static func classify(
        host: String,
        slug: String,
        url: URL,
        japanListHint: JapanSCPListReadingHint?
    ) -> Classification {
        if let japanListHint {
            switch japanListHint.flavor {
            case .jpOriginal: return .scpJapanOriginal
            case .mainlistTranslation: return .scpJapanMainlistTranslation
            case .jokeJp: return .scpJapanJoke
            }
        }

        if host == "scp-wiki.wikidot.com" {
            let s = slug.lowercased()
            if s.hasPrefix("scp-"), s.hasSuffix("-j"), !s.hasSuffix("-jp") {
                let mid = s.dropFirst(4).dropLast(2).filter(\.isNumber)
                if !mid.isEmpty, Int(String(mid)) != nil {
                    return .scpEnglishJoke
                }
            }
            if s.hasPrefix("scp-") {
                let core = s.dropFirst(4)
                let digits: Substring
                if core.hasSuffix("-jp") {
                    digits = core.dropLast(3).filter(\.isNumber)
                } else {
                    digits = core.filter(\.isNumber)
                }
                if !digits.isEmpty, Int(String(digits)) != nil {
                    return .scpEnglishMain
                }
            }
        }

        if host == "scp-jp.wikidot.com" {
            if url.absoluteString.localizedCaseInsensitiveContains("foundation-tales") {
                return .tale
            }
            if url.path.localizedCaseInsensitiveContains("canon-hub") || slug.localizedCaseInsensitiveContains("canon") {
                return .canon
            }
            if url.path.localizedCaseInsensitiveContains("groups-of-interest") {
                return .goi
            }
        }

        if host == "scp-wiki.wikidot.com", url.path.localizedCaseInsensitiveContains("foundation-tales") {
            return .tale
        }
        if host == "scp-wiki.wikidot.com", url.path.localizedCaseInsensitiveContains("canon-hub") {
            return .canon
        }
        if host == "scp-wiki.wikidot.com", url.path.localizedCaseInsensitiveContains("groups-of-interest") {
            return .goi
        }

        if host == "scp-int.wikidot.com" {
            if url.path.localizedCaseInsensitiveContains("groups-of-interest") {
                return .goi
            }
            let s = slug.lowercased()
            if s.hasPrefix("scp-") {
                let rest = s.dropFirst(4)
                if rest.contains(where: \.isNumber) {
                    return .scpInternationalMain
                }
            }
        }

        let ls = slug.lowercased()
        if ls.hasPrefix("scp-") {
            let rest = ls.dropFirst(4)
            if rest.contains(where: \.isNumber) {
                return .scpEnglishMain
            }
        }

        return .other
    }

    /// 三行目: 報告書番号表記。Tale / Canon 等の専用レイアウトは別途指示可。
    private static func resolveScpOrIdentifierLine(
        classification: Classification,
        slug: String,
        cachedPageTitle: String?,
        japanListHint: JapanSCPListReadingHint?
    ) -> String {
        if let japanListHint {
            return scpNumberLikeDisplayIfApplicable(japanListHint.displaySlug)
        }
        switch classification {
        case .tale:
            return humanizedSlug(slug)
        case .scpEnglishMain, .scpEnglishJoke, .scpInternationalMain:
            return scpSlugDisplay(slug)
        case .canon, .goi, .other:
            return humanizedSlug(slug)
        default:
            if slug.lowercased().hasPrefix("scp-") { return scpSlugDisplay(slug) }
            return humanizedSlug(slug)
        }
    }

    private static func scpNumberLikeDisplayIfApplicable(_ s: String) -> String {
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.lowercased().hasPrefix("scp-") { return scpSlugDisplay(t) }
        return t
    }

    private static func resolveMetaTitle(
        listMetaTitle: String?,
        classification: Classification,
        slug: String,
        cachedPageTitle: String?,
        japanListHint: JapanSCPListReadingHint?
    ) -> String {
        if let m = listMetaTitle?.trimmingCharacters(in: .whitespacesAndNewlines), !m.isEmpty {
            return m
        }
        if let t = cachedPageTitle?.trimmingCharacters(in: .whitespacesAndNewlines), !t.isEmpty {
            if classification == .tale {
                return taleTitleLine(cachedPageTitle: t, slug: slug)
            }
            return t
        }
        if let lt = japanListHint?.resolvedListTitle?.trimmingCharacters(in: .whitespacesAndNewlines), !lt.isEmpty {
            return lt
        }
        if classification == .tale {
            return taleTitleLine(cachedPageTitle: nil, slug: slug)
        }
        return humanizedSlug(slug)
    }

    private static func scpSlugDisplay(_ slug: String) -> String {
        if slug.lowercased().hasPrefix("scp-") {
            return slug.uppercased(with: Locale(identifier: "en"))
        }
        return humanizedSlug(slug)
    }

    private static func extractTaleAuthor(from title: String?) -> String? {
        guard let title, !title.isEmpty else { return nil }
        if let r = title.range(of: #"著[:：]\s*(.+)$"#, options: .regularExpression) {
            let slice = String(title[r])
            return slice.replacingOccurrences(of: #"^著[:：]\s*"#, with: "", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let r = title.range(of: #"作者[:：]\s*(.+)$"#, options: .regularExpression) {
            let slice = String(title[r])
            return slice.replacingOccurrences(of: #"^作者[:：]\s*"#, with: "", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let r = title.range(of: #"\bby\s+(.+)$"#, options: [.regularExpression, .caseInsensitive]) {
            let tail = String(title[r])
            if let m = tail.range(of: #"\bby\s+"#, options: .caseInsensitive) {
                return String(tail[m.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return nil
    }

    private static func humanizedSlug(_ slug: String) -> String {
        let s = slug.replacingOccurrences(of: "-", with: " ").replacingOccurrences(of: "_", with: " ")
        guard !s.isEmpty else { return slug }
        return s.prefix(1).uppercased() + String(s.dropFirst())
    }
}
