#!/usr/bin/env bash
set -euo pipefail
echo "🔧 Инициализация сервера v2.5..."

sudo apt update && sudo apt install -y zram-config docker.io docker-compose-v2 rsync jq calibre ddjvu-tools apache2-utils

echo "ALGO=zstd" | sudo tee /etc/zram.conf
echo "PERCENT=50" | sudo tee -a /etc/zram.conf
sudo systemctl restart zram-config

cat << 'SYSCTL' | sudo tee /etc/sysctl.d/99-offline.conf
vm.swappiness=5
vm.vfs_cache_pressure=75
net.core.somaxconn=1024
fs.inotify.max_user_watches=524288
SYSCTL
sudo sysctl -p /etc/sysctl.d/99-offline.conf

cat << 'DOCKER' | sudo tee /etc/docker/daemon.json
{"log-driver":"json-file","log-opts":{"max-size":"10m","max-file":"3"}}
DOCKER
sudo systemctl restart docker

source .env
sudo mkdir -p "$HDD1_PATH"/data/{zim,maps,docs/{tech/{computers,mobile},school/{soviet,chemistry,math_analysis,1-11},cache/kiwix},apps/{kanboard/{data,plugins},trilium}}
sudo mkdir -p "$HDD2_PATH"/{raw/{zim,maps,tech,school},backup/{daily,weekly},logs}
sudo chown -R $USER:$USER "$HDD1_PATH" "$HDD2_PATH"
chmod -R 755 "$HDD1_PATH" "$HDD2_PATH"

bash nginx/setup-auth.sh
echo "✅ Инициализация завершена. Запустите: docker compose up -d"