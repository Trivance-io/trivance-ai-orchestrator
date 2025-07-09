.PHONY: help up down logs rebuild clean status shell-management shell-auth

# Default target
help: ## Show this help message
	@echo "Trivance Docker Management"
	@echo "========================="
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

up: ## Start all services
	@echo "🚀 Starting Trivance services..."
	docker-compose up -d
	@echo "✅ Services started. Check logs with 'make logs'"

down: ## Stop all services
	@echo "🛑 Stopping Trivance services..."
	docker-compose down
	@echo "✅ Services stopped"

logs: ## Show logs for all services
	docker-compose logs -f

logs-management: ## Show logs for management service only
	docker-compose logs -f ms_level_up_management

logs-auth: ## Show logs for auth service only
	docker-compose logs -f ms_trivance_auth

rebuild: ## Rebuild and restart all services
	@echo "🔄 Rebuilding services..."
	docker-compose down
	docker-compose build --no-cache
	docker-compose up -d
	@echo "✅ Services rebuilt and restarted"

clean: ## Remove all containers, images and volumes
	@echo "🧹 Cleaning up Docker resources..."
	docker-compose down -v --rmi all
	@echo "✅ Cleanup completed"

status: ## Show status of all services
	docker-compose ps

shell-management: ## Open shell in management service
	docker-compose exec ms_level_up_management sh

shell-auth: ## Open shell in auth service
	docker-compose exec ms_trivance_auth sh

# Database management
db-reset: ## Reset all databases (WARNING: destroys data)
	@echo "🗑️  Resetting databases..."
	docker-compose down -v
	docker-compose up -d postgres mongodb
	@echo "✅ Databases reset and ready"

db-logs: ## Show database logs
	docker-compose logs -f postgres mongodb
