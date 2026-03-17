.PHONY: up down logs status clean setup

up:
	@echo "Starting Airbyte services..."
	docker-compose up -d
	@echo ""
	@echo "Waiting for services to be ready..."
	@sleep 30
	@echo ""
	@echo "Airbyte UI available at: http://localhost:8000"
	@echo "Default credentials: airbyte / password"

down:
	@echo "Stopping Airbyte services..."
	docker-compose down

logs:
	docker-compose logs -f

logs-server:
	docker-compose logs -f airbyte-server

status:
	@echo "Service Status:"
	@docker-compose ps

clean:
	@echo "Removing all Airbyte data..."
	docker-compose down -v
	@echo "Done."

setup: up
	@echo ""
	@echo "=========================================="
	@echo "Airbyte Setup Complete"
	@echo "=========================================="
	@echo ""
	@echo "Next steps:"
	@echo "1. Open http://localhost:8000"
	@echo "2. Configure sources and destinations"
	@echo "3. Create connections"
	@echo "4. Run sync"

restart:
	docker-compose restart

source-shell:
	docker exec -it airbyte-source-postgres psql -U source_user -d source_db

dest-shell:
	docker exec -it airbyte-destination-postgres psql -U warehouse_user -d warehouse
