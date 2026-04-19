import Foundation

/// SCP ライブラリ中間階層（物語 / カノン / 連作）と、要注意団体（GoI）ネイティブ一覧。
enum LibraryCategory: String, CaseIterable, Identifiable, Sendable {
    case tales
    case canons
    case series
    case goi

    var id: String { rawValue }

    /// ホーム「SCPライブラリ」ポータルに出すカテゴリ（物語・カノン・連作のみ）。
    static let scpLibraryPortalCategories: [LibraryCategory] = [.tales, .canons, .series]

    var titleLocalizationKey: String {
        switch self {
        case .tales: LocalizationKey.libraryCategoryTalesTitle
        case .canons: LocalizationKey.libraryCategoryCanonsTitle
        case .series: LocalizationKey.libraryCategorySeriesTitle
        case .goi: LocalizationKey.libraryCategoryGoITitle
        }
    }

    var subtitleLocalizationKey: String {
        switch self {
        case .tales: LocalizationKey.libraryCategoryTalesSubtitle
        case .canons: LocalizationKey.libraryCategoryCanonsSubtitle
        case .series: LocalizationKey.libraryCategorySeriesSubtitle
        case .goi: LocalizationKey.libraryCategoryGoISubtitle
        }
    }

    func hubURL(for branch: Branch) -> URL {
        switch self {
        case .tales:
            branch.talesHubURL()
        case .canons:
            branch.talesCanonHubURL()
        case .series:
            branch.taleSeriesHubURL()
        case .goi:
            branch.groupsOfInterestHubURL()
        }
    }
}
