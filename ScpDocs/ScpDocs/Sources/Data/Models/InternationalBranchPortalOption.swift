import Foundation

/// SCP International カタログ下部の横スクロール支部チップ（末尾言語コードで一覧を絞り込み、支部 Wiki へ遷移）。
struct InternationalBranchPortalOption: Identifiable, Sendable {
    let id: String
    let chipTitleLocalizationKey: String
    let portalURL: URL
    private let filterRule: FilterRule

    private enum FilterRule: Sendable, Equatable, Hashable {
        case codes(Set<String>)
        case portuguese
        case traditionalChinese
        case other
    }

    /// `scp-int` の `scp-番号-言語` 系スラッグから、末尾の言語コード断片を抽出する。
    enum SCPIntSlugLanguageTail: Sendable {
        /// 公式支部タブに割り当て済みの末尾コード（`その他` 判定の否定形に使用）。
        static let namedBranchCodes: Set<String> = [
            "ru", "ko", "cn", "fr", "pl", "es", "th", "de", "it", "ua", "pt", "br", "cs", "zh", "tr", "vn"
        ]

        /// 英語 `-en` はホームの EN 専用カタログで扱うため、INT 一覧からは常に除外する。
        static func isEnglishBranchCatalogEntry(_ article: SCPArticle) -> Bool {
            guard let tail = tailTokens(from: article) else { return false }
            return tail.contains("en")
        }

        static func tailTokens(from article: SCPArticle) -> [String]? {
            guard let url = article.resolvedURL else { return nil }
            guard url.host?.localizedCaseInsensitiveContains("scp-int") == true else { return nil }
            var slug = url.lastPathComponent.lowercased()
            if let hash = slug.firstIndex(of: "#") {
                slug = String(slug[..<hash])
            }
            guard slug.hasPrefix("scp-") else { return nil }
            let body = String(slug.dropFirst(4))
            let parts = body.split(separator: "-").map { String($0).lowercased() }
            guard let first = parts.first, !first.isEmpty else { return nil }
            guard first.first?.isNumber == true else { return nil }
            var tail = Array(parts.dropFirst())
            while let last = tail.last {
                if last == "j" || last == "ex" {
                    tail.removeLast()
                    continue
                }
                break
            }
            return tail
        }
    }

    func matchesCatalogEntry(_ article: SCPArticle) -> Bool {
        switch filterRule {
        case .codes(let codes):
            guard let tail = SCPIntSlugLanguageTail.tailTokens(from: article) else { return false }
            return !Set(tail).isDisjoint(with: codes)
        case .portuguese:
            guard let tail = SCPIntSlugLanguageTail.tailTokens(from: article) else { return false }
            return tail.contains("pt") || tail.contains("br")
        case .traditionalChinese:
            guard let tail = SCPIntSlugLanguageTail.tailTokens(from: article) else { return false }
            return tail.contains("zh") || tail.contains("tr")
        case .other:
            guard let tail = SCPIntSlugLanguageTail.tailTokens(from: article) else {
                return false
            }
            if tail.isEmpty { return true }
            let tokenSet = Set(tail)
            if !tokenSet.isDisjoint(with: SCPIntSlugLanguageTail.namedBranchCodes) { return false }
            if tail.contains("pt") || tail.contains("br") { return false }
            return true
        }
    }

    static let ordered: [InternationalBranchPortalOption] = [
        InternationalBranchPortalOption(
            id: "ru",
            chipTitleLocalizationKey: LocalizationKey.intCatalogBranchChipRU,
            portalURL: URL(string: "https://scpfoundation.net/")!,
            filterRule: .codes(["ru"])
        ),
        InternationalBranchPortalOption(
            id: "ko",
            chipTitleLocalizationKey: LocalizationKey.intCatalogBranchChipKO,
            portalURL: URL(string: "https://scp-kr.wikidot.com/")!,
            filterRule: .codes(["ko"])
        ),
        InternationalBranchPortalOption(
            id: "cn",
            chipTitleLocalizationKey: LocalizationKey.intCatalogBranchChipCN,
            portalURL: URL(string: "https://scp-wiki-cn.wikidot.com/")!,
            filterRule: .codes(["cn"])
        ),
        InternationalBranchPortalOption(
            id: "fr",
            chipTitleLocalizationKey: LocalizationKey.intCatalogBranchChipFR,
            portalURL: URL(string: "https://fondationscp.wikidot.com/")!,
            filterRule: .codes(["fr"])
        ),
        InternationalBranchPortalOption(
            id: "pl",
            chipTitleLocalizationKey: LocalizationKey.intCatalogBranchChipPL,
            portalURL: URL(string: "https://scp-pl.wikidot.com/")!,
            filterRule: .codes(["pl"])
        ),
        InternationalBranchPortalOption(
            id: "es",
            chipTitleLocalizationKey: LocalizationKey.intCatalogBranchChipES,
            portalURL: URL(string: "https://lafundacionscp.wikidot.com/")!,
            filterRule: .codes(["es"])
        ),
        InternationalBranchPortalOption(
            id: "th",
            chipTitleLocalizationKey: LocalizationKey.intCatalogBranchChipTH,
            portalURL: URL(string: "https://scp-th.wikidot.com/")!,
            filterRule: .codes(["th"])
        ),
        InternationalBranchPortalOption(
            id: "de",
            chipTitleLocalizationKey: LocalizationKey.intCatalogBranchChipDE,
            portalURL: URL(string: "https://scp-wiki-de.wikidot.com/")!,
            filterRule: .codes(["de"])
        ),
        InternationalBranchPortalOption(
            id: "it",
            chipTitleLocalizationKey: LocalizationKey.intCatalogBranchChipIT,
            portalURL: URL(string: "https://fondazionescp.wikidot.com/")!,
            filterRule: .codes(["it"])
        ),
        InternationalBranchPortalOption(
            id: "ua",
            chipTitleLocalizationKey: LocalizationKey.intCatalogBranchChipUA,
            portalURL: URL(string: "https://scp-ukrainian.wikidot.com/")!,
            filterRule: .codes(["ua"])
        ),
        InternationalBranchPortalOption(
            id: "pt_br",
            chipTitleLocalizationKey: LocalizationKey.intCatalogBranchChipPTBR,
            portalURL: URL(string: "https://scp-pt-br.wikidot.com/")!,
            filterRule: .portuguese
        ),
        InternationalBranchPortalOption(
            id: "cs",
            chipTitleLocalizationKey: LocalizationKey.intCatalogBranchChipCS,
            portalURL: URL(string: "https://scp-cs.wikidot.com/")!,
            filterRule: .codes(["cs"])
        ),
        InternationalBranchPortalOption(
            id: "zh_tr",
            chipTitleLocalizationKey: LocalizationKey.intCatalogBranchChipZHTR,
            portalURL: URL(string: "https://scp-zh-tr.wikidot.com/")!,
            filterRule: .traditionalChinese
        ),
        InternationalBranchPortalOption(
            id: "vn",
            chipTitleLocalizationKey: LocalizationKey.intCatalogBranchChipVN,
            portalURL: URL(string: "https://scp-vn.wikidot.com/")!,
            filterRule: .codes(["vn"])
        ),
        InternationalBranchPortalOption(
            id: "other",
            chipTitleLocalizationKey: LocalizationKey.intCatalogBranchChipOther,
            portalURL: URL(string: "https://scp-int.wikidot.com/other-hub")!,
            filterRule: .other
        )
    ]

    static func option(id: String) -> InternationalBranchPortalOption? {
        ordered.first { $0.id == id }
    }
}
