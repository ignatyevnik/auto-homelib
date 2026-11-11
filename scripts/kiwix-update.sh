#!/bin/bash
# Полное обновление библиотеки Kiwix

CONTAINER="homelib-kiwix"
ZIM_PATH="/mnt/hdd1/docker/kiwix"

# Остановить Kiwix
docker stop $CONTAINER

# Создать новую библиотеку
cat > $ZIM_PATH/library.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<library version="20110515">
EOF

# Добавить каждый ZIM вручную (без kiwix-manage)
for zim in $ZIM_PATH/*.zim; do
    if [ -f "$zim" ]; then
        name=$(basename "$zim" .zim)
        echo "  <book id=\"$name\" path=\"/data/$(basename $zim)\" title=\"$name\"></book>" >> $ZIM_PATH/library.xml
    fi
done

echo '</library>' >> $ZIM_PATH/library.xml

# Запустить Kiwix
docker start $CONTAINER

echo "✅ Библиотека обновлена"
cat $ZIM_PATH/library.xml