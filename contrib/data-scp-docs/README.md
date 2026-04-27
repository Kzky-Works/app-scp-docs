# data-scp-docs 連携（app-scp-docs 上の作業用ディレクトリ）

**原本（正）**は **GitHub の [Kzky-Works/app-scp-docs](https://github.com/Kzky-Works/app-scp-docs) リポジトリ `main` ブランチ**にマージ・プッシュされた内容である。本ディレクトリはその**作業用**置き場であり、**原本を最新のまま保つ**には**メンテが `main` へ push** する想定（ローカルだけの改変は原本ではない）。

- **配信物**（`list/jp/*.json` 等）の**格納庫**は [data-scp-docs](https://github.com/Kzky-Works/data-scp-docs) リポジトリであり、その**原本**は **data-scp-docs の GitHub `main`** 上のパスである。

**CI の所在:** 日次のハーベストと週次のタグマップは、**[app-scp-docs](https://github.com/Kzky-Works/app-scp-docs)** ルートの **`.github/workflows/`**（`update-list-feeds.yml` / `jp-tag-map.yml`）で動きます。ジョブ内で**本ディレクトリ**のスクリプトを使い、成果物だけ **[data-scp-docs](https://github.com/Kzky-Works/data-scp-docs)** の `list/jp/` へ `git push` します。data-scp-docs 側に同名ワークフローは不要です。スクリプトを [data-scp-docs の `scripts/`](https://github.com/Kzky-Works/data-scp-docs) にも**揃えたい**場合は、**両リポの `main` に**反映する手順（下記「手作業」）に従う。

**必須シークレット（app-scp-docs）:** リポジトリに **`DATA_SCP_DOCS_PUSH_TOKEN`** を登録。`Kzky-Works/data-scp-docs` へ **contents:write** できる PAT。未設定だと `data-scp-docs` の checkout が失敗します。

## 反映手順（data-scp-docs リポで `scripts` を手で揃える場合）

1. `data-scp-docs` を clone し、本ディレクトリの `scripts/` / `requirements.txt` を上書きコピー（Actions は app-scp-docs 側のため、ワークフローはコピー不要）
2. `pip install -r requirements.txt`
3. `python3 scripts/harvester.py`（**未指定なら** `data-scp-docs` 単体 clone ならリポジトリルートの `list/jp`。**本リポ（app）の作業用から**実行する場合は `contrib/data-scp-docs/list/jp` 等へ `--output-dir` 明示推奨）。**同一リポ内で**コミット／プッシュまで: `python3 scripts/harvester.py --git-commit` 等。実行開始時に stderr の**絶対パス**に注意
4. （任意）`build_jp_wikidot_tag_article_map.py` で `jp_tag.json` 等
5. `python3 scripts/validate_manifests.py`
6. 変更を **data-scp-docs の `main` へプッシュ**（**原本**は当該リポの `main`）

## 主な変更（マルチフォーム計画対応）

| 項目 | 内容 |
|------|------|
| **Canon** | `canon-hub-jp` / `canon-hub` の `#page-content div.canon-title` 内リンク → `manifest_canons.json`。`canonRegions` 各行に `tag-list` 由来の **`ct`**、各ハブページの **`ds`**（`div.canon-description`）・**`lu`**（`#page-info` の unix）を付与。軽量 `entries` は従来どおり `u` / `i` / `t` のみ。`metadata[].r` は `jp` / `en`。 |
| **Joke** | `joke-scps` / `joke-scps-jp` からジョーク記事パス（`-j` / `-jp-j` 等）を抽出 → `manifest_jokes.json` |
| **GoI** | `goi-formats-jp` の **h1/h2/ul 構造**をパース（schema **3**）。`goiRegions`（en / jp / other）+ 団体別 `entries` + フラット `entries`＋`metadata`（`g`・`r`）。仕様: `docs/GOI_MANIFEST_V3_ja.md` |
| **Tales** | `foundation-tales`（本家翻訳ハブ）を `foundation-tales-jp` に続けて取得し、`i` で重複除去してマージ |
| **listVersion** | 前回出力と `entries`+`metadata` が同一なら据え置き、変化時のみ `+1`（§13.2） |

旧 **`canons.json` / `jokes.json`（ホスト直下）** は配信しない方針です（`docs/HANDOVER_TALES_CANON_COLLECTION_RULES_ja.md` §13）。

**詳しいリポ境界・原本の定義**は `docs/DEV_RULE_ARTICLE_DATA_IN_DATA_SCP_DOCS_ja.md` を参照。
