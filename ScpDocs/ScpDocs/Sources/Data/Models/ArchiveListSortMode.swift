import Foundation

/// アーカイヴ一覧の並べ替え。
enum ArchiveListSortMode: String, CaseIterable, Identifiable, Sendable {
    /// レーティング降順（既定）。同点時は報告書番号昇順。
    case ratingHighToLow = "rating_desc"
    /// セグメント内の報告書番号昇順。
    case scpNumberAscending = "scp_asc"

    var id: String { rawValue }

    var localizationKey: String {
        switch self {
        case .ratingHighToLow: LocalizationKey.archiveSortRatingHighToLow
        case .scpNumberAscending: LocalizationKey.archiveSortScpNumberAsc
        }
    }

    static let userDefaultsKey = "archive.list.sort_mode"

    static func load(from defaults: UserDefaults = .standard) -> ArchiveListSortMode {
        guard let raw = defaults.string(forKey: userDefaultsKey),
              let mode = ArchiveListSortMode(rawValue: raw)
        else {
            return .ratingHighToLow
        }
        return mode
    }

    func save(to defaults: UserDefaults = .standard) {
        defaults.set(rawValue, forKey: Self.userDefaultsKey)
    }
}
