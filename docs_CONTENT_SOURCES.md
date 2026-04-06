# 📚 Offline Library Hub v2.5
Полностью автономная домашняя библиотека, оффлайн-карты, система задач и база знаний. Работает без интернета.

## ⚙️ Требования
- CPU: Intel Xeon E5-1650v1 (Sandy Bridge, AVX)
- RAM: 16 GB DDR3 + ZRAM (8 GB сжатый своп)
- SSD 240 GB → `/` (ОС + Docker)
- HDD1 250 GB → `/mnt/hdd1` (активные данные)
- HDD2 250 GB → `/mnt/hdd2` (исходники, бэкапы)
- OS: Ubuntu 22.04/24.04 Server (Minimal)

## 🚀 Быстрый старт
1. `git clone <repo_url> ~/offline-library-hub`
2. `cd ~/offline-library-hub && cp .env.example .env && nano .env`
3. `chmod +x scripts/*.sh && sudo ./scripts/01-init-server.sh`
4. `docker compose up -d`
5. Откройте `http://<SERVER_IP>`

## 🔐 Первый вход
- `/files/` → логин/пароль из `.env` (FB_USERNAME/FB_PASSWORD)
- `/tasks/` → admin / admin (смените в настройках Kanboard)
- `/notes/` → создаст базу при первом запуске, задаст пароль
- `/status/` → логин/пароль из `.env` (NGINX_ADMIN_*)

## 🔄 Обновление
Подключите флешку в `/mnt/usb`, затем:
```bash
sudo ./scripts/03-update.sh