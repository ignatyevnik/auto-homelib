#!/bin/bash
# Универсальный скрипт для пополнения библиотеки (с проверкой UID/GID)

set -e

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Проверка UID
CURRENT_UID=$(id -u)
if [ "$CURRENT_UID" != "1000" ]; then
    echo -e "${YELLOW}⚠️  Внимание: Скрипт запущен от UID=$CURRENT_UID${NC}"
    echo -e "${YELLOW}   Рекомендуется UID=1000 для правильных прав доступа${NC}"
    echo ""
fi

# Пути
BOOKS_PATH="/mnt/hdd1/docker/books"
ZIM_PATH="/mnt/hdd1/docker/kiwix"
DOWNLOADS_PATH="/mnt/hdd1/downloads"

# Функция исправления прав
fix_permissions() {
    local path=$1
    if [ -d "$path" ]; then
        sudo chown -R 1000:1000 "$path" 2>/dev/null || true
        chmod -R 755 "$path" 2>/dev/null || true
    fi
}

# Функция для отображения справки
show_help() {
    cat << EOF
${GREEN}📚 HomeLab Library Manager (UID=1000)${NC}

ИСПОЛЬЗОВАНИЕ:
    ./add_books.sh [КОМАНДА] [АРГУМЕНТЫ]

КОМАНДЫ:
    ${BLUE}download-zim${NC} <URL>              Скачать ZIM файл
    ${BLUE}download-zim-list${NC} <файл.txt>   Скачать список ZIM файлов
    ${BLUE}scan-books${NC} <путь>              Импортировать PDF/DjVu
    ${BLUE}download-ussr${NC}                  Скачать учебники СССР
    ${BLUE}download-wikipedia${NC} <язык>      Скачать Wikipedia (ru, en)
    ${BLUE}list-sources${NC}                   Показать источники книг
    ${BLUE}status${NC}                         Состояние хранилища
    ${BLUE}fix-perms${NC}                      Исправить права на файлы

ПРИМЕРЫ:
    ./add_books.sh download-zim https://download.kiwix.org/zim/wikipedia_ru_all_maxi.zim
    ./add_books.sh download-ussr
    ./add_books.sh fix-perms

EOF
}

# Функция скачивания ZIM
download_zim() {
    local url=$1
    local filename=$(basename "$url")
    
    echo -e "${YELLOW}📥 Скачивание: $filename${NC}"
    
    mkdir -p $DOWNLOADS_PATH
    cd $DOWNLOADS_PATH
    
    # Используем aria2c или wget
    if command -v aria2c &> /dev/null; then
        aria2c -x 4 -s 4 --continue=true "$url"
    else
        wget -c "$url"
    fi
    
    echo -e "${GREEN}✅ Скачано: $filename${NC}"
    echo -e "${YELLOW}Перемещаем в библиотеку...${NC}"
    
    mkdir -p $ZIM_PATH
    mv "$filename" $ZIM_PATH/
    
    # Исправляем права
    fix_permissions $ZIM_PATH
    
    # Перезапускаем Kiwix
    docker restart homelib-kiwix
    
    echo -e "${GREEN}✅ ZIM файл добавлен и права исправлены!${NC}"
}

# Функция скачивания учебников СССР
download_ussr_books() {
    echo -e "${YELLOW}📚 Скачивание учебников СССР (1-11 классы)...${NC}"
    
    mkdir -p $BOOKS_PATH/ussr_education
    cd $BOOKS_PATH/ussr_education
    
    # Установка internetarchive если нужно
    if ! command -v ia &> /dev/null; then
        echo "Устанавливаем internetarchive..."
        pip3 install --user internetarchive
    fi
    
    # Список учебников
    declare -a queries=(
        "Арифметика 1 класс СССР"
        "Букварь СССР 1980"
        "Русский язык 2 класс СССР"
        "Родная речь 3 класс СССР"
        "Математика 4 класс СССР"
        "Математика 5 класс Виленкин"
        "Алгебра 6 класс Макарычев"
        "Физика 7 класс Перышкин"
        "Химия 8 класс Рудзитис"
        "Геометрия 9 класс Погорелов"
        "История СССР 10 класс"
        "Астрономия 11 класс"
    )
    
    for query in "${queries[@]}"; do
        echo -e "${BLUE}Поиск: $query${NC}"
        ia search "$query" --itemlist | head -n 3 | while read -r item; do
            echo "  Скачиваю: $item"
            ia download "$item" --glob="*.pdf" --glob="*.djvu" --no-directories --ignore-existing
        done
    done
    
    # Исправляем права
    fix_permissions $BOOKS_PATH
    
    echo -e "${GREEN}✅ Учебники СССР скачаны и права исправлены!${NC}"
}

