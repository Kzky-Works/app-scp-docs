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

    // Wikidot は多くの URL で https → http へ 301 する。ATS は `Info-ATS.plist` で対応。
    // 未検討: 最初から `http://` で開きリダイレクトを減らす（挙動・App Review 説明とセットで後日判断）。

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

    /// 報告書アーカイヴ用に `branchId` から支部を解決する。
    static func branchForArchiveIndex(id: String) -> Branch {
        switch id {
        case BranchIdentifier.scpJapan:
            japan
        case BranchIdentifier.scpWikiEN:
            englishMain
        case BranchIdentifier.scpInternational:
            international
        default:
            japan
        }
    }

    /// 各支部の「サイトトップ」相当のハブ（`homeCategories` の `*_site_top`）。
    func siteTopHubURL() -> URL {
        if let url = homeCategories.first(where: { $0.id.hasSuffix("site_top") })?.url {
            return url
        }
        return baseURL
    }

    /// 物語ハブ（支部に無い場合は英語支部の物語へフォールバック）。
    func talesHubURL() -> URL {
        if let url = homeCategories.first(where: { $0.id.hasSuffix("_tales") })?.url {
            return url
        }
        return Branch.englishMain.homeCategories.first { $0.id == "en_tales" }!.url
    }

    /// 要注意団体（GoI）ハブ。
    func groupsOfInterestHubURL() -> URL {
        switch id {
        case BranchIdentifier.scpJapan:
            return URL(string: "https://scp-jp.wikidot.com/groups-of-interest-jp")!
        case BranchIdentifier.scpInternational:
            return homeCategories.first { $0.id == "int_branches" }!.url
        default:
            return URL(string: "https://scp-wiki.wikidot.com/groups-of-interest")!
        }
    }

    /// ガイド・規約系ハブ（ライセンス／サイトルールなど）。
    func guideHubURL() -> URL {
        switch id {
        case BranchIdentifier.scpJapan:
            return URL(string: "https://scp-jp.wikidot.com/guide-hub")!
        case BranchIdentifier.scpInternational:
            return homeCategories.first { $0.id == "int_rules" }!.url
        default:
            return homeCategories.first { $0.id == "en_licensing" }!.url
        }
    }

    /// コンテスト・アーカイヴ（イベント）。
    func eventsHubURL() -> URL {
        switch id {
        case BranchIdentifier.scpJapan:
            return URL(string: "https://scp-jp.wikidot.com/contest-archive")!
        case BranchIdentifier.scpInternational:
            return homeCategories.first { $0.id == "int_site_top" }!.url
        default:
            return URL(string: "https://scp-wiki.wikidot.com/contest-archive")!
        }
    }

    /// カノン・世界観ハブ（物語ポータル用）。
    func talesCanonHubURL() -> URL {
        switch id {
        case BranchIdentifier.scpJapan:
            return URL(string: "https://scp-jp.wikidot.com/canon-hub-jp")!
        default:
            return URL(string: "https://scp-wiki.wikidot.com/canon-hub")!
        }
    }

    /// 連作（Tale シリーズ）ハブ。国際支部など未整備の場合は英語本部のアーカイヴへフォールバック。
    func taleSeriesHubURL() -> URL {
        switch id {
        case BranchIdentifier.scpJapan:
            return URL(string: "https://scp-jp.wikidot.com/series-hub-jp")!
        default:
            return URL(string: "https://scp-wiki.wikidot.com/series-archive")!
        }
    }

    /// 高評価の物語一覧（支部にページが無い場合は `nil`）。
    func topRatedTalesURL() -> URL? {
        switch id {
        case BranchIdentifier.scpJapan:
            return nil
        default:
            return URL(string: "https://scp-wiki.wikidot.com/top-rated-tales")!
        }
    }

    /// 人事ファイル・登場人物（図鑑ポータル用）。
    func personnelDossierHubURL() -> URL {
        switch id {
        case BranchIdentifier.scpJapan:
            return URL(string: "https://scp-jp.wikidot.com/system:page-tags/tag/personnel")!
        default:
            return URL(string: "https://scp-wiki.wikidot.com/personnel-and-character-dossier")!
        }
    }

    /// オブジェクトクラス解説（英語メインサイトを参照）。
    func objectClassGuideURL() -> URL {
        URL(string: "https://scp-wiki.wikidot.com/object-classes")!
    }

    /// サイト規約・投稿ルール。
    func siteRulesURL() -> URL {
        switch id {
        case BranchIdentifier.scpJapan:
            return URL(string: "https://scp-jp.wikidot.com/guide-hub")!
        case BranchIdentifier.scpInternational:
            return homeCategories.first { $0.id == "int_rules" }!.url
        default:
            return URL(string: "https://scp-wiki.wikidot.com/site-rules")!
        }
    }

    /// 人気・評価の報告書（ランキング系イベントポータル用）。
    func topRatedReportsURL() -> URL? {
        switch id {
        case BranchIdentifier.scpJapan:
            return nil
        default:
            return URL(string: "https://scp-wiki.wikidot.com/highest-rated-scps")!
        }
    }
}
