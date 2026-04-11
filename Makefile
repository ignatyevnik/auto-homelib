.PHONY: help install start stop restart logs status fix-perms clean test-network

help:
	@echo "HomeLab Management Commands"
	@echo "============================"
	@echo "make install       - Полная установка"
	@echo "make start         - Запустить сервисы"
	@echo "make stop          - Остановить сервисы"
	@echo "make restart       - Перезапустить"
	@echo "make logs          - Показать логи"
	@echo "make status        - Статус сервисов"
	@echo "make fix-perms     - Исправить права"
	@echo "make test-network  - Проверить сетевой доступ"
	@echo "make clean         - Очистка"

install:
	@echo "🚀 Установка HomeLab..."
	@chmod +x scripts/*.sh
	@./scripts/mount_hdd.sh
	@./scripts/fix_permissions.sh
	@docker compose up -d
	@echo ""
	@echo "✅ Установка завершена!"
	@echo "📍 Доступ: http://192.168.1.46:24"
	@echo ""
	@make test-network

start:
	@docker compose up -d
	@echo "✅ Сервисы запущены"

stop:
	@docker compose down
	@echo "🛑 Сервисы остановлены"

restart:
	@docker compose down
	@docker compose up -d
	@echo "🔄 Сервисы перезапущены"

logs:
	@docker compose logs -f --tail=50

status:
	@echo "📊 Статус контейнеров:"
	@docker compose ps
	@echo ""
	@echo "📊 Использование дисков:"
	@df -h | grep -E "Filesystem|/mnt/hdd"
	@echo ""
	@echo "🌐 Сетевые порты:"
	@sudo netstat -tlnp | grep :24 || echo "Порт 24 не прослушивается"

fix-perms:
	@./scripts/fix_permissions.sh

test-network:
	@echo "🧪 Проверка сетевого доступа..."
	@echo -n "Локальный доступ: "
	@curl -s -o /dev/null -w "%{http_code}" http://localhost:24 || echo "❌ Ошибка"
	@echo ""
	@echo -n "Доступ по IP: "
	@curl -s -o /dev/null -w "%{http_code}" http://192.168.1.46:24 || echo "❌ Ошибка"
	@echo ""
	@echo "📡 Проверка порта 24:"
	@ss -tln | grep :24 || echo "⚠️ Порт 24 не открыт"

clean:
	@echo "🧹 Очистка..."
	@docker system prune -f
	@rm -rf /tmp/nginx-* 2>/dev/null || true
	@echo "✅ Очистка завершена"