# Функция сканирования и импорта книг
scan_books() {
    local source_path=$1
    
    if [ ! -d "$source_path" ]; then
        echo -e "${RED}❌ Путь не найден: $source_path${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}📂 Сканирование: $source_path${NC}"
    
    # Копируем файлы
    find "$source_path" -type f \( -name "*.pdf" -o -name "*.djvu" -o -name "*.fb2" -o -name "*.epub" \) | while read -r file; do
        local filename=$(basename "$file")
        local category=$(basename $(dirname "$file"))
        
        mkdir -p "$BOOKS_PATH/$category"
        
        if [ ! -f "$BOOKS_PATH/$category/$filename" ]; then
            echo "  📄 Копирую: $filename"
            cp "$file" "$BOOKS_PATH/$category/"
        else
            echo "  ⏭️ Пропущен: $filename"
        fi
    done
    
    # Исправляем права
    fix_permissions $BOOKS_PATH
    
    echo -e "${GREEN}✅ Книги импортированы и права исправлены!${NC}"
}

# Функция показа источников
list_sources() {
    cat << EOF
${GREEN}📖 ИСТОЧНИКИ ДЛЯ ПОПОЛНЕНИЯ БИБЛИОТЕКИ:${NC}

${BLUE}1. ZIM файлы (Wikipedia, Wiktionary, StackExchange):${NC}
   • https://download.kiwix.org/zim/ (зеркало)
   • https://library.kiwix.org/ (каталог)
   
${BLUE}2. Учебники СССР и современные:${NC}
   • https://archive.org/details/ussr_education
   • https://archive.org/details/sovetskie-uchebniki
   • http://sheba.spb.ru/shkola/
   
${BLUE}3. Научная литература:${NC}
   • https://sci-hub.se/
   • https://libgen.is/
   
${BLUE}4. Художественная литература:${NC}
   • https://flibusta.site/
   • https://royallib.com/
   
${BLUE}5. Карты для TileServer:${NC}
   • https://download.geofabrik.de/
   • http://gis-lab.info/projects/osm_dump/

${YELLOW}💡 Совет: Используйте VPN/прокси для доступа${NC}
EOF
}

# Функция показа состояния хранилища
show_status() {
    echo -e "${GREEN}📊 СОСТОЯНИЕ ХРАНИЛИЩА (UID=1000):${NC}"
    echo ""
    echo -e "${BLUE}HDD1 (Библиотека и ZIM):${NC}"
    echo "├─ ZIM файлы: $(ls -1 $ZIM_PATH/*.zim 2>/dev/null | wc -l) шт, $(du -sh $ZIM_PATH 2>/dev/null | cut -f1)"
    echo "├─ Книги: $(find $BOOKS_PATH -type f \( -name "*.pdf" -o -name "*.djvu" \) 2>/dev/null | wc -l) шт, $(du -sh $BOOKS_PATH 2>/dev/null | cut -f1)"
    echo "├─ Загрузки: $(du -sh $DOWNLOADS_PATH 2>/dev/null | cut -f1)"
    echo "└─ Владелец: $(stat -c '%U:%G' $ZIM_PATH 2>/dev/null || echo 'неизвестно')"
    echo ""
    echo -e "${BLUE}HDD2 (Карты и базы данных):${NC}"
    echo "├─ Карты: $(ls -1 /mnt/hdd2/docker/maps/*.mbtiles 2>/dev/null | wc -l) шт, $(du -sh /mnt/hdd2/docker/maps 2>/dev/null | cut -f1)"
    echo "├─ Trilium: $(du -sh /mnt/hdd2/docker/trilium 2>/dev/null | cut -f1)"
    echo "└─ Владелец: $(stat -c '%U:%G' /mnt/hdd2/docker/maps 2>/dev/null || echo 'неизвестно')"
    echo ""
    echo -e "${BLUE}Свободное место:${NC}"
    df -h | grep -E "Filesystem|/mnt/hdd"
    
    # Проверка прав
    echo ""
    echo -e "${YELLOW}Проверка прав доступа:${NC}"
    if [ -w "$ZIM_PATH" ] && [ -w "$BOOKS_PATH" ]; then
        echo -e "  ✅ Запись в директории библиотеки разрешена"
    else
        echo -e "  ❌ Проблема с правами записи. Выполните: ./add_books.sh fix-perms"
    fi
}

# Главный обработчик
case "$1" in
    download-zim)
        [ -z "$2" ] && { echo -e "${RED}❌ Укажите URL${NC}"; exit 1; }
        download_zim "$2"
        ;;
    download-zim-list)
        [ ! -f "$2" ] && { echo -e "${RED}❌ Файл не найден: $2${NC}"; exit 1; }
        while read -r url; do
            download_zim "$url"
        done < "$2"
        ;;
    scan-books)
        [ -z "$2" ] && { echo -e "${RED}❌ Укажите путь${NC}"; exit 1; }
        scan_books "$2"
        ;;
    download-ussr)
        download_ussr_books
        ;;
    download-wikipedia)
        lang=${2:-ru}
        url="https://download.kiwix.org/zim/wikipedia_${lang}_all_maxi.zim"
        download_zim "$url"
        ;;
    list-sources)
        list_sources
        ;;
    status)
        show_status
        ;;
    fix-perms)
        echo -e "${YELLOW}🔧 Исправление прав доступа...${NC}"
        fix_permissions "/mnt/hdd1/docker"
        fix_permissions "/mnt/hdd2/docker"
        echo -e "${GREEN}✅ Права исправлены!${NC}"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        show_help
        ;;
esac