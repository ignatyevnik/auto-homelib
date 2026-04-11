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