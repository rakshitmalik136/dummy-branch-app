.PHONY: help dev staging prod stop clean logs

help:
	@echo "Available commands:"
	@echo "  make dev       - Run in development mode"
	@echo "  make staging   - Run in staging mode"
	@echo "  make prod      - Run in production mode"
	@echo "  make stop-dev  - Stop development environment"
	@echo "  make stop-staging - Stop staging environment"
	@echo "  make stop-prod - Stop production environment"
	@echo "  make clean     - Clean all containers and volumes"
	@echo "  make logs      - View logs"

dev:
	@echo "Starting DEVELOPMENT environment..."
	docker-compose --env-file .env.dev up --build -d
	@echo "Waiting for services to be healthy..."
	@sleep 15
	docker-compose --env-file .env.dev exec api alembic upgrade head || true
	docker-compose --env-file .env.dev exec api python scripts/seed.py || true
	@echo "Development environment ready!"
	@echo "Access at: https://branchloans.com/health"

staging:
	@echo "Starting STAGING environment..."
	docker-compose --env-file .env.staging up --build -d
	@echo "Waiting for services to be healthy..."
	@sleep 15
	docker-compose --env-file .env.staging exec api alembic upgrade head || true
	docker-compose --env-file .env.staging exec api python scripts/seed.py || true
	@echo "Staging environment ready!"
	@echo "Access at: https://branchloans.com/health"

prod:
	@echo "Starting PRODUCTION environment..."
	docker-compose --env-file .env.prod up --build -d
	@echo "Waiting for services to be healthy..."
	@sleep 15
	docker-compose --env-file .env.prod exec api alembic upgrade head || true
	@echo "Production environment ready!"
	@echo "Access at: https://branchloans.com/health"
	@echo "Note: Production data is NOT seeded automatically"

stop-dev:
	@echo "Stopping development environment..."
	docker-compose --env-file .env.dev down

stop-staging:
	@echo "Stopping staging environment..."
	docker-compose --env-file .env.staging down

stop-prod:
	@echo "Stopping production environment..."
	docker-compose --env-file .env.prod down

clean:
	@echo "Cleaning up all environments..."
	docker-compose --env-file .env.dev down -v 2>/dev/null || true
	docker-compose --env-file .env.staging down -v 2>/dev/null || true
	docker-compose --env-file .env.prod down -v 2>/dev/null || true
	docker system prune -f
	@echo "Cleanup complete!"

logs:
	docker-compose logs -f
