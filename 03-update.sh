#!/usr/bin/env bash
set -euo pipefail
source .env
USB="/mnt/usb"
LOG="$HDD2_PATH/logs/update-$(date +%Y%m%d).log"
mkdir -p "$HDD2_PATH/logs"
exec > >(tee -a "$LOG") 2>&1

echo "🔄 Обновление: $(date)"
[ ! -d "$USB" ] && { echo "⚠️ USB не подключён"; exit 1; }
FREE=$(df -BG "$HDD1_PATH" | awk 'NR==2{print $4}'|tr -d 'G')
[ "$FREE" -lt 15 ] && { echo "⚠️ Место <15GB"; exit 1; }

[ -d "$USB/tech" ] && rsync -avh "$USB/tech/" "$HDD1_PATH/data/docs/tech/"
[ -d "$USB/school" ] && rsync -avh "$USB/school/" "$HDD1_PATH/data/docs/school/"
[ -d "$USB/zim" ] && {
  rsync -avh "$USB/zim/"*.zim "$HDD1_PATH/data/zim/" 2>/dev/null || true
  kiwix-manage "$HDD1_PATH/data/zim/library.xml" add "$HDD1_PATH/data/zim/"*.zim 2>/dev/null || true
}
[ -f "$USB/maps/ru-by-ge.mbtiles" ] && {
  mv "$HDD1_PATH/data/maps/ru-by-ge.mbtiles" "${HDD1_PATH}/data/maps/ru-by-ge.mbtiles.bak" 2>/dev/null || true
  cp "$USB/maps/ru-by-ge.mbtiles" "$HDD1_PATH/data/maps/"
}
docker compose restart kiwix tileserver filebrowser
docker system prune -f --volumes
echo "✅ Готово"
