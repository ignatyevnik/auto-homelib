!!нужна доработка README.MD!!
# 📚 Offline Library Hub v3
Полностью автономная домашняя библиотека, оффлайн-карты, система задач и база знаний. Работает без интернета.

Fully autonomous home library, offline maps, task tracker and knowledge base. Works without internet.

# **Disclaimer**
\## ENG

The project was created by AI. So do not judge me cruely :)

This project was created to preserve some knowledge in case all the Internet will be shut down due to recent events in the World.
Feel free to write some of the thoughts on this.
With limited resources, but fill of enthusiasm, I would like to share this "attempt" to help secure yourself and have, at least, a possibility to find the information you need about medicine (first-aid), agriculture, fixing auto (but only popular in Russia and former soviet countries), school books and some other things.

The data is needed to be downloaded and moved to the target machine to deploy. It has offline maps for some regions of Russian Federation. If needed, I can correct the project later to manipulate different packages.

**Be vary, that is not an easy task, if you are not quite familiar with Linux, docker, nginx, bash or terminal.**

Most of the files contain tips or what is it about. 

 
\## RU

Данный проект был создан с помощью ИИ, так что не судите строго :)

Проект был создан с целью сохранить некоторые знания, в случае если интернет будет отключен из-за недавних событий в мире.
Можете свободно писать свои мысли по этому поводу.
Полон интузиазма, но с ограниченными ресурсами, я бы хотел поделиться "попыткой" обезопасить себя и, хотя бы иметь возможность найти информацию, которая нужна про медицину (оказание первой помощи), сельское хозяйство, ремонт автомобилей (но только популярные в России и бывших стран СССР), школьные учебники и некоторые другие вещи.

Данные необходимо скачать и перенести на машину, на которой будет развернут проект. Имеются оффлайн карты для некоторых регионов Российской Федерации. Также, если потребуется, я смогу скорректировать проект позже и управлять пакетами.

**Будьте внимательны, так как это может показаться нелегкой задачей, если вы не знакомы с такими вещами как Линукс, докер, сервер nginx, bash или терминал.**

Большинство файлов содержит подсказки и что они обозначают.


# ## ⚙️ Требования/Requirements
- CPU: Intel Xeon E5-1650v1 (Sandy Bridge, AVX)
- RAM: 16 GB DDR3 + ZRAM (8 GB Swap)
- SSD 240 GB → `/` (ОС + Docker)
- HDD1 250 GB → `/mnt/hdd1` (active data)
- HDD2 250 GB → `/mnt/hdd2` (raw/source files, backup)
- OS: Ubuntu 22.04/24.04 Server (Minimal)

# HomeLab с UID=1000 GID=1000

## 🚀 Быстрый старт

```bash
# 1. Клонируем репозиторий
git clone https://github.com/ignatyevnik/auto-homelib.git
cd auto-homelib

# 2. Проверяем UID (должен быть 1000)
id -u  # Должно вывести 1000

# 3. Монтируем HDD с правильными правами
sudo ./scripts/mount_hdd.sh

# 4. Исправляем права на все директории
./scripts/fix_permissions.sh

# 5. Запускаем сервисы
make install
# или
docker compose up -d

# 6. Проверяем статус
make status
