import Foundation

/// グローバル検索結果の系統（タグ表示用）。
enum GlobalSearchBadge: String, Sendable, CaseIterable, Equatable {
    case scpJpCatalog
    case scpEnCatalog
    case scpIntCatalog
    case tale
    case goi
    case canon
    case joke
    case scpJpIndexedList

    var localizationKey: String {
        switch self {
        case .scpJpCatalog: LocalizationKey.searchBadgeScpJpCatalog
        case .scpEnCatalog: LocalizationKey.searchBadgeScpEnCatalog
        case .scpIntCatalog: LocalizationKey.searchBadgeScpIntCatalog
        case .tale: LocalizationKey.searchBadgeTale
        case .goi: LocalizationKey.searchBadgeGoi
        case .canon: LocalizationKey.searchBadgeCanon
        case .joke: LocalizationKey.searchBadgeJoke
        case .scpJpIndexedList: LocalizationKey.searchBadgeScpJpList
        }
    }

    static func badge(forTrifold kind: SCPArticleFeedKind) -> GlobalSearchBadge? {
        switch kind {
        case .jp: .scpJpCatalog
        case .en: .scpEnCatalog
        case .int: .scpIntCatalog
        default: nil
        }
    }

    static func badge(forMultiform kind: SCPArticleFeedKind) -> GlobalSearchBadge? {
        switch kind {
        case .tales: .tale
        case .gois: .goi
        case .canons: .canon
        case .jokes: .joke
        default: nil
        }
    }
}

/// バックグラウンド検索後、MainActor で `id` を確定させるためのドラフト。
struct CatalogSearchHitDraft: Sendable, Equatable {
    let url: URL
    let badge: GlobalSearchBadge
    let title: String
    let subtitle: String
    let tags: [String]
}

/// ホーム横断検索の 1 行。
struct CatalogSearchHit: Identifiable, Sendable, Equatable {
    let id: String
    let url: URL
    let badge: GlobalSearchBadge
    let title: String
    let subtitle: String
    let tags: [String]
}

/// `JSONDecoder` をバックグラウンドで回すためのスナップショット（`Sendable`）。
struct CatalogSearchSnapshot: Sendable {
    struct SCPRow: Sendable {
        let urlString: String
        let title: String
        let id: String
        let tags: [String]
        let badge: GlobalSearchBadge
    }

    struct GenRow: Sendable {
        let urlString: String
        let title: String
        let author: String?
        let badge: GlobalSearchBadge
    }

    struct IndexedListRow: Sendable {
        let urlString: String
        let scpNumber: Int
        let articleTitle: String?
        let objectClass: String?
        let tags: [String]
    }

    let scpRows: [SCPRow]
    let genRows: [GenRow]
    let indexedListRows: [IndexedListRow]
}
