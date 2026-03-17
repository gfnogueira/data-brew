.PHONY: up down deps seed run test report pipeline clean

DBT_DIR = dbt_project

up:
	@echo "Starting PostgreSQL..."
	docker-compose up -d
	@echo "Waiting for database to be ready..."
	@sleep 5

down:
	@echo "Stopping services..."
	docker-compose down

deps:
	@echo "Installing dbt packages..."
	cd $(DBT_DIR) && dbt deps

seed:
	@echo "Loading seed data..."
	cd $(DBT_DIR) && dbt seed

run:
	@echo "Running dbt models..."
	cd $(DBT_DIR) && dbt run

test:
	@echo "Running dbt tests..."
	cd $(DBT_DIR) && dbt test

report:
	@echo "Generating Elementary report..."
	cd $(DBT_DIR) && edr report

pipeline: deps seed run test report
	@echo "Pipeline completed successfully"

debug:
	@echo "Running dbt debug..."
	cd $(DBT_DIR) && dbt debug

clean:
	@echo "Cleaning generated files..."
	rm -rf $(DBT_DIR)/target
	rm -rf $(DBT_DIR)/dbt_packages
	rm -rf $(DBT_DIR)/logs
	rm -rf $(DBT_DIR)/edr_reports

install:
	pip install -r requirements.txt
