#!/usr/bin/env bash
set -euo pipefail
IN="${1:-/mnt/hdd2/raw/school/soviet}"
OUT="${2:-/mnt/hdd1/data/docs/school/soviet}"
mkdir -p "$OUT"
echo "🔄 Конвертация DjVu → PDF: $IN"
find "$IN" -name "*.djvu" -o -name "*.DjVu" | while read -r f; do
  base="$(basename "$f" .djvu).pdf"
  echo "  → $base"
  ddjvu -format=pdf "$f" "$OUT/$base" 2>/dev/null || echo "⚠️ Пропуск $f"
done
echo "✅ Конвертация завершена. Файлы в $OUT"
