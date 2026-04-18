import Foundation

protocol BranchCataloging: Sendable {
    func branch(id: String) -> Branch?
    var defaultBranch: Branch { get }
    var allBranches: [Branch] { get }
}

/// 静的マスター。将来はリモート設定へ差し替え可能。
struct StaticBranchCatalog: BranchCataloging {
    func branch(id: String) -> Branch? {
        Branch.ordered.first { $0.id == id }
    }

    var defaultBranch: Branch { Branch.japan }

    var allBranches: [Branch] { Branch.ordered }
}
