# 引き継ぎ: マルチフォーム一覧（Tales / GoI / Canon / Joke）とタグ・オブジェクトクラス収集ルール（次チャット用）

**作成日**: 2026-04-24（GoI・Joke・タグ／オブジェクトクラス節を追記）  
**リポジトリ**: [scp_docs](https://github.com/Kzky-Works/scp_docs)（本書は主にこのリポジトリの文脈。配信データの生成は **[data-scp-docs](https://github.com/Kzky-Works/data-scp-docs)** が正）。  
**前提ドキュメント**: 全般仕様は `docs/APP_SPEC_HANDOVER_ja.md`（2026-04-24 更新版）を参照。

---

## 1. このチャットでやること（ゴール）

次を **data-scp-docs のハーベスト／生成ルールと scp_docs の前提**として揃え、文書化する。

1. **マルチフォーム一覧**（`SCPArticleFeedKind` の `.tales` / `.gois` / `.canons` / `.jokes`）
  - 各カテゴリについて、**何をどの Wikidot ソース（一覧・タグ・ハブ・カテゴリ）から集め、どの JSON に載せるか**。  
  - **GoI**（`manifest_gois.json`）および **Joke**（`manifest_jokes.json`）も **Tales / Canon と同列**にスコープ・インクルード条件・除外・ソートを定義する。
2. **タグ（tags）とオブジェクトクラス（object class）**
  - **収集元**（Wikidot ページメタ、カテゴリ、別 API、手動オーバーライドなど）と、**どの配信物のどのフィールドに書くか**を確定する。  
  - **報告書（JP / メイン和訳 / INT）**と **Joke 報告書**、**マルチフォーム一般記事**でルールが異なるなら **分岐表**に落とす。
3. **二系統 JSON（マニフェスト系 vs `docs/catalog` 系）の役割分担**
  - タグ／オブジェクトクラスを **片方にだけ載せる／両方に載せる場合の優先順位**（アプリの参照先は種別ごとに異なる。§3・§4 参照）。

必要に応じて **`AppRemoteConfig` のパス**、`SCPGeneralContent` / `SCPArticle` / `WikiCategoryCatalogEntry` の解釈、検索インデックス（`GlobalCatalogSearchEngine`）の拡張を scp_docs 側で追従する。

---

## 2. 直前までの作業コンテキスト（scp_docs）

以下は **別スレッドで完了済み** の前提。重複実装しないこと。


| 項目                | 内容                                                                                                                                                       |
| ----------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 旧 `scp_list.json` | **廃止**。取得・同期ロジックは削除済み。                                                                                                                                   |
| 報告書 3 系統          | `list/jp/manifest_scp-jp.json` 等を `SCPArticleTrifoldSyncService` が取得し `SCPArticleFeedCacheRepository` に保存。                                               |
| Wikidot カタログ      | `docs/catalog/*.json` を `WikiCatalogSyncService` が取得し **`WikiCatalogCacheRepository`** に保存。`JapanSCPListMetadataStore` が **一部種別**のタグ・オブジェクトクラスに利用（§4.1）。 |
| 起動時               | `MainView.task` で Wiki カタログ同期 → トリフォールド／マルチフォーム同期の後に `japanSCPListMetadataStore.reloadFromCache()` を呼び、フィード更新後の索引を反映。                                    |


---

## 3. マルチフォーム（Tales / GoI / Canon / Joke）まわりの「現状」（アプリが前提としているデータ経路）

### 3.1 経路 A: マルチフォーム一覧（一覧 UI・横断検索の「一般記事」行）

- **サービス**: `MultiformContentSyncService`（`Sources/Data/Services/MultiformContentSyncService.swift`）  
- **取得**: `SCPGeneralContentCatalogRepository` → `AppRemoteConfig.resolvedMultiformArchiveJSONURL(kind:)`  
- **キャッシュ**: `SCPArticleFeedCacheRepository` の **general multiform**（`loadPersistedGeneralMultiformPayload` 系）  
- **モデル**: `SCPGeneralContent` / `SCPGeneralContentListPayload`（`Sources/Data/Models/SCPGeneralContent.swift`）。`schemaVersion` は `AppRemoteConfig.supportedSCPGeneralContentFeedSchemaVersions`（現状 1 と 2=マニフェスト）で検証。

**マルチフォーム配信パス（`Constants.swift` の `AppRemoteConfig`）**


| `SCPArticleFeedKind` | パス定数                          | 備考                          |
| -------------------- | ----------------------------- | --------------------------- |
| `.tales`             | `list/jp/manifest_tales.json` | 報告書マニフェストと同じ `list/jp/` 配下。 |
| `.gois`              | `list/jp/manifest_gois.json`  | 同上。                         |
| `.canons`            | `list/jp/manifest_canons.json`          | 旧 **`canons.json`（直下）は配信しない**（§13.1）。 |
| `.jokes`             | `list/jp/manifest_jokes.json`           | 旧 **`jokes.json`（直下）は配信しない**（§13.1）。 |


**ホームからの導線**: `HomeView` の Tales / GoI / Canon / Joke タイルは `NavigationRoute.scpArticleCatalogFeed(...)` → フィード種別に応じた一覧（`SCPArticleFeedListView` 等）。  
**横断検索**: `CatalogSearchSnapshotBuilder` が `SCPArticleFeedKind.allCases where kind.isMultiformArchiveFeed` を **4 種すべて**走査し、`genRows` に載せる（`GlobalCatalogSearchEngine`）。現状 `GenRow` は **タイトル・URL・著者**中心で、タグ配列は検索マッチに未使用（`tags: []`）。タグで横断検索したい場合は **スナップショット生成側の拡張**が必要。

### 3.2 経路 B: Wikidot カテゴリカタログ（`WikiCategoryCatalogPayload`）

- **サービス**: `WikiCatalogSyncService`（**`WikiCatalogKind.allCases` をすべて同期**）  
- **ファイル名**（`WikiCategoryCatalogPayload.swift` の `WikiCatalogKind`）:


| `WikiCatalogKind` | ファイル名（`docs/catalog/` 相当 URL） |
| ----------------- | ----------------------------- |
| `.scpJp`          | `scp_jp.json`                 |
| `.scpMainlist`    | `scp.json`                    |
| `.joke`           | `joke.json`                   |
| `.tales`          | `tales.json`                  |
| `.canon`          | `canon.json`                  |
| `.goi`            | `goi.json`                    |


- **キャッシュ**: `WikiCatalogCacheRepository`  
- **現状の利用箇所（アプリ）**: `JapanSCPListMetadataStore.reloadWikiCatalogIndexes()` は **`.scpJp` / `.scpMainlist` / `.joke` のみ**を読み、報告書アーカイヴ一覧のタグ・オブジェクトクラスに利用。  
  **`.tales` / `.canon` / `.goi` は同期されるが、当該ストアでは未参照**（一覧・検索の一般記事は経路 A が主）。  
→ 収集ルールでは、**カタログ JSON を「タグ・OC の正」とするか、「一覧用マニフェストの補助」に限定するか**を明示すると、data-scp-docs と scp_docs の責務がぶれない。

### 3.3 経路 C: 財団 Tales-JP（Wikidot HTML 直読み）

- **画面**: `FoundationTalesJPIndexView` + `FoundationTalesJPRepository`  
- **データ**: `https://scp-jp.wikidot.com/foundation-tales-jp` を取得してパース。**data-scp-docs の JSON とは独立**。  
- Canon ハブ URL 等は `Branch.talesCanonHubURL()`（`Branch.swift`）に定義。  
- **書庫の静的リスト**: `LibraryStaticData`（物語・カノン JP の並びは `research/html_canon-jp.txt` に準拠するコメントあり）。

---

## 4. タグ・オブジェクトクラス — アプリ側の前提と「確定させること」

### 4.1 消費箇所の対応表（現状実装）


| データソース          | 型・フィールド                                                                | 主な利用箇所                                                                                                    |
| --------------- | ---------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| 報告書マニフェスト（3 系統） | `SCPArticle` の `g`（タグ）、`c`（オブジェクトクラス相当・任意）、`o`（任意）                     | トリフォールド一覧・`CatalogSearchSnapshotBuilder` の `scpRows`（タグも検索対象）                                             |
| Wikidot カタログ    | `WikiCategoryCatalogEntry` の `tags`, `objectClass`, `tagsSyncedAt`     | `JapanSCPListMetadataStore` が **scp_jp / scp（メイン和訳）/ joke** についてマージキー単位で索引化し、**報告書アーカイヴ**のタグフィルタ・OC 表示に利用 |
| マルチフォーム一覧（4 種）  | `SCPGeneralContent` の `g`（タグ）、`a`（著者）、`o`（出典等）。**`c`（オブジェクトクラス）は型に無い** | 一覧 UI・`genRows`（横断検索は現状タイトル・URL・著者）。タグの UI 露出は画面による |


**決定すべきルール（data-scp-docs 側で明文化）**

1. **報告書（JP / メイン和訳 / INT）**
  - タグ・OC を **Wikidot カタログのみ**とするか、**マニフェストの `g` / `c` のみ**とするか、**両方出す場合の優先順位**（重複・矛盾時）。  
  - `WikiCategoryCatalogEntry.tagsSyncedAt` を **鮮度の判断**に使うか。
2. **Joke 報告書**
  - `docs/catalog/joke.json` と **マルチフォーム `manifest_jokes.json`** の関係（スコープが異なる場合の説明責任）。アーカイヴの OC/タグは現状 **カタログ `joke` のみ**メタストアが参照。
3. **Tales / GoI / Canon / Joke（一般記事）**
  - マニフェストの `SCPGeneralContent.g` を **どう収集するか**（Wikidot ページタグの生データか、正規化済みか、ブラックリスト）。  
  - **オブジェクトクラス**を一般記事に持たせるか（型上は `c` 無し）。持たせるなら **スキーマ拡張**と scp_docs のデコード変更が必要。  
  - 別途 **`docs/catalog/tales.json` / `canon.json` / `goi.json`** にタグ・OC を載せる場合、**一覧（経路 A）と検索がどちらを読むか**。
4. **正規化ポリシー**
  - タグの大小文字、`_` 置換、システム用タグの除外、日本語タグの扱い。  
  - オブジェクトクラス文字列の **許容列挙**（`Safe` / `Euclid` / `Keter` / `Thaumiel` / `Explained` / `Neutralized` 等）と **未判定・多段階**の表現。
5. **検索**
  - マルチフォームのタグを **横断検索に含めるか**。含めるなら `CatalogSearchSnapshotBuilder` の `GenRow` と `rowMatchesGen` の拡張方針。

---

## 5. 「収集ルール」を決めるときの論点（チェックリスト）

data-scp-docs 側のスクリプト・CI とセットで決めるとよい論点を列挙する。

### 5.1 スコープ・ソース（マルチフォーム 4 種共通 + 種別固有）

1. **スコープ**
  - **Tales**: 日本支部のみか、本家／INT まで含めるか。  
  - **GoI**: フォーマット別・支部別の境界。  
  - **Canon**: ハブ列挙のみか、全カノンページか、JP カノンのみか。  
  - **Joke**: JP Joke のみか、本家ジョークとの併記か。
2. **ソース・オブ・トゥルース**
  - Wikidot 一覧 HTML、ページメタ、カテゴリタグ、ハブの手動リスト、既存 JSON など、**カテゴリごとの正**。
3. **経路 A と B の重複**（§4 と重複するが要約）
  - 同一 URL が `manifest_*.json` と `docs/catalog/*.json` に両方出るときの **タイトル・タグ・OC の優先**。
4. **Canon / Joke の配信パス**
  - **`list/jp/manifest_canons.json`** / **`list/jp/manifest_jokes.json`** のみ。**旧 `canons.json` / `jokes.json`（データホスト直下）は配信しない（即廃止）**（§13.1）。`AppRemoteConfig` の `*ListJSONPathComponent` と data-scp-docs のデプロイを同時更新。
5. **マニフェスト短縮キー**
  - **報告書**: `SCPArticle` の `u` / `i` / `t` / `c` / `o` / `g`。  
  - **一般記事**: `SCPGeneralContent` の `u` / `t` / `a` / `o` / `g` / `i`（安定 ID・任意）。  
  - `i` を必須にするかはマージ・差分更新に影響。
6. **`listVersion` とマージ**
  - `MultiformContentSyncService` はリモート `listVersion` が大きいときのみマージ保存。運用は **§13.2**。
7. **支部・言語**
  - ホームは支部切替あり。各 JSON が **JP 専用か混在か**（検索バッジ `GlobalSearchBadge` との対応）。
8. **検証**
  - 必須フィールド、URL 正規化、タグ／OC のスキーマ検証を CI に載せるか。

---

## 6. scp_docs で触る可能性が高いファイル（ルール変更後）


| 領域              | パス                                                                                          |
| --------------- | ------------------------------------------------------------------------------------------- |
| URL・スキーマ定数      | `ScpDocs/ScpDocs/Sources/Core/Constants.swift`（`AppRemoteConfig`）                           |
| マルチフォーム同期       | `Sources/Data/Services/MultiformContentSyncService.swift`                                   |
| 取得のみ            | `Sources/Data/Repositories/SCPGeneralContentCatalogRepository.swift`                        |
| ペイロード型          | `Sources/Data/Models/SCPGeneralContent.swift`、`SCPArticle.swift`                            |
| メタストア・報告書 OC/タグ | `Sources/Data/Repositories/JapanSCPListMetadataStore.swift`                                 |
| 検索スナップショット      | `Sources/Data/Services/GlobalCatalogSearchEngine.swift`（末尾の `CatalogSearchSnapshotBuilder`） |
| カタログ種別          | `Sources/Data/Models/WikiCategoryCatalogPayload.swift`（`WikiCatalogKind`）                   |
| 一覧 UI           | `Sources/Views/Screens/SCPArticleFeedListView.swift` 等                                      |


---

## 7. data-scp-docs 側（別リポジトリ）で想定される作業

本リポジトリにはハーベスター本体を同梱しない運用のため、**収集ルールの実装の本体は data-scp-docs**（`docs/` 配信物、`list/` 配下マニフェスト、`scripts/`、GitHub Actions）になる想定。  
**実装スクリプトの反映候補**は scp_docs 同梱の [`contrib/data-scp-docs/`](../contrib/data-scp-docs/README.md) に置き、同内容を **Kzky-Works/data-scp-docs** へコピーしてコミットする。

- **マルチフォーム 4 種**それぞれについて、インクルード条件・除外・ソート・`listVersion` バンプ方針をドキュメント化する。  
- **`docs/catalog/*.json`** について、§4 の **タグ／オブジェクトクラス**の収集元とフィールド割当を **種別ごと**に定義する。  
- 配信パスを変える場合は、**scp_docs の `AppRemoteConfig` と同じコミット／デプロイ順**を決める。

---

## 8. 次チャットへの依頼文（コピペ用）

以下をそのまま次スレッドの冒頭に貼れる。

```text
リポジトリ: scp_docs。前提: docs/HANDOVER_TALES_CANON_COLLECTION_RULES_ja.md と docs/APP_SPEC_HANDOVER_ja.md を読んでください。

目的:
(1) Tales / GoI / Canon / Joke のマルチフォーム一覧について、data-scp-docs での収集ルール（ソース、スコープ、経路 A/B の役割、listVersion、§13 の配信規約）を定義する。
(2) タグおよびオブジェクトクラスについて、報告書（3 系統＋ joke カタログ）とマルチフォーム一般記事と Wikidot カタログのどれを正とするか・正規化方針を確定し、必要なら scp_docs のモデル・検索・JapanSCPListMetadataStore を追従させる。

現状: マルチフォームは MultiformContentSyncService + SCPGeneralContentListPayload。Tales/GoI は list/jp/manifest_*.json、Canon/Joke はホスト直下。Wikidot カタログは WikiCatalogSyncService が全 kind 同期。JapanSCPListMetadataStore は scp_jp / scp / joke カタログのみでタグ・OC を参照。SCPGeneralContent に OC 用フィールドは無い。
```

---

## 9. Tales — 収集ルール（確定案・2026-04-24）

data-scp-docs のハーベスト実装および `manifest_tales.json` 生成の前提とする。

### 9.1 SoT（ソース・オブ・トゥルース）


| 優先  | URL                                             | 備考         |
| --- | ----------------------------------------------- | ---------- |
| 1   | `http://scp-jp.wikidot.com/foundation-tales-jp` | 日本支部物語ハブ   |
| 2   | `http://scp-jp.wikidot.com/foundation-tales`    | 本家物語（翻訳）ハブ |


公式ページでは下部などに **横方向のピッカー**で JP と EN（翻訳）表示を切り替えられる。**収集対象**は、上記いずれかの SoT ページ上に **実際に表示されている記事行をすべて含める**（ピッカーで切り替わる別表示は、取得時に両方の HTML をカバーするか、クライアント側で同等の一覧 API が無いため **ハーベスト側で両ビューを走査**する想定）。

### 9.2 スコープ・境界

- **含める**: 上記 SoT の表に現れるすべての物語リンク（ユーザー指示: ページに表示される記事はすべて含める）。
- **除外**: 別途ブラックリストは未定。システム行・空行はパース時に捨てる。

### 9.3 フィールド対応（`SCPGeneralContent` 短縮キー）


| キー  | ルール                                                                                                                                    |
| --- | -------------------------------------------------------------------------------------------------------------------------------------- |
| `u` | 物語記事の **絶対 URL**（`https://scp-jp.wikidot.com/...` に正規化推奨）。                                                                             |
| `t` | **和名**。ハブの `wiki-content-table` における **第1列のリンクテキスト**（例: `コード・ブラウン`）。                                                                   |
| `a` | **著者**。著者見出し行の直後から、次の著者見出し行の手前までに現れる記事は、**直前の著者見出し**に属する。著者名は `<th>` 内の `printuser` リンクテキスト、または `img` の `alt`（例: `AdminBright`）から取得する。 |
| `o` | Tales では必須としない（カノン名・GoI 名は不要。将来必要なら拡張）。                                                                                                |
| `g` | 将来のタグ表示用。**現状アプリの Tales 一覧は `g` を表示しない**（§9.5）。ハーベストで埋めてもよい。                                                                           |
| `i` | **安定キー**: 原則として **記事の公式 URL 文字列**（`u` と同一でも可）。マージキーは `SCPGeneralContentCatalogRepository.normalizedURLKey` と整合すること。                    |


参考 HTML 構造（要約）: 著者ブロック先頭が `<th colspan="2">` 内の `printuser`、続く `<table class="wiki-content-table">` の各行が `<td><a href="...">和名</a></td>`。

### 9.4 ソート・`listVersion`

- 表示順は **公式ハブ上の出現順**を維持するか、URL 辞書順に正規化するかは data-scp-docs で決める（公式に合わせるなら出現順推奨）。
- `listVersion` は収集合図が変わったタイミングでバンプ（既存ポリシーに従う）。

### 9.5 経路 B（`docs/catalog/tales.json`）とマニフェストの役割 — **現状アプリの答え**

ユーザーの理解（「カタログはタグ専用で manifest と統合して最終一覧？」）に対する **実装ベースの整理**:

1. **`docs/catalog/tales.json` の中身**
  `WikiCategoryCatalogEntry` は `slug`, `url`, `title`, `objectClass`, `tags`, `tagsSyncedAt` 等を持つ（タグだけではない）。Tales 向けビルドがどのフィールドを埋めるかは data-scp-docs 次第。
2. **マルチフォーム Tales 一覧（ホーム → Tales タイル）**
  [`SCPGeneralContentListView`](ScpDocs/ScpDocs/Sources/Views/Screens/SCPGeneralContentListView.swift) は **`manifest_tales.json` 由来の `SCPGeneralContent` のみ**を表示（`t`・`a`・既読）。**`tales.json` カタログとは現状マージしていない**。
3. **`JapanSCPListMetadataStore`**
  Wikidot カタログを読むのは **`.scpJp` / `.scpMainlist` / `.joke` のみ**。**`.tales` は同期されるがこのストアでは未使用**（§3.2 参照）。報告書アーカイヴのタグ・OC には影響しない。
4. **横断検索**
  [`CatalogSearchSnapshotBuilder`](ScpDocs/ScpDocs/Sources/Data/Services/GlobalCatalogSearchEngine.swift) の `GenRow` は **`urlString`, `title`, `author`, `badge` のみ**（マルチフォームの `g` は検索に未接続）。

**結論（方針の提案）**


| 観点                              | どちらを正にするか（推奨）                                                                                                              |
| ------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| **「どの URL が Tales 一覧に載るか」**     | **マニフェスト（経路 A）** — SoT ハブの表に基づく。                                                                                           |
| **タグ（および将来 OC を Tales に載せる場合）** | **`docs/catalog/tales.json`（経路 B）をタグの正**にし、マニフェストの `g` は (i) 空のままにするか、(ii) ハーベスト時にカタログと同じタグを複製して検証用にするか、data-scp-docs で選択。 |
| **アプリで「カタログを正のタグ」にした一覧**        | **未実装**。必要なら URL（または `slug`）キーで `WikiCatalogCacheRepository.loadWikiCatalog(kind: .tales)` とマージする変更が scp_docs 側に必要。        |


「カタログが正」は **タグの意味での正**として採用しやすいが、**一覧の行セット**は現状コードでは **マニフェストのみ**が表示の SoT になっている、と理解すると齟齬がない。

---

## 10. Canon — 収集ルール（確定案・2026-04-24）

data-scp-docs のハーベスト実装、`list/jp/manifest_canons.json` および **`docs/catalog/canon.json`** の整合の前提とする。

### 10.1 SoT（ソース・オブ・トゥルース）

次の **インデックスページ**から、ページ内に記載されている **カノンハブ（および連作ハブ）へのリンク**を辿り、**リンク先の各ハブ URL** をマニフェストの 1 行とする（ハブ本文の再パースで子記事を列挙しない方針でもよいが、一覧に載せる URL の集合は下記 SoT 由来のリンク集合に一致させる）。


| 優先  | URL                                           | 備考                                                      |
| --- | --------------------------------------------- | ------------------------------------------------------- |
| 1   | `http://scp-jp.wikidot.com/canon-hub-jp#odss` | 日本支部カノン・ハブ索引（フラグメント付きでよい。取得時はフラグメント無し URL と同等に正規化してもよい） |
| 2   | `http://scp-jp.wikidot.com/canon-hub`         | 本家カノン索引（翻訳・本家カノン含むスコープの根拠）                              |
| 3   | `http://scp-jp.wikidot.com/series-hub-jp`     | 連作ハブ — **連作もカノン収集に含める**（ユーザー指示）                         |


### 10.2 スコープ

- **日本支部（scp-jp）に限らず**、上記 SoT に現れる **本家側カノン・連作**へのリンクも含める（リンク先 URL のホスト・パスで識別）。
- 重複リンク（同一ハブが複数 SoT に出る）は **正規化 URL で 1 行にマージ**する。

### 10.3 境界

- **含める**: 上記 SoT ページに **記載されているカノンハブ（および連作ハブ）へのリンクすべて**。
- **含めない**: 別途ブラックリストは未定。ナビ用・方針用の非ハブリンクを除外するルールは data-scp-docs で明示（例: `javascript:`、同一 SoT ページ自身、カテゴリ一覧のみ等）。

### 10.4 フィールド対応（`SCPGeneralContent`）

カノン一覧の各行は **「カノン（または連作）ハブの 1 ページ」**を指す。


| キー  | ルール                                                                                                                                                                            |
| --- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `u` | カノン／連作 **ハブの絶対 URL**（`https://scp-jp.wikidot.com/...` 等に正規化推奨。不要なフラグメントは除去可）。                                                                                                  |
| `t` | **和名のカノン（連作）ハブ名**。SoT 上のリンクテキスト、またはリンク先ページの表示タイトルから取得（例: `canon-hub` のアンカー `#toc0` 相当が「死人の手札」になる運用に合わせる）。                                                                      |
| `a` | **対象外**（常に省略または空）。                                                                                                                                                             |
| `o` | **対象外**（常に省略または空）。                                                                                                                                                             |
| `g` | **経路 B 全面「カタログを正」**（§10.5）に従い、一覧表示用タグは **`canon.json` を正**とする。マニフェストに `g` を複製するかは data-scp-docs の選択（アプリが未マージの間は manifest に載せた方が一覧だけで完結する）。 |
| `i` | **推奨**: Wikidot の **ページ ID** が取得できるなら `String(pageId)`（他フィードと揃えて数値文字列）。取得困難なら **`u` からフラグメントを除いた正規 URL** を安定キーとし、`SCPGeneralContentCatalogRepository.normalizedURLKey` と整合させる。 |


### 10.5 経路 B — **カタログを正（ユーザー決定・Canon）**

Canon については **すべて `docs/catalog/canon.json`（`WikiCatalogKind.canon`）を正**とする。

- **`WikiCategoryCatalogEntry`**: `slug`, `url`, `title`, `objectClass`, `tags`, `tagsSyncedAt` 等。タグ・補助タイトル・OC は **カタログの値を優先**し、マニフェストと矛盾する場合は **カタログを採用**（data-scp-docs でハーベスト順序または検証 CI を定義）。
- **マニフェスト `manifest_canons.json` の役割**: SoT ページから得た **ハブ URL の集合**と **表示用 `t`（和名）の初期値**（アプリ未マージ時のフォールバック）。**アプリ側でカタログと URL キー統合した後**は、一覧のタグ・タイトル上書きはカタログ準拠とする実装が望ましい（§9.5 の Tales と同様、**現状の `SCPGeneralContentListView` はカタログ未マージ**）。

### 10.6 アプリ製品要件（Canon 導線・未実装を含む）

以下は **製品仕様メモ**。実装状況はコードと照合すること。

1. **ハブ詳細**: カノン行をタップした先で、画面下部に **セグメントピッカー**（**カノン-JP** / **カノン** / **連作**）を置き、選択に応じて **該当する公式ハブ URL を `ArticleView`（WebView）でそのまま表示**する。ハブごとに Wikidot 側レイアウトが異なるため、**ネイティブでハブ本文を再現しない**方針。
2. **個別記事**: 上記 WebView 内のリンクから開いた **個別記事**は、他の SCP 記事と同様に閲覧し、**既読・履歴・ブックマーク等を通常どおり記録**する。
3. **続きから読む**: サマリー表示でオブジェクトクラス・SCP 番号等が **カタログ／マニフェストに無い場合は「-」** で表示する。

---

## 11. GoI — 収集ルール（確定案・2026-04-24）

data-scp-docs のハーベスト実装および `list/jp/manifest_gois.json`（既存パス）の前提とする。Canon（§10）と同様、**`docs/catalog/goi.json`（`WikiCatalogKind.goi`）をタグ・補助メタの正**とする想定を §11.5 に置く（別方針に差し替え可）。

### 11.1 SoT（ソース・オブ・トゥルース）


| 優先  | URL                                        | 備考                                                 |
| --- | ------------------------------------------ | -------------------------------------------------- |
| 1   | `http://scp-jp.wikidot.com/goi-formats-jp` | 日本支部 **GoI フォーマット**ハブ。ここに列挙される **要注意団体**を収集の起点とする。 |


本家 GoI は **上記ページからリンクされる**団体・フォーマットページを **スコープに含める**（§11.2）。

### 11.2 スコープ

- **日本支部の GoI-jp** と、当該 SoT から辿れる **本家 GoI（英語圏サイト上のフォーマット／団体ページ等）** を含める。
- 同一団体が JP / 本家で複数 URL を持つ場合は、**正規化 URL と `o`（団体キー）** で重複をマージするルールを data-scp-docs で定義する。

### 11.3 境界

- **含める**: 上記 SoT ページに **記載されている要注意団体（およびそれに対応するフォーマット一覧へのリンク）** をすべて含める。
- **含めない**: ナビ専用・方針文のみのリンクなど、**団体／フォーマット本体でない**リンクの除外ルールは data-scp-docs で明示する。

### 11.4 フィールド対応（`SCPGeneralContent`）

現行スキーマは **フラットなエントリ配列**のため、**団体名でグルーピングして折りたたみ表示**する UI（§11.6）は、次のいずれか（または併用）で実現する想定を data-scp-docs / scp_docs で選択する。


| 方式                           | 説明                                                                                                                                                                                                           |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| A（推奨・一覧の 1 行 = フォーマット／団体の入口） | 各行の `u` を **団体フォーマットの公式ページ URL**（またはハブ内アンカー先）、`t` を **和名**（一覧行タイトル）、`o` を **和名の団体名**（`Are We Cool Yet?` のような **団体の表示名**。日本語公式表記があればそれを優先）とする。**同一 `o` の複数行**で「関連フォーマット／別言語入口」を表現し、アプリは `o` でセクション折りたたみを構築する。 |
| B（子記事までフラット展開） | 各関連記事を別エントリとし、共通の **`o` に団体名**を付与。アプリは `o` グループの下に子行をぶら下げる。 |

| キー | ルール |
|------|--------|
| `u` | 要注意団体／フォーマットに対応する **絶対 URL**（`https://...` に正規化）。 |
| `t` | **和名**（SoT 上のリンクテキストまたは和訳タイトルに合わせる）。 |
| `a` | **対象外**（省略または空）。 |
| `o` | **和名の団体名**（グルーピング・ピッカー連携のキー。公式に英表記のみの団体は、その表記を `o` に用いてよい）。 |
| `g` | タグは **`goi.json` を正**（§11.5）。マニフェストに複製するかは data-scp-docs の選択。 |
| `i` | **推奨**: Wikidot **page ID** が取れるなら文字列化。無理なら **フラグメントを除いた正規 `u`**（§10.4 と同様）。 |

### 11.5 経路 B（`docs/catalog/goi.json`）

Canon（§10.5）と整合させ、**タグ・`title`・`objectClass` 等の補助メタは `goi.json` を正**とする。マニフェストは **SoT 由来の団体／フォーマット URL 集合**と **`t` / `o` の初期値**（アプリ未マージ時のフォールバック）。矛盾時はカタログ優先。

### 11.6 アプリ製品要件（GoI 一覧 UX・未実装を含む）

以下は **製品仕様メモ**。現状の [`SCPGeneralContentListView`](ScpDocs/ScpDocs/Sources/Views/Screens/SCPGeneralContentListView.swift) は **フラットリスト**のため、次は **別 UI または拡張**が必要。

1. **団体名ファースト**: 一覧は **団体名（`o` または導出ラベル）** を主見出しにし、**団体名タップで折りたたみを開閉**し、その下に **関連記事・関連フォーマット行**（方式 A/B に応じた `SCPGeneralContent` 行）を表示する。
2. **下部ピッカー**: 画面下に **横並びセグメント** — **GoI-JP** / **GoI** / **GoI-その他** — を置き、選択に応じて **表示対象の団体名・エントリをフィルタ**する（分類ルール: URL ホスト・パス規則・またはマニフェストに後から追加する `locale` / `tier` 等のフラグ。data-scp-docs で定義）。
3. **閲覧**: 子行・フォーマット行の URL は既存の **`ArticleView`（WebView）** で開き、既読・履歴等は他カテゴリと同様に記録する。

---

## 12. Joke — 収集ルール（確定案・2026-04-24）

data-scp-docs のハーベスト実装および **`list/jp/manifest_jokes.json`** の前提とする。scp_docs の `AppRemoteConfig.jokesListJSONPathComponent` は **`list/jp/manifest_jokes.json`** を指す（§3.1・§13.1）。配信とアプリをずらさないこと。

### 12.1 SoT（ソース・オブ・トゥルース）

| 優先 | URL | 備考 |
|------|-----|------|
| 1 | `http://scp-jp.wikidot.com/joke-scps` | ジョーク SCP（本家系の索引・一覧） |
| 2 | `http://scp-jp.wikidot.com/joke-scps-jp` | ジョーク SCP（日本支部オリジナル等の索引・一覧） |

### 12.2 スコープ

- **日本支部オリジナル**と **本家（翻訳・メインリスト系）**の両方を含める。上記 SoT ページに **実際に列挙されている記事リンク**がスコープの下限・上限になる。

### 12.3 境界

- **含める**: 上記 **両 URL のページに載っている記事をすべて**（ユーザー指示）。
- **除外**: 表外リンク・ナビのみ等の除外は data-scp-docs で明示。空行・壊リンクはパース時に捨てる。

### 12.4 フィールド方針 — **報告書マニフェスト（`manifest_scp-jp` / `manifest_scp-main`）と同趣旨に揃える**

ジョーク一覧はマルチフォーム用の [`SCPGeneralContent`](ScpDocs/ScpDocs/Sources/Data/Models/SCPGeneralContent.swift) を使うが、**収集・配信の意味論は [`SCPArticle`](ScpDocs/ScpDocs/Sources/Data/Models/SCPArticle.swift)（`u` / `i` / `t` / `c` / `o` / `g`）に揃える**。

| 報告書（`SCPArticle`） | Joke マルチフォーム（`SCPGeneralContent`）での扱い |
|------------------------|---------------------------------------------------|
| `u` 記事 URL | **同一**: 絶対 URL、報告書と同じ正規化方針。 |
| `i` 安定 ID | **同一**: Wikidot page ID 文字列を推奨（報告書と同じ）。 |
| `t` 一覧タイトル | **同一**: 和訳／支部表記の付け方を **JP 系・本家系報告書マニフェストと同じルール**で生成。 |
| `c` オブジェクトクラス | 報告書ではマニフェスト `metadata` に格納。**`SCPGeneralContent` 型に `c` は無い**（現状アプリ）。**正**: `docs/catalog/joke.json`（`WikiCatalogKind.joke`）の `objectClass`（`JapanSCPListMetadataStore` がジョーク報告書アーカイヴで既に参照）。マニフェストの `g` に OC 相当を載せない／載せるかは data-scp-docs で報告書ジョークと揃える。 |
| `o` 出典・系列 | **同一意味**で埋める（不要なら空）。 |
| `g` タグ | **同一**: 報告書と同じタグ正規化。**経路 B**: **`joke.json` を正**とし、マニフェストの `g` はカタログと整合させる（重複許容なら検証用に両方へ同内容）。 |
| 著者 | 報告書マニフェストに **著者キーは無い**。Joke も **`a` は省略または空**で報告書と揃える（`SCPGeneralContentManifestMetadata` に著者用キーがあるが、未使用でよい）。 |

**マニフェスト schema 2**: 報告書と同様 **`entries`（軽量 `u`/`i`/`t`）+ `metadata[i]`** で `g` / `o`（および将来 `c` 相当を載せる拡張が入る場合は data-scp-docs とアプリ型の合意）を載せる。

### 12.5 経路 B（`docs/catalog/joke.json`）

Canon / GoI と同様、**タグ・`objectClass`・`title` の鮮度は `joke.json` を正**とする。マニフェストは **SoT 由来の「どのジョーク URL が一覧に載るか」**と **報告書と同品質の `t` / `i` / `u`** のフォールバック。`JapanSCPListMetadataStore` は既に **ジョーク報告書アーカイヴ**で `joke` カタログを参照しており、マルチフォーム Joke 一覧と **URL キーで結合**する実装は **任意の将来拡張**（§9.5 参照）。

### 12.6 アプリ注意（現状）

[`SCPGeneralContentListView`](ScpDocs/ScpDocs/Sources/Views/Screens/SCPGeneralContentListView.swift) は **`t`・`a`・既読**中心。**OC・タグは一覧に未表示**。報告書と「見た目まで同一」にする場合は UI 拡張が別途必要。

---

## 13. 配信運用の確定（旧 JSON・`listVersion`）

### 13.1 旧 `canons.json` / `jokes.json`（データホスト直下）

**即廃止**。併用期間・301 リダイレクト・ミラー配置は **設けない**。

- 配信するのは **`list/jp/manifest_canons.json`** と **`list/jp/manifest_jokes.json`** のみ。
- GitHub Pages 等から **直下の `canons.json` / `jokes.json` を削除**してよい（参照されない前提）。
- scp_docs は **`Constants.swift` の `canonsListJSONPathComponent` / `jokesListJSONPathComponent`** を上記 `list/jp/` パスに合わせる（§3.1）。

### 13.2 `listVersion` と CI（運用ポリシー）

**CI** とは *Continuous Integration*（継続的インテグレーション）の略で、代表的には **GitHub Actions** のように、**プッシュや PR のたびに自動でスクリプトを実行**する仕組みを指す（テスト・リント・成果物のビルド・GitHub Pages へのデプロイ等）。

**`listVersion`**: [`MultiformContentSyncService`](ScpDocs/ScpDocs/Sources/Data/Services/MultiformContentSyncService.swift) は **リモートの `listVersion` がローカルより大きいときだけ**キャッシュをマージ更新する。データが変わったのに番号が上がらないと、クライアントは更新を取りに来ない。

**推奨（自動に近い運用）**

- data-scp-docs の **生成スクリプト**が、各 `manifest_*.json` について **`entries` の集合**（正規化 URL ソート後のシリアライズやハッシュ）を計算し、**前回生成物と差分があれば `listVersion` を 1 増やす**（またはビルド番号・タイムスタンプ由来の単調増加整数を採用）。  
- 上記を **GitHub Actions（CI）** の「データ生成ジョブ」に載せ、**手動バンプに依存しない**ようにする。手動バンプは取りこぼし・二重バンプのリスクがあるため **補助**に留めるのがよい。

**手動バンプのみ**にする場合は、リリースノートで「データ更新時は必ず `listVersion` を上げる」と運用ルール化する必要がある。

---

以上。ルール確定後は `APP_SPEC_HANDOVER_ja.md` の §7 テーブルに **マルチフォーム 4 種とタグ／OC のデータ源**を行で追記すると、以降の引き継ぎが楽になる。