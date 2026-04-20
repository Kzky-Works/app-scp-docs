import Foundation

/// ホーム「読者特化型」6 ピラー（`HomeView` で 2 列×3 行。行の高さ比は上段 5/11、中段・下段各 3/11）。
enum HomeCategory: String, CaseIterable, Sendable, Identifiable {
    /// 01: 日本支部オリジナル報告書（`scp-NNN-jp`）— アーカイヴ `-jp` タグ適用。
    case jpArticles
    /// 02: 本家メインリスト和訳（`scp-NNN`）— アーカイヴ EN 訳相当リスト。
    case originalArticles
    /// 03: 物語（Foundation Tales 系ハブ）。
    case tales
    /// 04: カノン・世界観ハブ。
    case canons
    /// 05: 要注意団体（GoI）ネイティブ一覧。
    case gois
    /// 06: ジョーク報告書ハブ。
    case jokes

    var id: String { rawValue }
}

/// `HomeViewModel` がホームグリッド用に返す表示情報（SF Symbol 名は View 側で `Image(systemName:)` に渡す）。
struct HomeGridItemDescriptor: Identifiable, Hashable, Sendable {
    var id: HomeCategory { category }

    let category: HomeCategory
    let titleLocalizationKey: String
    let subtitleLocalizationKey: String
    let badgeLocalizationKey: String
    let systemImageName: String
}

extension HomeCategory {
    /// 支部ごとにタイトル・サブタイトル・バッジ・アイコンを切り替える。
    func gridDescriptor(for branch: Branch) -> HomeGridItemDescriptor {
        HomeGridItemDescriptor(
            category: self,
            titleLocalizationKey: titleKey(for: branch),
            subtitleLocalizationKey: subtitleKey(for: branch),
            badgeLocalizationKey: badgeKey(for: branch),
            systemImageName: systemImageName(for: branch)
        )
    }

    private func titleKey(for branch: Branch) -> String {
        switch (self, branch.id) {
        case (.jpArticles, BranchIdentifier.scpJapan):
            LocalizationKey.homeReaderJpArticlesTitleJP
        case (.jpArticles, BranchIdentifier.scpWikiEN):
            LocalizationKey.homeReaderJpArticlesTitleEN
        case (.jpArticles, BranchIdentifier.scpInternational):
            LocalizationKey.homeReaderJpArticlesTitleINT
        case (.originalArticles, BranchIdentifier.scpJapan):
            LocalizationKey.homeReaderOriginalArticlesTitleJP
        case (.originalArticles, BranchIdentifier.scpWikiEN):
            LocalizationKey.homeReaderOriginalArticlesTitleEN
        case (.originalArticles, BranchIdentifier.scpInternational):
            LocalizationKey.homeReaderOriginalArticlesTitleINT
        case (.tales, BranchIdentifier.scpJapan):
            LocalizationKey.homeReaderTalesTitleJP
        case (.tales, BranchIdentifier.scpWikiEN):
            LocalizationKey.homeReaderTalesTitleEN
        case (.tales, BranchIdentifier.scpInternational):
            LocalizationKey.homeReaderTalesTitleINT
        case (.canons, BranchIdentifier.scpJapan):
            LocalizationKey.homeReaderCanonsTitleJP
        case (.canons, BranchIdentifier.scpWikiEN):
            LocalizationKey.homeReaderCanonsTitleEN
        case (.canons, BranchIdentifier.scpInternational):
            LocalizationKey.homeReaderCanonsTitleINT
        case (.gois, BranchIdentifier.scpJapan):
            LocalizationKey.homeReaderGoisTitleJP
        case (.gois, BranchIdentifier.scpWikiEN):
            LocalizationKey.homeReaderGoisTitleEN
        case (.gois, BranchIdentifier.scpInternational):
            LocalizationKey.homeReaderGoisTitleINT
        case (.jokes, BranchIdentifier.scpJapan):
            LocalizationKey.homeReaderJokesTitleJP
        case (.jokes, BranchIdentifier.scpWikiEN):
            LocalizationKey.homeReaderJokesTitleEN
        case (.jokes, BranchIdentifier.scpInternational):
            LocalizationKey.homeReaderJokesTitleINT
        default:
            LocalizationKey.homeReaderJpArticlesTitleJP
        }
    }

