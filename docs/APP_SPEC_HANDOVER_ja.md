# SCP docs — アプリ仕様引継書（別チャット用）

最終更新目安: 2026-04-19。リポジトリ: `scp_docs`（Xcode プロジェクトは `ScpDocs/ScpDocs.xcodeproj`）。

---

## 1. プロダクト概要

- **名称**: SCP docs（バンドル ID 例: `com.scpreader.app.scpdocs`）
- **目的**: SCP Foundation 系 Wikidot サイトを **ネイティブアプリ内 WebView** で閲覧するビューア。支部切替、報告書ジャンプ、ライブラリ静的リスト、オフラインスナップショット、既読・ブックマーク等を提供。
- **対象 OS**: **iOS 17.0+**（SwiftUI のみ。Flutter 等は禁止／`.cursorrules` 参照）。

---

## 2. 技術スタック

| 項目 | 内容 |
|------|------|
| 言語 | Swift 6 系 |
| UI | SwiftUI、`NavigationStack` + `NavigationPath` |
| 状態 | `Observation`（`@Observable`）、`@Bindable` |
| 非同期 | `async` / `await` |
| Web | `WKWebView`（`UIViewRepresentable`）、記事用に `CleanUI.js` 注入で Wikidot ヘッダ等を除去 |
| 広告 | Google Mobile Ads（バナー。テスト ID が Constants にある） |
| IAP | StoreKit 系ラッパ（`PurchaseRepository`、広告削除 SKU） |

**ViewModel 方針**: `Sources/ViewModels/` は **SwiftUI/UIKit を import しない**（将来の Android/Kotlin 移植を意識）。

---

## 3. アーキテクチャ（ディレクトリ）

プロジェクト憲法（`.cursorrules`）に沿った配置:

- `Sources/Core/` — `Constants.swift`（`LocalizationKey` 集約）、`Theme.swift`（`AppTheme`）、ハプティクス等
- `Sources/Data/Models/` — 支部、ルート、カテゴリ、`SCPJPSeries`、`SCPListRemotePayload` 等
- `Sources/Data/Repositories/` — `ArticleRepository`、`SettingsRepository`、`PurchaseRepository`、`SCPListCacheRepository`、`JapanSCPListMetadataStore` 等
- `Sources/Data/Services/` — `WebViewService`、`OfflineStore`、`ConnectivityMonitor`、`ContentGateway`、`SCPListSyncService`
- `Sources/Data/Resources/` — `LibraryStaticData`、`JapanSCPArchiveTitleData`（埋め込みタイトル辞書）、`GoIFormatsIndexData`
- `Sources/ViewModels/` — `HomeViewModel`、`WebViewModel`、`NavigationRouter`
- `Sources/Views/Screens/` / `Widgets/` — 各画面・`SCPWebView`、`AdBannerView`
- `Resources/Localization/` — `en.lproj` / `ja.lproj` の `Localizable.strings`
- `Resources/Injections/` — `CleanUI.js`

---

## 4. アプリ構造（タブとエントリ）

- **エントリ**: `ScpDocsApp.swift` が `HomeViewModel`、`NavigationRouter`（ホーム／書庫各一つ）、`ArticleRepository`、`PurchaseRepository`、`SCPListCacheRepository`、`JapanSCPListMetadataStore` を保持し、`MainView` に渡す。
- **タブ**（`AppRootTab`）: **ホーム** / **書庫** / **設定**。それぞれ `NavigationStack`（設定は単純スタック）。

---

## 5. ナビゲーション

- **ルート型**: `NavigationRoute`（`NavigationRoute.swift`）。`NavigationRouter` が `NavigationPath` を保持。
- **主なケース**:
  - `archiveIndex(branchId:)` — 支部別「報告書アーカイヴ」インデックス
  - `scpJapanArchiveSeries` — JP シリーズ JP-I〜V の選択
  - `scpJapanArchiveArticles(seriesOrdinal:)` — シリーズ内 100 件ブロックの報告書一覧（`SCPJPSeries.rawValue`）
  - `libraryIndex` / `libraryList(LibraryCategory)` — 物語・カノン・連作・GoI 等
  - `goiFormatsIndex` / `goiPortal`
  - `category(URL)` / `article(URL)` — Wikidot ページを `ArticleView` で表示

`MainView.articleDestination` が `NavigationRoute` を各 `View` にマッピングする。

---

## 6. 主要画面と挙動

### 6.1 ホーム（`HomeView`）

- 選択中 **支部**（JP / EN / INT）の表示名・ベース URL。
- **ランダム SCP**（現在支部・国際ハブ用 URL は `Branch` / `HomeViewModel` 経由）。
- **ダッシュボード 6 タイル**（`HomeSection`）: JP アーカイヴ、EN アーカイヴ、SCP ライブラリ、国際、ガイド、イベント。タップで該当フローへ `push`。
- **検索**: プレースホルダは「SCP 番号ジャンプ」系。送信時に `NavigationRouter.pushJumpToSCPIfPossible` で可能なら該当記事 URL へ。

