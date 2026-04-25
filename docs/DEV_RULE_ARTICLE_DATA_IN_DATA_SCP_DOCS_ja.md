# 開発ルール: 記事データ（JSON）・関連スクリプト・元データの所在

**適用**: SCP docs（`scp_docs`）およびデータ配信リポジトリの開発全般。今後の変更もこの方針に従う。

## 単一ソース・オブ・トゥルース

**記事系の配信 JSON、その生成・検証スクリプト、収集に用いる元データ（生 HTML サンプル、中間 CSV、手作業メモを含む）の正本は、すべて [data-scp-docs](https://github.com/Kzky-Works/data-scp-docs) リポジトリに置く。**

ここでいう「記事データ」には、少なくとも次が含まれる。

- 報告書マニフェスト（例: `list/jp/manifest_scp-*.json`）および 3 系統フィードのソース
- マルチフォーム一覧（Tales / GoI / Canon / Joke の manifest）
- Wikidot カタログ（例: `docs/catalog/*.json`）およびそのビルド入力・スクリプト
- タグ一覧・記事逆引きマップ（例: `list/jp/jp_tag.json`）と **`build_jp_wikidot_tag_article_map.py` のような収集スクリプト**
- 上記を生成・検証する **`scripts/`** 配下のツール。CI は **app-scp-docs** の **`.github/workflows/`** から起動し、**data-scp-docs** の `list/jp` 等へ push（シークレット `DATA_SCP_DOCS_PUSH_TOKEN`）

## `scp_docs`（アプリリポジトリ）側の扱い

- **同梱・長期保管しない**: 配信 JSON のコピーや、データ専用のハーベスタ本体を `scp_docs` に置いて二重管理しない。
- **`Research/` 等の参考資料**: アプリ開発用のローカル研究物として `scp_docs` に残り得るが、**配信パイプラインの正本入力とはみなさない**。パイプラインに取り込むサンプル・抽出ルールの根拠データは **data-scp-docs** に置く。
- **アプリの責務**: リモート URL から取得・キャッシュ（`SCPArticleTrifoldSyncService` / `WikiCatalogSyncService` 等）に留める。
- **`contrib/data-scp-docs/`** は、data-scp-docs へマージする前の **一時ミラー／候補置き場**に過ぎない。正の履歴・CI・本番配信は **data-scp-docs の `main`** を参照する。

## 新規作業の手順（要約）

1. 配信用 JSON や `docs/catalog` の更新は **data-scp-docs** の `main` が正。スクリプト改修は同リポ（または `contrib` から同期）。**収集用ワークフロー**の追加・変更は **app-scp-docs** の `.github/workflows/` で行い、必要なら data-scp-docs 用 PAT を同リポのシークレットに登録する。
2. アプリ側の変更が必要なのは **URL・スキーマ消費・型** に限る（必要なら `docs/APP_SPEC_HANDOVER_ja.md` や `AppRemoteConfig` の説明を更新）。
3. `scp_docs` にだけ残っている旧パスや重複スクリプトに気づいたら、**data-scp-docs へ移し** `scp_docs` からは削除する。

## 参照

- アプリからの取得先の整理: `docs/APP_SPEC_HANDOVER_ja.md` §7
- Tales / Canon 等の収集詳細: `docs/HANDOVER_TALES_CANON_COLLECTION_RULES_ja.md`
