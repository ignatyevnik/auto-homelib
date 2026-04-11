#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🔐 Исправление прав для UID=1000 GID=1000${NC}"

# Проверка UID
if [ "$(id -u)" != "1000" ]; then
    echo -e "${YELLOW}⚠️ Текущий UID=$(id -u). Ожидается 1000${NC}"
fi

# Исправление прав
for dir in /mnt/hdd1/docker /mnt/hdd2/docker; do
    if [ -d "$dir" ]; then
        echo "Исправляем $dir"
        sudo chown -R 1000:1000 "$dir" 2>/dev/null || true
        chmod -R 755 "$dir" 2>/dev/null || true
    fi
done

# Права на .htpasswd
[ -f "./nginx/.htpasswd" ] && chmod 644 ./nginx/.htpasswd

echo -e "${GREEN}✅ Права исправлены${NC}"