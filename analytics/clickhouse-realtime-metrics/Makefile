SHELL := /usr/bin/env bash
COMPOSE := docker compose
CLIENT := $(COMPOSE) exec -T clickhouse clickhouse-client \
  --user $${CLICKHOUSE_USER:-metrics_user} \
  --password $${CLICKHOUSE_PASSWORD:-metrics_password} \
  --database $${CLICKHOUSE_DATABASE:-realtime}

.PHONY: up down restart status logs smoke

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down -v

restart:
	$(COMPOSE) restart clickhouse

status:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs -f --tail=200 clickhouse

smoke:
	$(CLIENT) --query "SELECT version(), now(), currentUser()"
