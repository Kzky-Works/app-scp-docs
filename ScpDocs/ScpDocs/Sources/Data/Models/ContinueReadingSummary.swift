import Foundation

/// ホーム「続きから読む」5 行分の表示用（SwiftUI 以外の純データ）。
struct ContinueReadingRowDisplay: Sendable, Equatable {
    /// 一行目: カテゴリ短名（ローカライズ済み）。
    let categoryLine: String
    /// 二行目: 番号・ハブ名・著者名など。
    let identifierLine: String
    /// 三行目: タイトル。
    let titleLine: String
    /// 四行目: オブジェクトクラス全文（`nil` のときは行ごと非表示）。
    let objectClassLine: String?
    /// 五行目: 0...1 のスクロール進捗。
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
        categoryLabel: (String) -> String,
        objectClassFormat: (String) -> String
    ) -> ContinueReadingRowDisplay {
        let slug = url.path.split(separator: "/").last.map(String.init) ?? ""
        let host = url.host?.lowercased() ?? ""

        let classification = classify(host: host, slug: slug, url: url, japanListHint: japanListHint)

        let identifier = resolveIdentifier(
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
        let objectLine = objectClassLine(
            classification: classification,
            japanHint: japanListHint,
            format: objectClassFormat
        )

        return ContinueReadingRowDisplay(
            categoryLine: categoryLabel(classification.categoryLocalizationKey),
            identifierLine: identifier,
            titleLine: title,
            objectClassLine: objectLine,
            scrollProgress: min(1, max(0, scrollProgress)),
            thumbnailURL: thumbnailURL
        )
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

        var categoryLocalizationKey: String {
            switch self {
            case .scpJapanOriginal: LocalizationKey.homeContinueCategoryScpJp
            case .scpJapanMainlistTranslation: LocalizationKey.homeContinueCategoryScpMainJp
            case .scpJapanJoke: LocalizationKey.homeContinueCategoryJoke
            case .scpEnglishMain, .scpEnglishJoke: LocalizationKey.homeContinueCategoryScpEn
            case .scpInternationalMain: LocalizationKey.homeContinueCategoryScpInt
            case .tale: LocalizationKey.homeContinueCategoryTale
            case .canon: LocalizationKey.homeContinueCategoryCanon
            case .goi: LocalizationKey.homeContinueCategoryGoi
            case .other: LocalizationKey.homeContinueCategoryOther
            }
        }
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

    private static func resolveIdentifier(
        classification: Classification,
        slug: String,
        cachedPageTitle: String?,
        japanListHint: JapanSCPListReadingHint?
    ) -> String {
        if let japanListHint {
            return japanListHint.displaySlug
        }
        switch classification {
        case .tale:
            return taleIdentifierLine(cachedPageTitle: cachedPageTitle, slug: slug)
        case .scpEnglishMain, .scpEnglishJoke, .scpInternationalMain:
            return scpSlugDisplay(slug)
        case .canon, .goi, .other:
            return humanizedSlug(slug)
        default:
            return humanizedSlug(slug)
        }
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

    private static func objectClassLine(
        classification: Classification,
        japanHint: JapanSCPListReadingHint?,
        format: (String) -> String
    ) -> String? {
        switch classification {
        case .scpJapanOriginal, .scpJapanMainlistTranslation, .scpJapanJoke, .scpEnglishJoke:
            if let oc = japanHint?.objectClass?.trimmingCharacters(in: .whitespacesAndNewlines), !oc.isEmpty {
                return format(oc)
            }
            return nil
        case .scpEnglishMain, .scpInternationalMain:
            return nil
        default:
            return nil
        }
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
