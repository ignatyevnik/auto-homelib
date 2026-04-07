#!/usr/bin/env bash
set -euo pipefail

IN="${1:-/mnt/hdd2/raw/school/soviet}"
OUT="${2:-/mnt/hdd1/data/docs/school/soviet}"
mkdir -p "$OUT"

# Проверка наличия утилиты
if ! command -v ddjvu &> /dev/null; then
    echo "❌ ddjvu не найдена. Установите: sudo apt install djvulibre-bin"
    exit 1
fi

echo "🔄 Конвертация DjVu → PDF: $IN"
count=0
find "$IN" -type f \( -name "*.djvu" -o -name "*.DjVu" \) | while read -r f; do
    base="$(basename "$f" .djvu).pdf"
    echo "  → $base"
    if ddjvu -format=pdf -quality=85 "$f" "$OUT/$base" 2>/dev/null; then
        ((count++))
    else
        echo "⚠️ Пропуск (ошибка конвертации): $f"
    fi
done
echo "✅ Завершено. Конвертировано файлов: $count"
