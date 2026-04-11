#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Монтирование HDD ===${NC}"

# Определяем диски
HDD1="/dev/sdb1"
HDD2="/dev/sdc1"
MOUNT1="/mnt/hdd1"
MOUNT2="/mnt/hdd2"

# Создаем точки
sudo mkdir -p $MOUNT1 $MOUNT2

# Монтируем
echo "Монтируем HDD1..."
sudo mount -o uid=1000,gid=1000 $HDD1 $MOUNT1 2>/dev/null || echo "Уже смонтирован"

echo "Монтируем HDD2..."
sudo mount -o uid=1000,gid=1000 $HDD2 $MOUNT2 2>/dev/null || echo "Уже смонтирован"

# Создаем структуру
for dir in \
    "$MOUNT1/docker/kiwix" \
    "$MOUNT1/docker/books" \
    "$MOUNT1/downloads" \
    "$MOUNT2/docker/maps" \
    "$MOUNT2/docker/trilium" \
    "$MOUNT2/docker/kanboard" \
    "$MOUNT2/docker/filebrowser"
do
    sudo mkdir -p "$dir"
    sudo chown 1000:1000 "$dir"
done

echo -e "${GREEN}✅ Готово${NC}"
df -h | grep /mnt/hdd