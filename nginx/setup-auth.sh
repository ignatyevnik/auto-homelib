#!/usr/bin/env bash
set -euo pipefail
source ../.env
htpasswd_file="../nginx/.htpasswd"

echo "🔐 Генерация .htpasswd..."
htpasswd -bc "$htpasswd_file" "$NGINX_ADMIN_USER" "$NGINX_ADMIN_PASSWORD"
chmod 644 "$htpasswd_file"
echo "✅ Файл создан: $htpasswd_file"