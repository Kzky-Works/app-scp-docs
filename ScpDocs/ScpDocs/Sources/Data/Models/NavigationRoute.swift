import Foundation

/// アプリ内ナビゲーションの遷移先（`NavigationPath` に積む値）。
enum NavigationRoute: Hashable, Sendable {
    case home
    /// 報告書アーカイヴ（100 番ブロック）。`branchId` は `BranchIdentifier`（JP / EN など）。
    case archiveIndex(branchId: String)
    /// SCP-JP：シリーズ JP-I 〜 JP-V の選択。
    case scpJapanArchiveSeries
    /// SCP-JP：シリーズ内の報告書一覧（100 件セグメント）。`seriesOrdinal` は `SCPJPSeries.rawValue`。
    case scpJapanArchiveArticles(seriesOrdinal: Int)
    /// SCP ライブラリ（物語 / カノン / 連作）の中間階層。
    case libraryIndex
    /// 静的データに基づくライブラリ一覧（支部ごとに URL セットが切り替わる）。
    case libraryList(LibraryCategory)
    /// GoI フォーマット索引（`goi-formats-jp` 相当・日本支部向け）。
    case goiFormatsIndex
    /// 要注意団体ネイティブ一覧・人事ファイルへのハブ。
    case goiPortal
    case category(URL)
    case article(URL)
}
