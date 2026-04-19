import Foundation

/// ホームダッシュボードの 6 ピラー（2×3）。
enum HomeSection: String, CaseIterable, Sendable, Identifiable {
    /// SCP-JP 報告書アーカイヴ（100 番ブロック）。
    case jpArchive
    /// SCP Wiki（英語）報告書アーカイヴ。
    case enArchive
    /// SCP ライブラリ（書庫タブで `LibraryIndexView`）。
    case scpLibrary
    /// SCP International（国際ハブ）。
    case international
    /// 新人職員ガイド・規約。
    case guide
    /// イベント・コンテスト。
    case events

    var id: String { rawValue }

    var titleLocalizationKey: String {
        switch self {
        case .jpArchive: LocalizationKey.homeSectionJpArchiveTitle
        case .enArchive: LocalizationKey.homeSectionEnArchiveTitle
        case .scpLibrary: LocalizationKey.homeSectionScpLibraryTitle
        case .international: LocalizationKey.homeSectionInternationalTitle
        case .guide: LocalizationKey.homeSectionGuideTitle
        case .events: LocalizationKey.homeSectionEventsTitle
        }
    }

    var subtitleLocalizationKey: String {
        switch self {
        case .jpArchive: LocalizationKey.homeSectionJpArchiveSubtitle
        case .enArchive: LocalizationKey.homeSectionEnArchiveSubtitle
        case .scpLibrary: LocalizationKey.homeSectionScpLibrarySubtitle
        case .international: LocalizationKey.homeSectionInternationalSubtitle
        case .guide: LocalizationKey.homeSectionGuideSubtitle
        case .events: LocalizationKey.homeSectionEventsSubtitle
        }
    }

    var systemImageName: String {
        switch self {
        case .jpArchive: "building.columns.fill"
        case .enArchive: "globe.americas.fill"
        case .scpLibrary: "books.vertical.fill"
        case .international: "globe"
        case .guide: "map"
        case .events: "calendar"
        }
    }

    static let dashboard: [HomeSection] = [
        .jpArchive, .enArchive, .scpLibrary,
        .international, .guide, .events
    ]
}
