SHELL := /usr/bin/env bash
COMPOSE := docker compose
PSQL := $(COMPOSE) exec -T timescaledb psql \
  -U $${POSTGRES_USER:-telemetry_user} \
  -d $${POSTGRES_DB:-telemetry} \
  -v ON_ERROR_STOP=1

.PHONY: up down restart status logs smoke

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
