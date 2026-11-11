#!/bin/bash
# ==================== KIWIX STARTUP SCRIPT / СКРИПТ ЗАПУСКА KIWIX ====================
# Starts Kiwix container with proper configuration / Запускает контейнер Kiwix с правильной конфигурацией

set -e  # Exit on error / Выход при ошибке

# Configuration / Конфигурация
CONTAINER_NAME="homelib-kiwix"
KIWIX_PORT="8084"
KIWIX_INTERNAL_PORT="8080"
ZIM_PATH="/mnt/hdd1/docker/kiwix"           # Path to ZIM files / Путь к ZIM-файлам
LIBRARY_XML="$ZIM_PATH/library.xml"         # Library catalog / Каталог библиотеки
IMAGE="ghcr.io/kiwix/kiwix-tools:latest"   # Docker image / Docker образ

echo "========================================"
echo "       KIWIX CONTAINER MANAGER         "
echo "========================================"

# Check and remove existing container / Проверить и удалить существующий контейнер
if docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
    echo "⚠️  Container $CONTAINER_NAME already exists / Контейнер $CONTAINER_NAME уже существует"
    read -p "Stop and remove? (y/n) / Остановить и удалить? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker stop "$CONTAINER_NAME" 2>/dev/null || true
        docker rm "$CONTAINER_NAME" 2>/dev/null || true
        echo "✅ Old container removed / Старый контейнер удалён"
    else
        echo "Exiting / Выход"
        exit 0
    fi
fi

# Create ZIM directory / Создать директорию для ZIM
mkdir -p "$ZIM_PATH"

# Create XML library / Создать XML библиотеку
echo "📚 Creating XML library... / Создание XML-библиотеки..."
cat > "$LIBRARY_XML" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<library version="20110515">
</library>
EOF
echo "✅ XML library created / XML-библиотека создана"

# Start container / Запустить контейнер
echo "🚀 Starting Kiwix container... / Запуск контейнера Kiwix..."
docker run -d \
  --name "$CONTAINER_NAME" \
  -p "$KIWIX_PORT:$KIWIX_INTERNAL_PORT" \
  -v "$ZIM_PATH:/data" \
  --restart unless-stopped \
  "$IMAGE" \
  kiwix-serve --port="$KIWIX_INTERNAL_PORT" --nolibrarybutton --library /data/library.xml

# Check startup / Проверить запуск
sleep 3
if docker ps | grep -q "$CONTAINER_NAME"; then
    echo "========================================"
    echo "✅ KIWIX SUCCESSFULLY STARTED! / KIWIX УСПЕШНО ЗАПУЩЕН!"
    echo "========================================"
    echo ""
    echo "📡 Access / Доступ: http://192.168.1.46:$KIWIX_PORT/"
    echo "📂 ZIM files / ZIM-файлы: $ZIM_PATH"
    echo "📋 Logs / Логи: docker logs $CONTAINER_NAME"
else
    echo "❌ Kiwix startup failed / Ошибка запуска Kiwix"
    echo "Logs / Логи:"
    docker logs "$CONTAINER_NAME" --tail 20
    exit 1
fi
