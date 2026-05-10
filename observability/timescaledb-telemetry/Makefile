SHELL := /usr/bin/env bash
COMPOSE := docker compose
PSQL := $(COMPOSE) exec -T timescaledb psql \
  -U $${POSTGRES_USER:-telemetry_user} \
  -d $${POSTGRES_DB:-telemetry} \
  -v ON_ERROR_STOP=1

.PHONY: up down restart status logs smoke init seed stream

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down -v

restart:
	$(COMPOSE) restart timescaledb

status:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs -f --tail=200 timescaledb

smoke:
	$(PSQL) -c "SELECT version(), now(), current_user"

init:
	$(PSQL) -f /dev/stdin < sql/schema/00_extension.sql
	$(PSQL) -f /dev/stdin < sql/schema/01_telemetry_raw.sql
	$(PSQL) -f /dev/stdin < sql/schema/02_indexes.sql
	$(PSQL) -f /dev/stdin < sql/schema/03_telemetry_1m.sql
	$(PSQL) -f /dev/stdin < sql/schema/04_telemetry_1h.sql
	$(PSQL) -f /dev/stdin < sql/schema/05_refresh_policies.sql

seed:
	cd scripts && python seed_data.py

stream:
	cd scripts && python stream_events.py
