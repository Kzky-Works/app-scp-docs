import Foundation

/// Home 画面のカテゴリ行（支部ごとの主要ハブ URL）。
struct BranchHomeCategory: Sendable, Equatable, Identifiable {
    let id: String
    /// `Localizable.strings` のキー。
    let titleLocalizationKey: String
    let url: URL
}

/// コンテンツ支部（サイト／ロケール）。SwiftUI とは独立。
struct Branch: Sendable, Equatable, Identifiable {
    let id: String
    /// `Localizable.strings` の支部名キー。
    let displayNameKey: String
    let baseURL: URL
    let logoSystemName: String?
    /// `HomeView` で表示する主要カテゴリ。
    let homeCategories: [BranchHomeCategory]

    /// グローバルポータル用の静的マスター（表示順）。
    static let ordered: [Branch] = [
        .japan,
        .englishMain,
        .international
    ]

    /// 日本支部（JP）
    static let japan = Branch(
        id: BranchIdentifier.scpJapan,
        displayNameKey: "branch.name.scp_jp",
        baseURL: URL(string: "https://scp-jp.wikidot.com/")!,
        logoSystemName: "building.columns.fill",
        homeCategories: [
            BranchHomeCategory(id: "jp_site_top", titleLocalizationKey: LocalizationKey.categorySiteTop, url: URL(string: "https://scp-jp.wikidot.com/")!),
            BranchHomeCategory(id: "jp_series_1", titleLocalizationKey: LocalizationKey.categorySeriesJP1, url: URL(string: "https://scp-jp.wikidot.com/scp-series-jp")!),
            BranchHomeCategory(id: "jp_series_2", titleLocalizationKey: LocalizationKey.categorySeriesJP2, url: URL(string: "https://scp-jp.wikidot.com/scp-series-jp-2")!),
            BranchHomeCategory(id: "jp_series_3", titleLocalizationKey: LocalizationKey.categorySeriesJP3, url: URL(string: "https://scp-jp.wikidot.com/scp-series-jp-3")!),
            BranchHomeCategory(id: "jp_series_4", titleLocalizationKey: LocalizationKey.categorySeriesJP4, url: URL(string: "https://scp-jp.wikidot.com/scp-series-jp-4")!),
            BranchHomeCategory(id: "jp_tales", titleLocalizationKey: LocalizationKey.categoryTalesJP, url: URL(string: "https://scp-jp.wikidot.com/foundation-tales-jp")!),
            BranchHomeCategory(id: "jp_credits", titleLocalizationKey: LocalizationKey.categoryCredits, url: URL(string: "https://scp-jp.wikidot.com/credits")!)
        ]
    )

    /// 本部（英語メインサイト, EN）
    static let englishMain = Branch(
        id: BranchIdentifier.scpWikiEN,
        displayNameKey: "branch.name.scp_en",
        baseURL: URL(string: "https://scp-wiki.wikidot.com/")!,
        logoSystemName: "globe.americas.fill",
        homeCategories: [
            BranchHomeCategory(id: "en_site_top", titleLocalizationKey: LocalizationKey.categoryENSiteTop, url: URL(string: "https://scp-wiki.wikidot.com/")!),
            BranchHomeCategory(id: "en_series_1", titleLocalizationKey: LocalizationKey.categoryENSeries1, url: URL(string: "https://scp-wiki.wikidot.com/scp-series")!),
            BranchHomeCategory(id: "en_series_2", titleLocalizationKey: LocalizationKey.categoryENSeries2, url: URL(string: "https://scp-wiki.wikidot.com/scp-series-2")!),
            BranchHomeCategory(id: "en_series_3", titleLocalizationKey: LocalizationKey.categoryENSeries3, url: URL(string: "https://scp-wiki.wikidot.com/scp-series-3")!),
            BranchHomeCategory(id: "en_series_4", titleLocalizationKey: LocalizationKey.categoryENSeries4, url: URL(string: "https://scp-wiki.wikidot.com/scp-series-4")!),
            BranchHomeCategory(id: "en_series_5", titleLocalizationKey: LocalizationKey.categoryENSeries5, url: URL(string: "https://scp-wiki.wikidot.com/scp-series-5")!),
            BranchHomeCategory(id: "en_tales", titleLocalizationKey: LocalizationKey.categoryENTales, url: URL(string: "https://scp-wiki.wikidot.com/foundation-tales")!),
            BranchHomeCategory(id: "en_licensing", titleLocalizationKey: LocalizationKey.categoryENLicensing, url: URL(string: "https://scp-wiki.wikidot.com/licensing-guide")!)
        ]
    )

    /// 国際（INT / SCP International）
    static let international = Branch(
        id: BranchIdentifier.scpInternational,
        displayNameKey: "branch.name.scp_int",
        baseURL: URL(string: "https://scp-int.wikidot.com/")!,
        logoSystemName: "globe",
        homeCategories: [
            BranchHomeCategory(id: "int_site_top", titleLocalizationKey: LocalizationKey.categoryINTSiteTop, url: URL(string: "https://scp-int.wikidot.com/")!),
            BranchHomeCategory(id: "int_branches", titleLocalizationKey: LocalizationKey.categoryINTBranches, url: URL(string: "https://scp-int.wikidot.com/scp-international")!),
            BranchHomeCategory(id: "int_rules", titleLocalizationKey: LocalizationKey.categoryINTRules, url: URL(string: "https://scp-int.wikidot.com/site-rules")!),
            BranchHomeCategory(id: "int_tags", titleLocalizationKey: LocalizationKey.categoryINTTagGuide, url: URL(string: "https://scp-int.wikidot.com/tag-guide")!),
            BranchHomeCategory(id: "int_chat", titleLocalizationKey: LocalizationKey.categoryINTChat, url: URL(string: "https://scp-int.wikidot.com/join-chat")!)
        ]
    )

    /// 既存コード向けエイリアス。
    static let scpJapanDefault = japan
}
