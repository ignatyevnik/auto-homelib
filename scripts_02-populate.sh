#!/usr/bin/env bash
set -euo pipefail
source .env
echo "📦 Заполнение библиотеки..."
rsync -avh --delete "$HDD2_PATH/raw/tech/" "$HDD1_PATH/data/docs/tech/" 2>/dev/null || true
rsync -avh --delete "$HDD2_PATH/raw/school/" "$HDD1_PATH/data/docs/school/" 2>/dev/null || true
kiwix-manage "$HDD1_PATH/data/zim/library.xml" add "$HDD1_PATH/data/zim/"*.zim 2>/dev/null || true
echo "✅ Данные скопированы. docker compose restart kiwix filebrowser"