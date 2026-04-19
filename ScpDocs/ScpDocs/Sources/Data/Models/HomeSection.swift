import Foundation

/// ホームダッシュボードの 6 ピラー（2×3）。
enum HomeSection: String, CaseIterable, Sendable, Identifiable {
    /// 左（広い）: 日本支部オリジナル（`scp-series-jp` / `scp-NNN-jp`）。
    case jpArchive
    /// 右: 本家メインリストの日本語訳（`scp-series` 系 / `scp-NNN` on scp-jp）。
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

    var badgeLocalizationKey: String {
        switch self {
        case .jpArchive: LocalizationKey.homePillarJpBadge
        case .enArchive: LocalizationKey.homePillarEnBadge
        case .scpLibrary: LocalizationKey.homePillarLibraryBadge
        case .international: LocalizationKey.homePillarInternationalBadge
        case .guide: LocalizationKey.homePillarGuideBadge
        case .events: LocalizationKey.homePillarEventsBadge
        }
    }

    static let dashboard: [HomeSection] = [
        .jpArchive, .enArchive, .scpLibrary,
        .international, .guide, .events
    ]
}
