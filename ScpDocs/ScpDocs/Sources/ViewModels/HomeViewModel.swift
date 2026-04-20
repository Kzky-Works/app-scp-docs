import Foundation
import Observation

@Observable
final class HomeViewModel {
    private let branchCatalog: any BranchCataloging
    private let settingsRepository: SettingsRepository

    private(set) var selectedBranch: Branch
    private(set) var fontSizeMultiplier: Double
    private(set) var uiLanguage: AppUILanguage

    init(
        branchCatalog: any BranchCataloging = StaticBranchCatalog(),
        settingsRepository: SettingsRepository
    ) {
        self.branchCatalog = branchCatalog
        self.settingsRepository = settingsRepository
        let storedId = settingsRepository.loadSelectedBranchId()
        let resolved = branchCatalog.branch(id: storedId) ?? branchCatalog.defaultBranch
        self.selectedBranch = resolved
        if branchCatalog.branch(id: storedId) == nil {
            settingsRepository.saveSelectedBranchId(resolved.id)
        }
        self.fontSizeMultiplier = settingsRepository.loadFontSizeMultiplier()
        self.uiLanguage = settingsRepository.loadUILanguage()
    }

    var resolvedLocale: Locale {
        switch uiLanguage {
        case .system:
            .autoupdatingCurrent
        case .japanese:
            Locale(identifier: "ja")
        case .english:
            Locale(identifier: "en")
        }
    }

    func updateFontSizeMultiplier(_ value: Double) {
        let clamped = min(max(value, 0.75), 2.0)
        guard clamped != fontSizeMultiplier else { return }
        fontSizeMultiplier = clamped
        settingsRepository.saveFontSizeMultiplier(clamped)
    }

    func updateUILanguage(_ value: AppUILanguage) {
        guard value != uiLanguage else { return }
        uiLanguage = value
        settingsRepository.saveUILanguage(value)
    }

    var availableBranches: [Branch] {
        branchCatalog.allBranches
    }

    func selectBranch(id: String) {
        guard let branch = branchCatalog.branch(id: id), branch.id != selectedBranch.id else { return }
        selectedBranch = branch
        settingsRepository.saveSelectedBranchId(id)
    }

    var screenTitle: String {
        String(localized: String.LocalizationValue(LocalizationKey.homeTitle))
    }

    var branchDisplayTitle: String {
        String(localized: String.LocalizationValue(selectedBranch.displayNameKey))
    }

    var branchBaseURLDisplay: String {
        selectedBranch.baseURL.absoluteString
    }

    var branchURLLabel: String {
        String(localized: String.LocalizationValue(LocalizationKey.branchBaseURLLabel))
    }

    /// ホーム `LazyVGrid` 用：現在支部に応じた 6 ピラーのラベルと SF Symbol 名（名前は `systemImageName`）。
    var homeGridItems: [HomeGridItemDescriptor] {
        HomeCategory.allCases.map { $0.gridDescriptor(for: selectedBranch) }
    }

    func loadLibraryListSortMode(for category: LibraryCategory) -> LibraryListSortMode {
        settingsRepository.loadLibraryListSortMode(for: category)
    }

    func saveLibraryListSortMode(_ mode: LibraryListSortMode, for category: LibraryCategory) {
        settingsRepository.saveLibraryListSortMode(mode, for: category)
    }
}