### 6.2 日本支部アーカイヴ（深さ例）

1. `ArchiveIndexView` — 支部に応じたアーカイヴ入口  
2. `ArchiveSeriesListView` — `SCPJPSeries`（JP-I〜V、番号レンジ 001〜4999）  
3. `ArchiveArticleListView` — **100 件セグメント**切替 + リスト。各行 **SCP-XXX-JP** と **タイトル**（下段キャプション）、既読・ブックマークアイコン。ツールバーから Wikidot 一覧ページを Safari 系で開く導線あり。

**タイトル解決の優先順位**（実装の要点）:

1. **リモート同期キャッシュ**（`JapanSCPListMetadataStore` / UserDefaults に保存した `scp_list` 由来）
2. **埋め込み** `JapanSCPArchiveTitleData`（HTML から抽出した静的辞書）
3. どちらも無い場合は UI 側で **`[DATA UNKNOWN]`**（`LocalizationKey.archiveJpArticleTitleUnknown`）

### 6.3 書庫（`LibraryView`）

- セグメント: **お気に入り** / **履歴**（`ArticleRepository`）。
- 別経路: `LibraryIndexView` → カテゴリ → `LibraryListView`（`LibraryStaticData` の静的 `LibraryItem`、検索・並べ替え、既読・ブックマーク表示）。

### 6.4 記事（`ArticleView`）

- `WKWebView` で URL 表示。`WebViewModel` が `CleanUI.js` 注入、フォント倍率、オフラインスナップショット、`ConnectivityMonitor` 連携。
- ツールバー: ブックマーク、共有等。既読はリポジトリが管理。

### 6.5 設定（`SettingsView`）

- 支部、UI 言語、記事フォントサイズ、広告削除 IAP、履歴・ブックマーク・Web キャッシュ削除、WebView デバッグ系トグル、ライセンス表記など。

---

## 7. データと永続化

| 領域 | 実装 |
|------|------|
| 設定 | `SettingsRepository` → `UserDefaults`（支部 ID、フォント倍率、UI 言語、ライブラリ並べ替え） |
| 既読・履歴・ブックマーク | `ArticleRepository` → `UserDefaults` |
| オフライン HTML | `OfflineStore` → Application Support 配下にスナップショット保存 |
| JP 一覧タイトル（リモート） | Phase 13: `SCPListSyncService` が HTTPS の `scp_list.json` を取得し、`SCPListCacheRepository` に JSON 保存。`JapanSCPListMetadataStore` が参照。**URL 未設定時は同期しない**（`AppRemoteConfig.scpListJSONURLString` が空）。 |
| 埋め込みタイトル | `JapanSCPArchiveTitleData.swift`（ビルド時同梱） |

**リモート一覧 JSON** のサンプル・スキーマは `Research/scp_list.json` を参照。`listVersion` を上げるたびにクライアントがマージ取り込み（詳細は `SCPListSyncService`）。

---

## 8. デザイン

- **テーマ**: Matte Black `#121212`、`AppTheme.backgroundPrimary`
- **アクセント**: Satin Silver `#C0C0C0`、`AppTheme.accentPrimary`
- ダークモード前提（各所で `preferredColorScheme(.dark)` 等）

---

## 9. ローカライズ

- UI 文字列は **`LocalizationKey`（`Constants.swift`）と `Localizable.strings`（en / ja）のペア**。画面に英語を直書きしない。
- `HomeViewModel.resolvedLocale` が UI 言語設定に応じて `Locale` を切替。

---

## 10. 静的コンテンツの扱い

- **ライブラリ中間階層**（物語・カノン・連作など）: `LibraryStaticData` + `LibraryItem`（`titleLocalizationKey`、任意で注入用 `title`）。
- **GoI**: `GoIFormatsIndexData` 等で URL とローカライズキーを保持。
- **JP 報告書シリーズ**: `SCPJPSeries` が番号レンジ・Wikidot 一覧 URL・記事 URL スラグ規則を定義。

---

## 11. 開発時の注意（コードベースから）

- Wikidot は **https → http の 301** があり、`Info` 側で ATS 例外がある（`Branch.swift` コメント参照）。
- **Research/** 配下に HTML テキストや `scp_list.json` サンプルがあり、一覧タイトル抽出やリモートスキーマの参考になる。
- 新規ファイルは **`.cursorrules` のディレクトリ規約**に合わせること。

---

## 12. この引継書に含めない／未確定のこと

- App Store 掲載文言、プライバシーポリシー本文。
- 本番 AdMob / IAP プロダクト ID の確定値（テスト用定数がコードに残っている可能性）。
- リモート `scp_list.json` の**本番ホスト URL**（`AppRemoteConfig` を書き換えて有効化する運用）。**一覧 JSON の生成スクリプト**（`update_list.py`）は **[data-scp-docs](https://github.com/Kzky-Works/data-scp-docs)** リポジトリの `scripts/` が正（本アプリリポには同梱しない）。

---

以上を別チャットに貼り、必要なら「変更したい画面」「参照ファイルパス」を追記すると会話がスムーズです。
