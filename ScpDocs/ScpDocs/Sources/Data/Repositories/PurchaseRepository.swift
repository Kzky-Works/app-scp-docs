import Foundation
import Observation
import StoreKit

/// StoreKit 2 による「広告除去」購入の確認と `UserDefaults` への反映。
@Observable
@MainActor
final class PurchaseRepository {
    private enum StorageKey {
        static let adFreeUnlocked = "purchase.ad_free_unlocked"
    }

    /// App Store Connect で作成する非消費型プロダクト ID（本番で一致させる）。
    nonisolated static let adRemovalProductID = "com.scpreader.app.scpdocs.adfree"

    private(set) var isAdRemovalActive: Bool
    private(set) var lastErrorDescription: String?
    private(set) var isPurchaseInProgress = false

    private let productID: String
    private let defaults: UserDefaults

    init(
        productID: String = PurchaseRepository.adRemovalProductID,
        defaults: UserDefaults = .standard
    ) {
        self.productID = productID
        self.defaults = defaults
        self.isAdRemovalActive = defaults.bool(forKey: StorageKey.adFreeUnlocked)
        Task { await self.listenForTransactions() }
        Task { await self.refreshEntitlementsFromStore() }
    }

    /// 起動時・復元後にトランザクション状態を再評価する。
    func refreshEntitlementsFromStore() async {
        var unlocked = false
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if transaction.productID == productID {
                unlocked = true
                break
            }
        }
        applyAdFreeFlag(unlocked)
    }

    func purchaseAdRemoval() async {
        lastErrorDescription = nil
        isPurchaseInProgress = true
        defer { isPurchaseInProgress = false }
        do {
            let products = try await Product.products(for: [productID])
            guard let product = products.first else {
                lastErrorDescription = String(localized: String.LocalizationValue(LocalizationKey.settingsPurchaseProductUnavailable))
                return
            }
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                guard case .verified(let transaction) = verification else {
                    lastErrorDescription = String(localized: String.LocalizationValue(LocalizationKey.settingsPurchaseVerificationFailed))
                    return
                }
                if transaction.productID == productID {
                    await transaction.finish()
                    applyAdFreeFlag(true)
                }
            case .userCancelled:
                break
            case .pending:
                break
            @unknown default:
                break
            }
        } catch {
            lastErrorDescription = error.localizedDescription
        }
    }

    func restorePurchases() async {
        lastErrorDescription = nil
        isPurchaseInProgress = true
        defer { isPurchaseInProgress = false }
        do {
            try await AppStore.sync()
            await refreshEntitlementsFromStore()
        } catch {
            lastErrorDescription = error.localizedDescription
        }
    }

    private func listenForTransactions() async {
        for await update in Transaction.updates {
            guard case .verified(let transaction) = update else { continue }
            if transaction.productID == productID {
                applyAdFreeFlag(true)
                await transaction.finish()
            }
        }
    }

    private func applyAdFreeFlag(_ unlocked: Bool) {
        isAdRemovalActive = unlocked
        defaults.set(unlocked, forKey: StorageKey.adFreeUnlocked)
    }
}
