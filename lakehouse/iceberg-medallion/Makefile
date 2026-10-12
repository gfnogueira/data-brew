.PHONY: up down bootstrap pipeline preview

up:
	docker compose up -d
	@sleep 3

down:
	docker compose down -v

bootstrap:
	bash scripts/bootstrap.sh

pipeline:
	bash scripts/end-to-end.sh

preview:
	uv run python scripts/preview.py