    private func subtitleKey(for branch: Branch) -> String {
        switch (self, branch.id) {
        case (.jpArticles, BranchIdentifier.scpJapan):
            LocalizationKey.homeReaderJpArticlesSubtitleJP
        case (.jpArticles, BranchIdentifier.scpWikiEN):
            LocalizationKey.homeReaderJpArticlesSubtitleEN
        case (.jpArticles, BranchIdentifier.scpInternational):
            LocalizationKey.homeReaderJpArticlesSubtitleINT
        case (.originalArticles, BranchIdentifier.scpJapan):
            LocalizationKey.homeReaderOriginalArticlesSubtitleJP
        case (.originalArticles, BranchIdentifier.scpWikiEN):
            LocalizationKey.homeReaderOriginalArticlesSubtitleEN
        case (.originalArticles, BranchIdentifier.scpInternational):
            LocalizationKey.homeReaderOriginalArticlesSubtitleINT
        case (.tales, BranchIdentifier.scpJapan):
            LocalizationKey.homeReaderTalesSubtitleJP
        case (.tales, BranchIdentifier.scpWikiEN):
            LocalizationKey.homeReaderTalesSubtitleEN
        case (.tales, BranchIdentifier.scpInternational):
            LocalizationKey.homeReaderTalesSubtitleINT
        case (.canons, BranchIdentifier.scpJapan):
            LocalizationKey.homeReaderCanonsSubtitleJP
        case (.canons, BranchIdentifier.scpWikiEN):
            LocalizationKey.homeReaderCanonsSubtitleEN
        case (.canons, BranchIdentifier.scpInternational):
            LocalizationKey.homeReaderCanonsSubtitleINT
        case (.gois, BranchIdentifier.scpJapan):
            LocalizationKey.homeReaderGoisSubtitleJP
        case (.gois, BranchIdentifier.scpWikiEN):
            LocalizationKey.homeReaderGoisSubtitleEN
        case (.gois, BranchIdentifier.scpInternational):
            LocalizationKey.homeReaderGoisSubtitleINT
        case (.jokes, BranchIdentifier.scpJapan):
            LocalizationKey.homeReaderJokesSubtitleJP
        case (.jokes, BranchIdentifier.scpWikiEN):
            LocalizationKey.homeReaderJokesSubtitleEN
        case (.jokes, BranchIdentifier.scpInternational):
            LocalizationKey.homeReaderJokesSubtitleINT
        default:
            LocalizationKey.homeReaderJpArticlesSubtitleJP
        }
    }

    private func badgeKey(for branch: Branch) -> String {
        switch (self, branch.id) {
        case (_, BranchIdentifier.scpWikiEN):
            badgeKeyEnglishSite
        case (_, BranchIdentifier.scpInternational):
            badgeKeyInternationalSite
        default:
            badgeKeyJapanSite
        }
    }

    /// バッジ文言（支部サイト別）。01…06 の番号はカテゴリで固定。
    private var badgeKeyJapanSite: String {
        switch self {
        case .jpArticles: LocalizationKey.homeReaderPillar01BadgeJP
        case .originalArticles: LocalizationKey.homeReaderPillar02BadgeJP
        case .tales: LocalizationKey.homeReaderPillar03BadgeJP
        case .canons: LocalizationKey.homeReaderPillar04BadgeJP
        case .gois: LocalizationKey.homeReaderPillar05BadgeJP
        case .jokes: LocalizationKey.homeReaderPillar06BadgeJP
        }
    }

    private var badgeKeyEnglishSite: String {
        switch self {
        case .jpArticles: LocalizationKey.homeReaderPillar01BadgeEN
        case .originalArticles: LocalizationKey.homeReaderPillar02BadgeEN
        case .tales: LocalizationKey.homeReaderPillar03BadgeEN
        case .canons: LocalizationKey.homeReaderPillar04BadgeEN
        case .gois: LocalizationKey.homeReaderPillar05BadgeEN
        case .jokes: LocalizationKey.homeReaderPillar06BadgeEN
        }
    }

    private var badgeKeyInternationalSite: String {
        switch self {
        case .jpArticles: LocalizationKey.homeReaderPillar01BadgeINT
        case .originalArticles: LocalizationKey.homeReaderPillar02BadgeINT
        case .tales: LocalizationKey.homeReaderPillar03BadgeINT
        case .canons: LocalizationKey.homeReaderPillar04BadgeINT
        case .gois: LocalizationKey.homeReaderPillar05BadgeINT
        case .jokes: LocalizationKey.homeReaderPillar06BadgeINT
        }
    }

    private func systemImageName(for branch: Branch) -> String {
        switch self {
        case .jpArticles:
            "doc.text.fill"
        case .originalArticles:
            "character.book.closed.fill"
        case .tales:
            "book.pages.fill"
        case .canons:
            "map.fill"
        case .gois:
            "building.2.fill"
        case .jokes:
            switch branch.id {
            case BranchIdentifier.scpJapan:
                "theatermasks.fill"
            default:
                "face.smiling.inverse"
            }
        }
    }
}
