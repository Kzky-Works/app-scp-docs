import Foundation

/// 支部などアプリ設定の `UserDefaults` 永続化。
final class SettingsRepository: @unchecked Sendable {
    private enum StorageKey {
        static let selectedBranchId = "settings.selected_branch_id"
    }

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
}
