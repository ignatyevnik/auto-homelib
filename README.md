# **Disclaimer**
N \## ENG
The project was created by AI. So do not judge me cruely :)
This project was created to preserve some knowledge in case all the Internet will be shut down due to recent events in the World.
Feel free to write some of the thoughts on this.
With limited resources, but fill of enthusiasm, I would like to share this "attempt" to help secure yourself and have, at least, a possibility to find the information you need about medicine (first-aid), agriculture, fixing auto (but only popular in Russia and former soviet countries), school books and some other things.

The data is needed to be downloaded and moved to the target machine to deploy. It has offline maps for some region. If needed, I can correct the project later to manipulate different packages.
It contains 

**Be vary, that is not an easy task, if you are not quite familiar with Linux, docker, nginx, bash or terminal.**

Most of the files contain tips or what is it about. 

System requirements (for my case) are located in the doc CONTENT_SOURCES.md.

**!!NB!!**
Some files are named like tileserver_config.json and filebrowser.config.json. They should be located according to the docker-compose.yml file and renamed back to the config.json.

 
# \## RU
Данный проект был создан с помощью ИИ, так что не судите строго :)
Проект был создан с целью сохранить некоторые знания, в случае если интернет будет отключен из-за недавних событий в мире.
Можете свободно писать свои мысли по этому поводу.
Полон интузиазма, но с ограниченными ресурсами, я бы хотел поделиться "попыткой" обезопасить себя и, хотя бы иметь возможность найти информацию, которая нужна про медицину (оказание первой помощи), сельское хозяйство, ремонт автомобилей (но только популярные в России и бывших стран СССР), школьные учебники и некоторые другие вещи.

**Будьте внимательны, так как это может показаться нелегкой задачей, если вы не знакомы с такими вещами как Линукс, докер, сервер nginx, bash или терминал.**

Большинство файлов содержит подсказки и что они обозначают.

Системные требования (для моего случая) находятся в документе CONTENT_SOURCES.md.

**!!NB!!**
Некоторые файл именованы как tileserver_config.json и filebrowser.config.json. Они должны располагаться согласно файлу docker-compose.yml и переименованы обратно в config.json.

# 📚 Offline Library Hub v2.5
Полностью автономная домашняя библиотека, оффлайн-карты, система задач и база знаний. Работает без интернета.
Fully autonomous home library, offline maps, task tracker and knowledge base. Works without internet.

## ⚙️ Требования/Requirements
- CPU: Intel Xeon E5-1650v1 (Sandy Bridge, AVX)
- RAM: 16 GB DDR3 + ZRAM (8 GB Swap)
- SSD 240 GB → `/` (ОС + Docker)
- HDD1 250 GB → `/mnt/hdd1` (active data)
- HDD2 250 GB → `/mnt/hdd2` (raw/source files, backup)
- OS: Ubuntu 22.04/24.04 Server (Minimal)

## 🚀 Быстрый старт/Quick Start
1. `git clone <repo_url> ~/offline-library-hub`
2. `cd ~/offline-library-hub && cp .env.example .env && nano .env`
3. `chmod +x scripts/*.sh && sudo ./scripts/01-init-server.sh`
4. `docker compose up -d`
5. Откройте/Open `http://<SERVER_IP>`

## 🔐 Первый вход/First Login
- `/files/` → login/password from `.env` (FB_USERNAME/FB_PASSWORD)
- `/tasks/` → admin / admin (смените в настройках Kanboard/Change in the settings of Kanboard)
- `/notes/` → создаст базу при первом запуске, задаст пароль/creates database upon the first launch, sets password
- `/status/` → login/password from `.env` (NGINX_ADMIN_*)

## 🔄 Обновление/Update
Подключите флешку в `/mnt/usb`, затем: (Mount the flash USB in `/mnt/usb`, and then):
```bash
sudo ./scripts/03-update.sh

# 📚 Источники контента v2.5/Content Sources (Most of them are in Russian, but you can try to replace them for your needs

## 🔧 Компьютеры & Мобильные устройства/PCs and Mobile Devices
- `ifixit.com/guides` → оффлайн-архив
- `badcaps.net`, `radiokot.ru`, `elremont.ru` → схемы, ремонт
- `datasheetarchive.com` → чипы, контроллеры
- Структура: `docs/tech/computers`, `docs/tech/mobile`

## 🧪 Химия & 📐 Матанализ/Chemistry and Mathematical analisys
- Глинка, Кузнецов, Фриман, Архипов/Ильин/Позняк
- Демидович (задачи), Фихтенгольц (курс)
- Структура: `docs/school/chemistry`, `docs/school/math_analysis`

## 📖 Советские учебники (1930–1990)/Soviet schoolbooks
- `sovietbook.ru`, `lib.ru/school`, `archive.org`
- Киселёв, Перышкин, Плешаков, Гуревич
- Конвертация: `./scripts/djvu_to_pdf.sh`
- Структура: `docs/school/soviet`

## 🌐 Kiwix ZIM
- `wikipedia_ru_all_nopic.zim`, `wikibooks_ru_all_maxi.zim`, `stack_exchange_ru.zim`, `stack_exchange_math.zim`
