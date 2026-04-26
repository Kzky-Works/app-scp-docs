# data-scp-docs 変更候補（scp_docs 同梱ミラー）

このフォルダは **[Kzky-Works/data-scp-docs](https://github.com/Kzky-Works/data-scp-docs)** へ同梱する **スクリプト正本**です。`list/jp/*.json` の配信物は同リポの `main` 上のパスが正です。

**CI の所在:** 日次のハーベストと週次のタグマップ生成は、**[app-scp-docs](https://github.com/Kzky-Works/app-scp-docs)** ルートの **`.github/workflows/`**（`update-list-feeds.yml` / `jp-tag-map.yml`）で動きます。ジョブ内で本ディレクトリのスクリプトを使い、成果物だけ **`data-scp-docs` リポジトリ**の `list/jp/` へ `git push` します。data-scp-docs 側に同名ワークフローは不要です（スクリプトのコピー先としてだけ同期する）。

**必須シークレット（app-scp-docs）:** リポジトリに **`DATA_SCP_DOCS_PUSH_TOKEN`** を登録する。`Kzky-Works/data-scp-docs` へ **contents:write** できる fine-grained PAT または classic PAT。未設定だと `data-scp-docs` の checkout が失敗します。

## 反映手順（data-scp-docs リポの手作業でスクリプトを更新する場合）

1. `data-scp-docs` を clone し、本ディレクトリの `scripts/` / `requirements.txt` を上書きコピー（Actions は上記のとおり app-scp-docs 側のため、ワークフローはコピー不要）。
2. `pip install -r requirements.txt`
3. `python3 scripts/harvester.py`（未指定なら、clone 先の `list/jp` に書く。別ディレクトリへ出すときは `python3 scripts/harvester.py --output-dir <絶対パス>/list/jp`）
4. （任意）`mkdir -p list/jp && python3 scripts/build_jp_wikidot_tag_article_map.py -o list/jp/jp_tag.json` — `tag/jp/p/1..59` 周辺からタグ名を集め、記事スラッグ→タグ配列の JSON を `list/jp/` へ。`docs/catalog` 取り込みは data-scp-docs 側スキーマに合わせる。
5. `python3 scripts/validate_manifests.py`（`list/jp` を省略可。別ディレクトリなら第1引数で渡す）
6. 変更を `data-scp-docs` の `main` へプッシュ

## 主な変更（マルチフォーム計画対応）

| 項目 | 内容 |
|------|------|
| **Canon** | `canon-hub-jp` / `canon-hub` の `#page-content div.canon-title` 内リンクのみ → `manifest_canons.json`（`canonRegions.jp` / `canonRegions.en` + `metadata[].r`） |
| **Joke** | `joke-scps` / `joke-scps-jp` からジョーク記事パス（`-j` / `-jp-j` 等）を抽出 → `manifest_jokes.json` |
| **GoI** | `goi-formats-jp` の **h1/h2/ul 構造**をパース（schema **3**）。`goiRegions`（en / jp / other）+ 団体別 `entries` + フラット `entries`＋`metadata`（`g`・`r`）。仕様: `docs/GOI_MANIFEST_V3_ja.md` |
| **Tales** | `foundation-tales`（本家翻訳ハブ）を `foundation-tales-jp` に続けて取得し、`i` で重複除去してマージ |
| **listVersion** | 前回出力と `entries`+`metadata` が同一なら据え置き、変化時のみ `+1`（§13.2） |

旧 **`canons.json` / `jokes.json`（ホスト直下）** は配信しない方針です（`docs/HANDOVER_TALES_CANON_COLLECTION_RULES_ja.md` §13）。
