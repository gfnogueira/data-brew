.PHONY: up down bootstrap status logs

up:
	docker compose up -d

down:
	docker compose down -v

bootstrap:
	bash scripts/bootstrap.sh

status:
	docker compose ps

logs:
	docker compose logs -f --tail=100
