import Foundation
import Observation

@Observable
final class HomeViewModel {
    private let branchCatalog: any BranchCataloging
    private let settingsRepository: SettingsRepository

    private(set) var selectedBranch: Branch

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
}
