# data-scp-docs 変更候補（scp_docs 同梱ミラー）

このフォルダは **[Kzky-Works/data-scp-docs](https://github.com/Kzky-Works/data-scp-docs)** リポジトリへ取り込むための **スクリプト・ワークフロー案**です。GitHub Pages の実データは data-scp-docs 側の `main` が正です。

## 反映手順

1. `data-scp-docs` を clone し、本ディレクトリの内容で上書き（少なくとも `scripts/harvester.py`）。
2. `pip install -r requirements.txt`
3. `python3 scripts/harvester.py`（Wikidot へのリクエストが多く **数十分かかる**場合があります）
4. （任意）`mkdir -p lists/jp && python3 scripts/build_jp_wikidot_tag_article_map.py -o lists/jp/jp_tag.json` — `system:page-tags/tag/jp/p/1..59` からタグ名を集め、各タグの `list-pages-item` 由来で記事スラッグ→タグ配列の JSON を生成。`docs/catalog` への取り込みは data-scp-docs 側のスキーマに合わせてマージする。
   - **GitHub Actions（正本）**: **[data-scp-docs](https://github.com/Kzky-Works/data-scp-docs)** の `.github/workflows/jp-tag-map.yml` は **週1回（日曜 00:00 UTC）**に自動実行され、差分があれば `main` の **`lists/jp/jp_tag.json`** を更新する。Hybrid harvester（`update.yml`）とは別ジョブ。**手動実行**（`workflow_dispatch`）も可。フル実行は Wikidot へのリクエストが極めて多いため **既定のジョブ上限 6 時間**に収まらない場合がある。試験時は入力 `max_tags` に小さな数（例: `20`）を指定すること。
5. `python3 scripts/validate_manifests.py`
6. `list/jp/` に `manifest_canons.json` / `manifest_jokes.json` が生成されていることを確認してコミット・プッシュ

## 主な変更（マルチフォーム計画対応）

| 項目 | 内容 |
|------|------|
| **Canon** | `canon-hub-jp` / `canon-hub` / `series-hub-jp` の `#page-content` から単一スラッグリンクを収集 → `manifest_canons.json` |
| **Joke** | `joke-scps` / `joke-scps-jp` からジョーク記事パス（`-j` / `-jp-j` 等）を抽出 → `manifest_jokes.json` |
| **GoI** | `goi-formats-jp` ハブリンクに切替（旧: `goi-format` タグページのみ）。`metadata` に `o`（団体表示名＝リンクテキスト） |
| **Tales** | `foundation-tales`（本家翻訳ハブ）を `foundation-tales-jp` に続けて取得し、`i` で重複除去してマージ |
| **listVersion** | 前回出力と `entries`+`metadata` が同一なら据え置き、変化時のみ `+1`（§13.2） |

旧 **`canons.json` / `jokes.json`（ホスト直下）** は配信しない方針です（`docs/HANDOVER_TALES_CANON_COLLECTION_RULES_ja.md` §13）。
