.PHONY: up down bootstrap status logs run-sql run-part2 run-part3 validate-all

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

run-sql:
	bash scripts/run_sql_file.sh $(FILE)

run-part2:
	bash scripts/run_sql_file.sh sql/01_create_namespace_and_tables.sql
	bash scripts/run_sql_file.sh sql/02_ingest_baseline_data.sql
	bash scripts/run_sql_file.sh sql/03_merge_upserts.sql

run-part3:
	bash scripts/run_sql_file.sh sql/04_schema_evolution.sql
	bash scripts/run_sql_file.sh sql/05_time_travel_and_rollback.sql
	bash scripts/run_sql_file.sh sql/06_trino_validation_queries.sql

validate-all: run-part2 run-part3
