!!нужна доработка README.MD!!
# 📚 Offline Library Hub v3

Полностью автономная домашняя библиотека, оффлайн-карты, система задач и база знаний. Работает без интернета.

Fully autonomous home library, offline maps, task tracker and knowledge base. Works without internet.

---

## ⚠️ Disclaimer

### ENG
The project was created by AI. So do not judge me cruelly :)

This project was created to preserve some knowledge in case all the Internet will be shut down due to recent events in the World. Feel free to write some of the thoughts on this.

With limited resources, but full of enthusiasm, I would like to share this "attempt" to help secure yourself and have, at least, a possibility to find the information you need about medicine (first-aid), agriculture, fixing auto (but only popular in Russia and former soviet countries), school books and some other things.

The data is needed to be downloaded and moved to the target machine to deploy. It has offline maps for some regions of Russian Federation. If needed, I can correct the project later to manipulate different packages.

**Be aware, that is not an easy task, if you are not quite familiar with Linux, docker, nginx, bash or terminal.**

Most of the files contain tips or what is it about.

### RU
Данный проект был создан с помощью ИИ, так что не судите строго :)

Проект был создан с целью сохранить некоторые знания, в случае если интернет будет отключен из-за недавних событий в мире. Можете свободно писать свои мысли по этому поводу.

Полон энтузиазма, но с ограниченными ресурсами, я бы хотел поделиться "попыткой" обезопасить себя и, хотя бы иметь возможность найти информацию, которая нужна про медицину (оказание первой помощи), сельское хозяйство, ремонт автомобилей (но только популярные в России и бывших стран СССР), школьные учебники и некоторые другие вещи.

Данные необходимо скачать и перенести на машину, на которой будет развернут проект. Имеются оффлайн карты для некоторых регионов Российской Федерации. Также, если потребуется, я смогу скорректировать проект позже и управлять пакетами.

**Будьте внимательны, так как это может показаться нелегкой задачей, если вы не знакомы с такими вещами как Линукс, докер, сервер nginx, bash или терминал.**

Большинство файлов содержит подсказки и что они обозначают.

---

## ⚙️ Требования / Requirements

| Компонент | Минимум | Рекомендуется |
|-----------|---------|---------------|
| **CPU** | 2 ядра, x86_64 | 4+ ядра, AVX |
| **RAM** | 8 GB | 16 GB + ZRAM/Swap |
| **SSD (система)** | 120 GB | 240 GB → `/` (ОС + Docker) |
| **HDD1** | 100 GB | 250+ GB → `/mnt/hdd1` (книги, ZIM, музыка) |
| **HDD2** | 100 GB | 250+ GB → `/mnt/hdd2` (карты, БД, ИИ) |
| **GPU** | опционально | NVIDIA (для Ollama) |
| **ОС** | Ubuntu 22.04/24.04 | Ubuntu 24.04 Server (Minimal) |

---

## 🗂️ Стек сервисов

| Сервис | Назначение | Порт | Логин/Пароль |
|--------|-----------|------|--------------|
| **Nginx + Dashboard** | Веб-портал и реверс-прокси | **24** | `admin / homelib2024` |
| **Kanboard** | Канбан-доска задач | 8081 | `admin / admin` |
| **FileBrowser** | Файловый менеджер | 8082 | `admin / homelib2024` |
| **Calibre-Web** | Электронная библиотека | 8083 | `admin / admin123` |
| **Kiwix** | Офлайн-энциклопедия (Wikipedia) | 8084 | — |
| **TileServer-GL** | Офлайн-карты | 8085 | — |
| **CyberChef** | Анализ данных | 8087 | — |
| **Hardware API** | Информация о железе | 8089 | — |
| **Navidrome** | Музыкальный сервер | 8090 | `admin / homelib2024` |
| **Open WebUI** | Веб-интерфейс для локального ИИ | 8091 | первый юзер = админ |
| **Glances** | Системный мониторинг | 61208 | — |
| **Ollama** | Локальный ИИ (API) | 11434 | — |

