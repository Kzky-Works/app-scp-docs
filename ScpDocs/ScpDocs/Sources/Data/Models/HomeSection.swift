import Foundation

/// ホームダッシュボードの 6 ピラー（2×3）。
enum HomeSection: String, CaseIterable, Sendable, Identifiable {
    /// 報告書アーカイヴ（設定中の支部・100 番ブロック）。
    case archive
    /// SCP ライブラリ（物語／カノン／連作のネイティブ階層）。
    case scpLibrary
    /// 世界各国の報告書（国際ハブ）。
    case international
    /// 要注意団体・人事ファイル。
    case goiAndPersonnel
    /// 新人職員ガイド・規約・ライセンス等。
    case guide
    /// イベント・コンテスト・ランキング。
    case events

    var id: String { rawValue }

    var titleLocalizationKey: String {
        switch self {
        case .archive: LocalizationKey.homeSectionArchiveTitle
        case .scpLibrary: LocalizationKey.homeSectionScpLibraryTitle
        case .international: LocalizationKey.homeSectionInternationalTitle
        case .goiAndPersonnel: LocalizationKey.homeSectionGoIPersonnelTitle
        case .guide: LocalizationKey.homeSectionGuideTitle
        case .events: LocalizationKey.homeSectionEventsTitle
        }
    }

    var subtitleLocalizationKey: String {
        switch self {
        case .archive: LocalizationKey.homeSectionArchiveSubtitle
        case .scpLibrary: LocalizationKey.homeSectionScpLibrarySubtitle
        case .international: LocalizationKey.homeSectionInternationalSubtitle
        case .goiAndPersonnel: LocalizationKey.homeSectionGoIPersonnelSubtitle
        case .guide: LocalizationKey.homeSectionGuideSubtitle
        case .events: LocalizationKey.homeSectionEventsSubtitle
        }
    }

    var systemImageName: String {
        switch self {
        case .archive: "building.columns.fill"
        case .scpLibrary: "books.vertical.fill"
        case .international: "globe"
        case .goiAndPersonnel: "person.3.sequence.fill"
        case .guide: "map"
        case .events: "calendar"
        }
    }

    static let dashboard: [HomeSection] = [
        .archive, .scpLibrary, .international,
        .goiAndPersonnel, .guide, .events
    ]
}
