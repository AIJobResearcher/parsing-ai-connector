.PHONY: build sync up down exec logs migrate test test-unit test-integration \
        test-coverage test-db-prepare test-lint test-format test-types \
        test-static test-md

# ===== Infrastructure =====

# Copies docs/ and .ai-agent/ from the Deploy & Docs service.
sync:
	chmod +x deploy/sync.sh
	./deploy/sync.sh

# Syncs from Deploy & Docs, then downloads and runs its build script.
build:
	chmod +x deploy/deploy.sh
	./deploy/deploy.sh

up:
	docker compose up -d

down:
	docker compose down

exec:
	docker compose exec app sh

logs:
	docker compose logs -f

# ===== Database =====

migrate:
	docker compose exec -T app alembic upgrade head

test-db-prepare:
	@echo "Creating test database..."
	docker compose exec -T postgres psql -U parsing_user -c "CREATE DATABASE parsing_ai_test;" 2>/dev/null || true
	@echo "Running migrations on test database..."
	docker compose exec -T -e DATABASE_URL=postgresql+psycopg://parsing_user:parsing_password@postgres:5432/parsing_ai_test app alembic upgrade head

# ===== Tests =====

test: test-unit test-lint test-format test-types
	@echo "All tests and static analysis checks passed"

test-unit:
	docker compose exec -T app pytest tests/unit

test-integration:
	docker compose exec -T app pytest tests/integration

test-coverage:
	docker compose exec -T app pytest --cov=app --cov-report=html

# ===== Static analysis =====

test-lint:
	docker compose exec -T app ruff check .

test-format:
	docker compose exec -T app ruff format --check .

test-types:
	docker compose exec -T app mypy app

test-static: test-lint test-format test-types test-md
	@echo "All static analysis checks passed"

# ===== Markdown (documentation) linting =====

# Lints every Markdown file tracked by git; rules live in .markdownlint.json.
MD_CONFIG ?= .markdownlint.json
MD_FILES := $(shell git ls-files '*.md')
MARKDOWNLINT ?= npx --yes markdownlint-cli2@0.23.3

test-md:
	$(MARKDOWNLINT) --config $(MD_CONFIG) $(MD_FILES)
	@echo "Markdown lint passed"
