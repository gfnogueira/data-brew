SHELL := /usr/bin/env bash
COMPOSE := docker compose

.PHONY: up down restart status logs smoke psql mc init seed mutate snapshots evolution concurrent

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

seed:
	cd scripts && python run_operations.py 01_seed_initial.sql

mutate:
	cd scripts && python run_operations.py 02_mutations.sql

snapshots:
	cd scripts && python run_operations.py 03_time_travel.sql 04_changes_inspection.sql

evolution:
	cd scripts && python run_operations.py 05_schema_evolution.sql

concurrent:
	cd scripts && python concurrent_writers.py
