# 1. Клонирование (или распаковка архива)

git clone <ваш_репозиторий> ~/offline-library-hub

cd ~/offline-library-hub

# 2. Настройка окружения

cp .env.example .env

nano .env  # Укажите надёжные пароли и локальную подсеть

# 3. Инициализация и запуск

chmod +x scripts/*.sh

sudo ./scripts/01-init-server.sh

docker compose up -d