---

## 🚀 Быстрый старт (первичная установка)

### 1. Установка Docker и зависимостей

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y docker.io docker-compose-plugin git curl wget make
sudo usermod -aG docker $USER
newgrp docker
```

### 2. Проверка UID/GID (должен быть 1000)

```bash
id -u   # Ожидается: 1000
id -g   # Ожидается: 1000
```

Если UID не 1000 — создайте пользователя:

```bash
sudo useradd -u 1000 -g 1000 -m -s /bin/bash homelab
sudo usermod -aG docker homelab
```

### 3. Клонирование репозитория

```bash
git clone https://github.com/ignatyevnik/auto-homelib.git
cd auto-homelib
```

### 4. Монтирование дисков

```bash
# Проверить, что HDD видны
lsblk -f

# Смонтировать (замените /dev/sdb1 и /dev/sdc1 на свои)
sudo ./scripts/mount_hdd.sh

# Проверить
df -h | grep /mnt/hdd
```

### 5. Создание структуры каталогов

```bash
# Данные на HDD1
sudo mkdir -p /mnt/hdd1/docker/{books,kiwix,music,downloads}
sudo chown -R 1000:1000 /mnt/hdd1/docker

# Данные на HDD2
sudo mkdir -p /mnt/hdd2/docker/{trilium,kanboard,filebrowser,maps,pmtiles,ollama,webui}
sudo chown -R 1000:1000 /mnt/hdd2/docker

# Локальные конфиги
mkdir -p ./nginx ./kanboard ./tileserver ./scripts ./calibre-web/config ./navidrome/data ./mcp
```

### 6. Создание `.htpasswd` для Nginx

```bash
docker run --rm httpd:alpine htpasswd -nbB admin 'homelib2024' > nginx/.htpasswd
chmod 644 nginx/.htpasswd
```

### 7. Настройка IP-адреса

**Важно:** замените `192.168.1.94` на IP вашего сервера во всех конфигах.

```bash
# Узнать текущий IP
ip addr show | grep "inet " | grep -v 127.0.0.1

