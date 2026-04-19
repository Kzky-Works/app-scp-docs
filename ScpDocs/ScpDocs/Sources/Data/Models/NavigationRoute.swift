import Foundation

/// アプリ内ナビゲーションの遷移先（`NavigationStack` のパス配列に積む値）。
enum NavigationRoute: Hashable, Sendable {
    case home
    /// 報告書アーカイヴ（100 番ブロック）。`branchId` は `BranchIdentifier`（JP / EN など）。
    case archiveIndex(branchId: String)
    /// SCP-JP：001–4999 を 1000 刻み・100 刻みピッカーで閲覧。
    case scpJapanArchive
    /// 本家メインリストの日本語訳（scp-jp）：001–4999 を SCP-JP と同じピッカーで閲覧。
    case scpEnglishArchive
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
    case category(URL)
    case article(URL)
}

extension NavigationRoute {
    /// WebView で本文を表示しているルート（記事・カテゴリ一覧など）。下部ドックの縮小表示に使う。
    var isWebReaderSurface: Bool {
        switch self {
        case .article, .category:
            true
        default:
            false
        }
    }
}
