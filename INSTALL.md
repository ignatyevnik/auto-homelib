# Установка HomeLab на Ubuntu Server

## 1. Подготовка системы
```bash
# Установка Docker
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER
newgrp docker

# Проверка UID (должен быть 1000)
id -u