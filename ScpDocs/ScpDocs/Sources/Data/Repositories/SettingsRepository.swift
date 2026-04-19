import Foundation

/// 支部などアプリ設定の `UserDefaults` 永続化。
final class SettingsRepository: @unchecked Sendable {
    private enum StorageKey {
        static let selectedBranchId = "settings.selected_branch_id"
        static let fontSizeMultiplier = "settings.font_size_multiplier"
        static let uiLanguage = "settings.ui_language"
        static func libraryListSort(_ category: LibraryCategory) -> String {
            "library.list.sort.\(category.rawValue)"
        }
    }

    private static let defaultFontSizeMultiplier = 1.0
    private static let fontSizeRange: ClosedRange<Double> = 0.75 ... 2.0

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadSelectedBranchId() -> String {
        if let raw = defaults.string(forKey: StorageKey.selectedBranchId),
           !raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return raw
        }
        return BranchIdentifier.scpJapan
    }

    func saveSelectedBranchId(_ id: String) {
        defaults.set(id, forKey: StorageKey.selectedBranchId)
    }

    func loadFontSizeMultiplier() -> Double {
        guard defaults.object(forKey: StorageKey.fontSizeMultiplier) != nil else {
            return Self.defaultFontSizeMultiplier
        }
        let raw = defaults.double(forKey: StorageKey.fontSizeMultiplier)
        if raw <= 0 {
            return Self.defaultFontSizeMultiplier
        }
        return min(max(raw, Self.fontSizeRange.lowerBound), Self.fontSizeRange.upperBound)
    }

    func saveFontSizeMultiplier(_ value: Double) {
        let clamped = min(max(value, Self.fontSizeRange.lowerBound), Self.fontSizeRange.upperBound)
        defaults.set(clamped, forKey: StorageKey.fontSizeMultiplier)
    }

    func loadUILanguage() -> AppUILanguage {
        guard let raw = defaults.string(forKey: StorageKey.uiLanguage),
              let parsed = AppUILanguage(rawValue: raw) else {
            return .system
        }
        return parsed
    }

    func saveUILanguage(_ value: AppUILanguage) {
        defaults.set(value.rawValue, forKey: StorageKey.uiLanguage)
    }

    func loadLibraryListSortMode(for category: LibraryCategory) -> LibraryListSortMode {
        guard let raw = defaults.string(forKey: StorageKey.libraryListSort(category)),
              let mode = LibraryListSortMode(rawValue: raw) else {
            return .wikiOrder
        }
        return mode
    }

    func saveLibraryListSortMode(_ mode: LibraryListSortMode, for category: LibraryCategory) {
        defaults.set(mode.rawValue, forKey: StorageKey.libraryListSort(category))
    }
}
