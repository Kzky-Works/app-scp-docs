# 開発ルール: 記事データ（JSON）・関連スクリプト・元データの所在

**適用**: SCP docs（`scp_docs`）およびデータ配信リポジトリの開発全般。今後の変更もこの方針に従う。

## Git 上の原本（合意事項）

- **原本（正）**は、**各リポジトリの GitHub 上 `main` ブランチにマージされた内容**とする。ローカルは作業中の仮の状態であり、**原本を更新する**にはリモートの **`main` に必ず到達**させる（プッシュ、または PR 経由のマージ）。
- **[Kzky-Works/app-scp-docs](https://github.com/Kzky-Works/app-scp-docs)**（本リポ）の **`contrib/data-scp-docs/`** は、ハーベスタ等の**作業用ディレクトリ**である。ここを編集した内容を**原本とする**には、**本リポの `main` へ push（メンテが実行）**する。未 push の手元だけでは原本ではない。

## 配信アーティファクトの置き場と原本

- **記事系の配信 JSON、カタログ、収集用の共有スクリプト、元データ**（生 HTML サンプル、中間 CSV、手作業メモ等）の**格納庫**は **[data-scp-docs](https://github.com/Kzky-Works/data-scp-docs) リポジトリ**とする。  
- 上記の**原本**は **data-scp-docs の GitHub `main`** 上のツリーである。`list/jp` の JSON、`docs/catalog` 等の取得先は常に**そのリポの `main` が指す内容**（アプリはリモート取得）。

ここでいう「記事データ」には、少なくとも次が含まれる。

- 報告書マニフェスト（例: `list/jp/manifest_scp-*.json`）および 3 系統フィードのソース
- マルチフォーム一覧（Tales / GoI / Canon / Joke の manifest）
- Wikidot カタログ（例: `docs/catalog/*.json`）およびそのビルド入力
- タグ一覧・記事逆引きマップ（例: `list/jp/jp_tag.json`）と **`build_jp_wikidot_tag_article_map.py` 等**
- 上記を生成・検証する **`scripts/`** 。CI は **app-scp-docs** の **`.github/workflows/`** から起動し、**data-scp-docs** の `list/jp` 等へ push（シークレット `DATA_SCP_DOCS_PUSH_TOKEN`）。ジョブは**本リポ**の `contrib/data-scp-docs/scripts` を参照する（原本は手元作業のあと本リポ `main` に乗る）。

## `scp_docs`（アプリリポジトリ）側の扱い

- **同梱・長期保管しない**: 配信 JSON の**コピー**を `scp_docs` 内に重ねて正としない（取得はリモートのみ）
- **`Research/` 等の参考資料**: ローカル研究用。**配信パイプラインの原本入力**ではない
- **アプリの責務**: リモート URL から取得・キャッシュ（`SCPArticleTrifoldSyncService` / `WikiCatalogSyncService` 等）に留める
- **`contrib/data-scp-docs/`** は**作業用**である（上記「Git 上の原本」）。data-scp-docs 側の `scripts/` と**内容を揃えたい**場合は、**data-scp-docs の `main` に**反映する手順（コピー・PR 等）に従う。CI は app の `contrib` から走るため、**本リポの `main` に作業内容が乗っていない**と CI と手元の食い違いが生じる

## 新規作業の手順（要約）

1. 配信 JSON や `docs/catalog` の**原本**は **data-scp-docs の `main`**。**app-scp-docs 側**でスクリプトを直すのは `contrib/...` を編集し、**`main` へ push**。必要なら **data-scp-docs** の同パス（`scripts/` 等）へ**手で同期**し、そちらも **`main` を更新**。**収集用ワークフロー**の追加・変更は **app-scp-docs** の `.github/workflows/`
2. アプリ側の変更が必要なのは **URL・スキーマ消費・型** に限る（必要なら `docs/APP_SPEC_HANDOVER_ja.md` や `AppRemoteConfig`）
3. 旧パスや重複に気づいたら、**各リポの `main` で一つに**整理する（どちらを残すかは上記の置き場の節に従う）

## 参照

- アプリからの取得先: `docs/APP_SPEC_HANDOVER_ja.md` §7
- Tales / Canon 等の収集詳細: `docs/HANDOVER_TALES_CANON_COLLECTION_RULES_ja.md`
