import Foundation

/// 日本支部／本家メイン和訳アーカイヴへの遷移パラメータ（タグ AND ・オブジェクトクラス）。
struct ScpArchiveListSeed: Hashable, Sendable {
    var tagFilters: Set<String>?
    var objectClassWikiTitle: String?

    init(tagFilters: Set<String>? = nil, objectClassWikiTitle: String? = nil) {
        self.tagFilters = tagFilters
        self.objectClassWikiTitle = objectClassWikiTitle
    }
}

/// アプリ内ナビゲーションの遷移先（`NavigationStack` のパス配列に積む値）。
enum NavigationRoute: Hashable, Sendable {
    case home
    /// 報告書アーカイヴ（100 番ブロック）。`branchId` は `BranchIdentifier`（JP / EN など）。
    case archiveIndex(branchId: String)
    /// SCP-JP：001–9999 をシリーズ / 100 刻みピッカーで閲覧。
    case scpJapanArchive(ScpArchiveListSeed)
    /// 本家メインリストの日本語訳（scp-jp）：001–9999 を SCP-JP と同じピッカーで閲覧。
    case scpEnglishArchive(ScpArchiveListSeed)
    /// SCP ライブラリ（物語 / カノン / 連作）の中間階層。
    case libraryIndex
    /// 静的データに基づくライブラリ一覧（支部ごとに URL セットが切り替わる）。
    case libraryList(LibraryCategory)
    /// GoI フォーマット索引（`goi-formats-jp` 相当・日本支部向け）。
    case goiFormatsIndex
    /// 要注意団体ネイティブ一覧・人事ファイルへのハブ。
    case goiPortal
    /// SCP-JP：新人職員向けガイド・規約ページへのネイティブ索引。
    case staffGuideIndex
    /// ホーム: 番号・タイトル・タグ・オブジェクトクラスで scp-jp 報告書を検索。
    case homeScpSearch
    /// 3 系統キャッシュ（`list/jp/` 配下の各フィード）から組み立てた一覧。
    case scpArticleCatalogFeed(SCPArticleFeedKind)
    /// 財団 Tales-JP（`foundation-tales-jp`）の著者別ネイティブ索引。
    case foundationTalesJPAuthorIndex
    case category(URL)
    case article(URL)
}

extension NavigationRoute {
    /// WebView で本文を表示しているルート（記事・カテゴリ一覧など）。下部ドックの縮小表示に使う。
    var isWebReaderSurface: Bool {
        switch self {
        case .article, .category:
            true
        case .scpArticleCatalogFeed:
            false
        default:
            false
        }
    }
}
