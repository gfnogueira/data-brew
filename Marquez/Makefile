# Marquez Demo Makefile
# Supports both Docker and Podman

# Detect container engine
CONTAINER_ENGINE := $(shell command -v podman 2> /dev/null || echo docker)
COMPOSE_CMD := $(CONTAINER_ENGINE)-compose

.PHONY: help start stop restart status clean logs demo validate

help: ## Show this help message
	@echo "Marquez Demo"
	@echo "Container Engine: $(CONTAINER_ENGINE)"
	@echo ""
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

start: ## Start all services
	@echo "Starting Marquez with $(CONTAINER_ENGINE)..."
	$(COMPOSE_CMD) up -d
	@echo "Services starting... This may take 2-3 minutes"
	@echo "Check status with: make status"

stop: ## Stop all services
	@echo "Stopping services..."
	$(COMPOSE_CMD) down

restart: ## Restart all services
	@echo "Restarting services..."
	$(COMPOSE_CMD) down
	$(COMPOSE_CMD) up -d

status: ## Check service status
	@echo "Service Status:"
	@echo "==============="
	$(COMPOSE_CMD) ps
	@echo ""
	@echo "Health Check:"
	@echo "============="
	@if curl -s -f http://localhost:5555/api/v1/namespaces > /dev/null 2>&1; then \
		echo "API: OK"; \
	else \
		echo "API: NOT READY"; \
	fi
	@if curl -s -f http://localhost:3000 > /dev/null 2>&1; then \
		echo "Web UI: OK"; \
	else \
		echo "Web UI: NOT READY"; \
	fi

logs: ## Show service logs
	$(COMPOSE_CMD) logs -f

clean: ## Remove all containers and volumes
	@echo "Cleaning up..."
	$(COMPOSE_CMD) down -v --remove-orphans
	@if [ "$(CONTAINER_ENGINE)" = "podman" ]; then \
		podman volume prune -f; \
	else \
		docker volume prune -f; \
	fi

demo: ## Setup complete demo environment
	@echo "Setting up demo environment..."
	make start
	@echo "Waiting for services to be ready..."
	@sleep 30
	./load-demo-data.sh
	@echo "Demo ready at: http://localhost:3000"

validate: ## Validate demo is working
	@echo "Validating demo..."
	@./validate-demo.sh
