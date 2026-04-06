#!/usr/bin/env bash
set -euo pipefail
source .env
DATE=$(date +%Y%m%d_%H%M)
DEST="$HDD2_PATH/backup/config/$DATE"
mkdir -p "$DEST"

echo "💾 Бэкап конфигурации и приложений..."
cp -r docker-compose.yml .env nginx/ tileserver/ filebrowser/ scripts/ html/ "$DEST/"
tar czf "$HDD2_PATH/backup/config/hub-config-$DATE.tar.gz" -C "$DEST" .
tar czf "$HDD2_PATH/backup/apps-$DATE.tar.gz" -C "$HDD1_PATH/data/apps" kanboard trilium
rm -rf "$DEST"
echo "✅ Бэкапы сохранены в $HDD2_PATH/backup/"