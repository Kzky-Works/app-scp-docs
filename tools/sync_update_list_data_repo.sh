#!/usr/bin/env bash
# data-scp-docs リポジトリの scripts/update_list.py を、app-scp-docs(main) と揃える。
# 使い方:
#   ./tools/sync_update_list_data_repo.sh pull   # GitHub の main を取得（CI と同じ）
#   ./tools/sync_update_list_data_repo.sh copy   # ローカルの update_list.py をコピー（未 push の変更を試すとき）
#
# 隣に data-scp-docs を clone してある前提。別パスなら DATA_SCP_DOCS_DIR を指定。
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DATA_REPO="${DATA_SCP_DOCS_DIR:-$REPO_ROOT/../data-scp-docs}"
RAW_URL="${APP_SCP_DOCS_SCRIPT_URL:-https://raw.githubusercontent.com/Kzky-Works/app-scp-docs/main/update_list.py}"
MODE="${1:-pull}"

if [[ ! -d "$DATA_REPO" ]]; then
  echo "data-scp-docs が見つかりません: $DATA_REPO" >&2
  echo "隣に clone するか: export DATA_SCP_DOCS_DIR=/path/to/data-scp-docs" >&2
  exit 1
fi

mkdir -p "$DATA_REPO/scripts"

case "$MODE" in
  pull)
    curl -fsSL -o "$DATA_REPO/scripts/update_list.py" "$RAW_URL"
    echo "取得: $RAW_URL → $DATA_REPO/scripts/update_list.py"
    ;;
  copy)
    cp "$REPO_ROOT/update_list.py" "$DATA_REPO/scripts/update_list.py"
    echo "コピー: $REPO_ROOT/update_list.py → $DATA_REPO/scripts/update_list.py"
    ;;
  *)
    echo "usage: $0 [pull|copy]" >&2
    exit 2
    ;;
esac
