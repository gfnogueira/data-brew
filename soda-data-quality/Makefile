.PHONY: up down scan scan-local scan-verbose clean install

up:
	@echo "Starting PostgreSQL..."
	docker-compose up -d
	@echo "Waiting for database..."
	@sleep 5

down:
	@echo "Stopping PostgreSQL..."
	docker-compose down

scan:
	@echo "Running Soda scans..."
	soda scan -d raw_warehouse -c configuration.yml checks/raw_customers.yml checks/raw_products.yml checks/raw_orders.yml

scan-local:
	@echo "Running Soda scans (local, no cloud)..."
	soda scan -d raw_warehouse -c configuration.yml checks/raw_customers.yml checks/raw_products.yml checks/raw_orders.yml --local

scan-verbose:
	soda scan -d raw_warehouse -c configuration.yml checks/raw_customers.yml checks/raw_products.yml checks/raw_orders.yml -V

scan-customers:
	soda scan -d raw_warehouse -c configuration.yml checks/raw_customers.yml --local

scan-products:
	soda scan -d raw_warehouse -c configuration.yml checks/raw_products.yml --local

scan-orders:
	soda scan -d raw_warehouse -c configuration.yml checks/raw_orders.yml --local

install:
	pip install -r requirements.txt

clean:
	docker-compose down -v