# Заменить в конфигах (укажите ваш IP)
NEW_IP="192.168.1.94"
grep -rl "192.168.1.94" . 2>/dev/null | xargs sed -i "s/192.168.1.94/$NEW_IP/g"
```

### 8. Запуск всех сервисов

```bash
# Права на скрипты
chmod +x scripts/*.sh

# Запуск
docker compose up -d

# Проверка
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### 9. Запуск Kiwix (отдельно!)

Kiwix запускается **вручную**, вне `docker-compose.yml` (иначе ломает Nginx).

```bash
# Создать пустую библиотеку (если ещё нет)
cat > /mnt/hdd1/docker/kiwix/library.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<library version="20110515">
</library>
EOF

# Запуск
docker rm -f homelib-kiwix 2>/dev/null
docker run -d \
  --name homelib-kiwix \
  -p 8084:8080 \
  -v /mnt/hdd1/docker/kiwix:/data \
  --restart unless-stopped \
  ghcr.io/kiwix/kiwix-tools:latest \
  kiwix-serve --port=8080 --nolibrarybutton --library /data/library.xml
```

### 10. Hardware API (systemd-сервис)

```bash
sudo mkdir -p /opt/homelab
sudo tee /opt/homelab/hardware-api.py > /dev/null << 'EOF'
#!/usr/bin/env python3
from http.server import HTTPServer, BaseHTTPRequestHandler
import json, subprocess

class HardwareHandler(BaseHTTPRequestHandler):
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()
    def do_GET(self):
        if self.path == '/api/hardware':
            data = self.get_hardware_info()
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps(data, ensure_ascii=False).encode())
        else:
            self.send_response(404)
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
    def get_hardware_info(self):
        cpu = subprocess.getoutput("lscpu | grep 'Model name' | cut -d':' -f2 | xargs")
        cores = subprocess.getoutput("nproc")
        gpu = subprocess.getoutput("lspci | grep -E 'VGA|3D|Display' | head -1 | cut -d':' -f3 | xargs")
        return {"cpu": {"model": cpu or "—", "cores": cores or "—"},
                "gpu": {"name": gpu or "—", "memory": "—"}}

if __name__ == '__main__':
    HTTPServer(('0.0.0.0', 8089), HardwareHandler).serve_forever()
EOF

sudo tee /etc/systemd/system/hardware-api.service > /dev/null << 'EOF'
[Unit]
Description=Hardware Info API
After=network.target
[Service]
Type=simple
User=malkavlib
WorkingDirectory=/opt/homelab
ExecStart=python3 /opt/homelab/hardware-api.py
Restart=always
RestartSec=5
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now hardware-api
curl http://localhost:8089/api/hardware
```

### 11. Проверка доступа

```bash
# Дашборд
curl -I http://localhost:24/

# Все контейнеры
docker ps

# Kiwix
curl -I http://localhost:8084/

# Hardware API
curl http://localhost:8089/api/hardware
```

Откройте в браузере: **`http://192.168.1.94:24/`**

---

## 🔄 Обновление системы

### Обновить образы контейнеров

```bash
cd ~/auto-homelib
docker compose pull
docker compose up -d
docker image prune -f
```

### Обновить Kiwix (отдельно)

```bash
docker pull ghcr.io/kiwix/kiwix-tools:latest
docker rm -f homelib-kiwix
# Запустить заново командой из раздела «Быстрый старт», п.9
```

### Обновить конфиги (из Git)

```bash
cd ~/auto-homelib
git pull origin main

# Если были локальные изменения — сохранить в стэш
git stash
git pull
git stash pop

# Перезапустить
docker compose up -d
docker exec homelib-nginx nginx -t && docker exec homelib-nginx nginx -s reload
```

### Обновить систему (Ubuntu)

```bash
sudo apt update && sudo apt upgrade -y
sudo apt autoremove -y
```

---

## 📚 Пополнение библиотеки

### 📖 Книги для Calibre-Web

**Способ 1: Веб-интерфейс (рекомендуется)**

1. Откройте `http://192.168.1.94:8083/`
2. Войдите: `admin / admin123`
3. **Admin → Feature Configuration** → включить **«Enable Uploading»**
4. На главной странице — кнопка **Upload** → загрузить DJVU/FB2/EPUB/PDF

**Способ 2: Через файловую систему**

```bash
# Скопировать книги
cp /путь/к/книгам/*.fb2 /mnt/hdd1/docker/books/
cp /путь/к/книгам/*.djvu /mnt/hdd1/docker/books/

# Права
sudo chown -R 1000:1000 /mnt/hdd1/docker/books/

# Перезапустить Calibre-Web для индексации
docker restart homelib-calibre
```

**Способ 3: Импорт через CLI (если установлен мод universal-calibre)**

```bash
docker exec homelib-calibre calibredb add /books/*.fb2 --with-library /books -r
```

**Где брать книги:**
- `https://archive.org/details/ussr_education` — советские учебники
- `https://libgen.is/` — техническая литература
- `https://flibusta.site/` — художественная литература
- `http://sheba.spb.ru/shkola/` — школьная программа

### 🌍 ZIM-файлы для Kiwix

```bash
# Скачать ZIM (пример: Wikipedia RU)
cd /mnt/hdd1/downloads
wget http://iso.nl.netbsd.org/kiwix/zim/wikipedia/wikipedia_ru_all_maxi_2024-01.zim
# или с зеркала:
# wget https://mirrors.dotsrc.org/kiwix/zim/wikipedia/wikipedia_ru_all_maxi_2024-01.zim

# Переместить в папку Kiwix
mv *.zim /mnt/hdd1/docker/kiwix/
sudo chown -R 1000:1000 /mnt/hdd1/docker/kiwix/

# Обновить library.xml
cat > /mnt/hdd1/docker/kiwix/library.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<library version="20110515">
  <book id="wikipedia_ru" path="/data/wikipedia_ru_all_maxi_2024-01.zim" title="Wikipedia RU"></book>
</library>
EOF

# Перезапустить Kiwix
docker restart homelib-kiwix
```

**Где брать ZIM:**
- `http://iso.nl.netbsd.org/kiwix/zim/` — зеркало NLUUG
- `https://mirrors.dotsrc.org/kiwix/zim/` — зеркало dotsrc
- `https://library.kiwix.org/` — каталог (только просмотр)

### 🎵 Музыка для Navidrome

```bash
# Скопировать музыку
cp -r /путь/к/музыке/* /mnt/hdd1/docker/music/
sudo chown -R 1000:1000 /mnt/hdd1/docker/music/

# Перезапустить для сканирования
docker restart homelib-music
```

Форматы: MP3, FLAC, AAC, OPUS, OGG.

### 🗺️ Карты для TileServer

**Вариант A: Готовый MBTiles**

```bash
# Положить файл в /mnt/hdd2/docker/pmtiles/
cp /путь/к/картам/*.mbtiles /mnt/hdd2/docker/pmtiles/
sudo chown 1000:1000 /mnt/hdd2/docker/pmtiles/*.mbtiles

# Проверить валидность (должен быть SQLite)
head -c 16 /mnt/hdd2/docker/pmtiles/ваш_файл.mbtiles | xxd
# Ожидается: 5351 4c69 7465 2066 6f72 6d61 7420 3300 (SQLite format 3)

# Обновить config.json
nano /mnt/hdd2/docker/maps/config.json
```

Пример `config.json`:
```json
{
  "options": {
    "paths": {
      "root": "/data",
      "mbtiles": "/data/mbtiles",
      "styles": "/data"
    }
  },
  "styles": {
    "northwestern": {
      "style": "style.json"
    }
  },
  "data": {
    "northwestern": {
      "mbtiles": "ваш_файл.mbtiles"
    }
  }
}
```

```bash
# Перезапустить
docker compose restart tileserver
```

**Вариант B: Сгенерировать из OSM PBF**

```bash
# Скачать данные
cd /mnt/hdd2/docker/maps
wget https://download.geofabrik.de/russia/northwestern-fed-district-latest.osm.pbf

# Конвертировать (требует 4+ GB RAM, 30-60 мин)
docker run -it --rm \
  -v $(pwd):/data \
  ghcr.io/systemed/tilemaker:master \
  --input /data/northwestern-fed-district-latest.osm.pbf \
  --output /data/northwestern.mbtiles \
  --store /data/temp
```

**Где брать карты:**
- `https://download.geofabrik.de/russia/` — OSM PBF по регионам
- `https://maps.protomaps.com/builds/` — готовые PMTiles
- `https://data.maptiler.com/` — MBTiles (платно)

### 🎓 DevAcademy (офлайн-курсы)

```bash
# Сборка
git clone https://github.com/ignatyevnik/DevAcademy.git
cd DevAcademy
npm install
npm run build

# Разместить в Nginx
sudo mkdir -p /mnt/hdd2/docker/devacademy
sudo cp -r dist/* /mnt/hdd2/docker/devacademy/
sudo chown -R 1000:1000 /mnt/hdd2/docker/devacademy/
```

Добавить в `nginx.conf`:
```nginx
location /devacademy/ {
    alias /usr/share/nginx/html/devacademy/;
    try_files $uri $uri/ /devacademy/index.html;
}
```

Добавить volume в `docker-compose.yml` для `nginx`:
```yaml
- /mnt/hdd2/docker/devacademy:/usr/share/nginx/html/devacademy:ro
```

```bash
docker compose restart nginx
```

---

## 🤖 Локальный ИИ (Ollama + Open WebUI)

### Установка NVIDIA (если есть GPU)

```bash
# Драйвер
sudo apt install -y ubuntu-drivers-common
sudo ubuntu-drivers devices | grep recommended
sudo apt install -y nvidia-driver-580
sudo reboot

# После перезагрузки — проверить
nvidia-smi

# NVIDIA Container Toolkit
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
  sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] \
  https://nvidia.github.io/libnvidia-container/stable/deb/amd64 /" | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt update && sudo apt install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

# Проверка
docker run --rm --runtime=nvidia nvidia/cuda:12.0-base nvidia-smi
```

### Загрузка моделей

```bash
# Рекомендованные для 4 GB VRAM
docker exec homelib-ollama ollama pull qwen2.5:3b
docker exec homelib-ollama ollama pull llama3.2:3b
docker exec homelib-ollama ollama pull phi3:mini
docker exec homelib-ollama ollama pull deepseek-r1:1.5b
docker exec homelib-ollama ollama pull tinyllama:1.1b

# Список загруженных моделей
docker exec homelib-ollama ollama list

# Удалить модель
docker exec homelib-ollama ollama rm <название>

# Проверить, что GPU виден
docker exec homelib-ollama nvidia-smi
```

### Использование

**Веб-интерфейс:** `http://192.168.1.94:8091/`  
**API:**
```bash
curl http://192.168.1.94:11434/api/generate -d '{
  "model": "qwen2.5:3b",
  "prompt": "Привет!",
  "stream": false
}'
```

---

## 📝 Работа с сервисами

### Kanboard (задачи)

- Создать проект → доски → колонки → задачи
- API: `http://192.168.1.94:8081/jsonrpc.php`
- Экспорт: **Project Settings → Export**

### Trilium (заметки)

- Иерархия: дневник, проекты, ссылки
- Прокси: `http://192.168.1.94:24/notes/`
- Импорт/экспорт: **Settings → Backup**

### FileBrowser (файлы)

- Два корня: `/srv/hdd1` и `/srv/hdd2`
- Загрузка, скачивание, редактирование
- Прямой доступ: `http://192.168.1.94:8082/`

### CyberChef (данные)

- 300+ операций: Base64, Hex, JSON, AES, Gzip
- Прямой доступ: `http://192.168.1.94:8087/`

---

## 🔧 Управление контейнерами

```bash
# Все сервисы
docker compose up -d                    # запустить
docker compose down                     # остановить
docker compose restart                  # перезапустить
docker compose logs -f <сервис>         # логи
docker compose ps                       # статус
docker compose pull                     # обновить образы

# Отдельный сервис
docker compose up -d <сервис>
docker compose down <сервис>
docker compose restart <сервис>
docker logs homelib-<сервис> --tail 30

# Kiwix (отдельно)
docker restart homelib-kiwix
docker logs homelib-kiwix --tail 30
```

### Проверка конфигурации Nginx

```bash
docker exec homelib-nginx nginx -t
docker exec homelib-nginx nginx -s reload
```

---

## 💾 Резервное копирование

### Бэкап конфигов

```bash
cd ~
tar -czf homelab-config-$(date +%Y%m%d).tar.gz \
  auto-homelib/nginx \
  auto-homelib/kanboard \
  auto-homelib/tileserver \
  auto-homelib/docker-compose.yml \
  auto-homelib/.env \
  /opt/homelab/
```

### Бэкап данных

```bash
# HDD1 (книги, ZIM, музыка)
sudo tar -czf hdd1-backup-$(date +%Y%m%d).tar.gz -C /mnt/hdd1/docker \
  books kiwix music

# HDD2 (карты, БД, модели ИИ)
sudo tar -czf hdd2-backup-$(date +%Y%m%d).tar.gz -C /mnt/hdd2/docker \
  trilium kanboard filebrowser maps
```

### Восстановление

```bash
# Распаковать конфиги
tar -xzf homelab-config-YYYYMMDD.tar.gz -C ~/

# Распаковать данные
sudo tar -xzf hdd1-backup-YYYYMMDD.tar.gz -C /mnt/hdd1/docker
sudo chown -R 1000:1000 /mnt/hdd1/docker

# Запустить
cd ~/auto-homelib
docker compose up -d
```

### Автоматический бэкап (cron)

```bash
sudo tee /etc/cron.d/homelab-backup > /dev/null << 'EOF'
0 3 * * 0 malkavlib cd /home/malkavlib && tar -czf /mnt/hdd2/backup/homelab-config-$(date +\%Y\%m\%d).tar.gz auto-homelib/nginx auto-homelib/kanboard auto-homelib/tileserver auto-homelib/docker-compose.yml
EOF
```

---

## 🆘 Диагностика и решение проблем

### Проверка портов

```bash
sudo ss -tlnp | grep -E ':(24|8081|8082|8083|8084|8085|8087|8089|8090|8091|61208|11434)'
```

### Проверка Docker-сети

```bash
docker network inspect homelib-net | grep -E "Name|IPv4Address"
```

### Проверка доступа к сервисам

```bash
for port in 24 8081 8082 8083 8084 8085 8087 8089 8090 8091 61208; do
  echo -n "Port $port: "
  curl -s -o /dev/null -w "%{http_code}\n" --max-time 2 http://localhost:$port/ 2>/dev/null || echo "FAIL"
done
```

### Частые проблемы

| Симптом | Причина | Решение |
|---------|---------|---------|
| `403 Forbidden` при входе | Неверный `.htpasswd` | Пересоздать: `docker run --rm httpd:alpine htpasswd -nbB admin 'homelib2024' > nginx/.htpasswd` |
| `SSL received a record that exceeded...` | Браузер форсирует HTTPS | Ввести явно `http://IP:24/` или очистить HSTS в браузере |
| `Kanboard 404 на JS/CSS` | `KANBOARD_URL` содержит `/tasks/` | Указать `http://IP:8081/` без `/tasks` |
| `TileServer //_root` ошибка | Комментарии `//` в JSON | Убрать комментарии из `config.json` |
| `Ollama unknown runtime: nvidia` | NVIDIA Toolkit не настроен | `sudo nvidia-ctk runtime configure --runtime=docker` + `systemctl restart docker` |
| `Driver/library version mismatch` | Драйвер обновлён, модуль старый | **Перезагрузить сервер** (`sudo reboot`) |
| `Nginx host not found in upstream` | Контейнер не запущен или не в сети | `docker compose up -d` |
| `location directive not allowed here` | Секция `location` вне блока `server` | Проверить скобки в `nginx.conf` |
| `maplibre-gl.js 401/404` | Файл не в volume или требует авторизацию | Положить в `nginx/` + `auth_basic off` |
| `address already in use` (порт) | Процесс занял порт | `sudo lsof -i :PORT` → `sudo kill -9 PID` |
| `/tmp заполнен 100%` | Мусор от Docker/системы | `sudo rm -rf /tmp/*` + `systemctl restart docker` |
| `No space left on device` | Диск заполнен | `docker system prune -af` + очистка логов |

### Логи проблемных сервисов

```bash
docker logs homelib-nginx --tail 50
docker logs homelib-kanboard --tail 50
docker logs homelib-tileserver --tail 50
docker logs homelib-ollama --tail 50
docker logs homelib-kiwix --tail 50
sudo journalctl -u hardware-api -n 30
```

### Проверка GPU

```bash
# На хосте
nvidia-smi

# В контейнере Ollama
docker exec homelib-ollama nvidia-smi

# Тест через CUDA-контейнер
docker run --rm --runtime=nvidia nvidia/cuda:12.0-base nvidia-smi
```

### Полный сброс

```bash
# Остановить всё
docker compose down
docker rm -f homelib-kiwix 2>/dev/null

# Очистить Docker
docker system prune -af
docker volume prune -f

# Перезапустить
docker compose up -d

# Kiwix — отдельно (см. раздел «Быстрый старт», п.9)
```

---

## 🌐 Доступ ко всем сервисам

| Сервис | URL |
|--------|-----|
| **Дашборд** | `http://192.168.1.94:24/` |
| **Kanboard** | `http://192.168.1.94:8081/` |
| **FileBrowser** | `http://192.168.1.94:8082/` |
| **Calibre-Web** | `http://192.168.1.94:8083/` |
| **Kiwix** | `http://192.168.1.94:8084/` |
| **TileServer** | `http://192.168.1.94:8085/` |
| **CyberChef** | `http://192.168.1.94:8087/` |
| **Hardware API** | `http://192.168.1.94:8089/api/hardware` |
| **Navidrome** | `http://192.168.1.94:8090/` |
| **Open WebUI** | `http://192.168.1.94:8091/` |
| **Glances** | `http://192.168.1.94:61208/` |
| **Ollama API** | `http://192.168.1.94:11434/` |
| **Trilium** | `http://192.168.1.94:24/notes/` |
| **DevAcademy** | `http://192.168.1.94:24/devacademy/` |

---

## 🔑 Учётные данные

| Сервис | Логин | Пароль |
|--------|-------|--------|
| Nginx Basic Auth | `admin` | `homelib2024` |
| Kanboard | `admin` | `admin` |
| FileBrowser | `admin` | `homelib2024` |
| Calibre-Web | `admin` | `admin123` |
| Navidrome | `admin` | `homelib2024` |
| Trilium | `admin` | `homelib2024` |
| Open WebUI | *(регистрация)* | *(свой)* |

**Сменить дефолтные пароли после первого запуска!**

---

## 📋 Полезные ссылки

- **Репозиторий:** `https://github.com/ignatyevnik/auto-homelib`
- **DevAcademy:** `https://github.com/ignatyevnik/DevAcademy`
- **Kiwix-зеркала:**
  - `http://iso.nl.netbsd.org/kiwix/zim/`
  - `https://mirrors.dotsrc.org/kiwix/zim/`
- **OSM-данные:** `https://download.geofabrik.de/russia/`
- **Protomaps:** `https://maps.protomaps.com/builds/`
- **Книги:** `https://archive.org/`, `https://libgen.is/`
- **Шрифты для карт:** `https://fonts.openmaptiles.org/`
- **Docker Hub:** `https://hub.docker.com/`
- **Navidrome-клиенты:** DSub (Android), play:Sub (iOS), Ultrasonic

---

## 📝 Changelog (значимые изменения)

- **v3.0** — Переход на Ubuntu Server, Docker Compose v3, добавлены Ollama/Open WebUI/Navidrome/Hardware API
- **v3.0** — Дашборд с двумя темами (Default / Warhammer 40k), локализация RU/EN, сворачиваемая карта
- **v3.0** — Kiwix вынесен из `docker-compose.yml` (запускается отдельно)
- **v3.0** — TileServer переведён на MBTiles с векторными тайлами Северо-Западного региона
- **v2.0** — Добавлены CyberChef, Glances, Trilium, Kanboard, FileBrowser
- **v1.0** — Базовый Nginx + Kiwix + Calibre-Web

---

## 📄 Лицензия

Проект распространяется «как есть», без гарантий. Используйте на свой страх и риск.

Данные (книги, энциклопедии, карты) — из открытых источников (OpenStreetMap, Internet Archive, Kiwix). Соблюдайте лицензии источников.

---

**Автор:** [@ignatyevnik](https://github.com/ignatyevnik)  
**Обновлено:** ноябрь 2026  
**Версия:** v3.0
