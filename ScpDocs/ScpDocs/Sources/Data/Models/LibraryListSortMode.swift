import Foundation

/// ライブラリ一覧（静的ハブ）の並べ替え。カテゴリごとに `UserDefaults` で保持する。
enum LibraryListSortMode: String, CaseIterable, Identifiable, Sendable {
    /// サイトの掲載順（`wikiCreationOrder` 昇順）
    case wikiOrder = "wiki"
    /// 表示タイトル（ローカライズ後）の昇順
    case titleAscending = "title_asc"
    case titleDescending = "title_desc"
    /// `wikiCreationOrder` 降順（大きいほど新しい想定）
    case newestFirst = "newest"
    case oldestFirst = "oldest"
    /// 主著者キー（`primaryAuthorSortKey`）の昇順。未設定はタイトル扱い。
    case primaryAuthorAscending = "author_asc"
    /// 同一主著者キーがリスト内に何件あるか（多い順）。キー未設定は末尾。
    case primaryAuthorHubCountDescending = "author_hub_count"

    var id: String { rawValue }

    var localizationKey: String {
        switch self {
        case .wikiOrder: LocalizationKey.librarySortWikiOrder
        case .titleAscending: LocalizationKey.librarySortTitleAsc
        case .titleDescending: LocalizationKey.librarySortTitleDesc
        case .newestFirst: LocalizationKey.librarySortNewest
        case .oldestFirst: LocalizationKey.librarySortOldest
        case .primaryAuthorAscending: LocalizationKey.librarySortAuthorAsc
        case .primaryAuthorHubCountDescending: LocalizationKey.librarySortAuthorHubCount
        }
    }
}
