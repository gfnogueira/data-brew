SHELL := /usr/bin/env bash
COMPOSE := docker compose

.PHONY: up down restart status logs smoke psql mc init

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down -v

restart:
	$(COMPOSE) restart catalog storage

status:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs -f --tail=200

smoke:
	$(COMPOSE) exec -T catalog psql -U $${CATALOG_USER:-ducklake} -d $${CATALOG_DB:-ducklake_catalog} -c "SELECT version()"
	curl -fsS http://localhost:9000/minio/health/live && echo

psql:
	$(COMPOSE) exec catalog psql -U $${CATALOG_USER:-ducklake} -d $${CATALOG_DB:-ducklake_catalog}

mc:
	@docker run --rm --network host -it \
	  minio/mc:RELEASE.2025-02-08T19-14-21Z \
	  --alias-set local http://localhost:9000 $${STORAGE_ACCESS_KEY:-minioadmin} $${STORAGE_SECRET_KEY:-minioadmin}

init:
	cd scripts && python init_lake.py
