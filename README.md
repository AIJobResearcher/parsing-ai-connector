# Parsing&AIConnector

Status: living · Date: 2026-10-02 · Owner: engineering

Parsing&AIConnector is the Python service of AIJobResearcher that parses
external job portals and generates AI recommendations and RAG answers. It
serves a FastAPI HTTP API, background Celery workers and scheduled portal
watches. This document describes the service itself, how to deploy it locally
and how to test it; it covers this repository only.

## 1. Overview

- **1.1** Stack: Python, FastAPI, Celery, PostgreSQL 18, Redis, RabbitMQ and
  Qdrant; AI runs on the DeepSeek API behind an ACL port.
- **1.2** Dependency direction: `app/presentation` → `app/application` →
  `app/domain`; `app/infrastructure` and `app/tasks` sit at the edge.
- **1.3** Python floor is 3.10: the API and plain workers run on 3.13, the
  browser worker uses the Playwright image (3.10).
- **1.4** Runtime versions and the platform contract live in
  `docs/architecture-overview.md`; environment facts are recorded in
  `.ai-agent/DECISIONS.md`.

## 2. Requirements

- **2.1** Docker Engine with Compose v2.
- **2.2** `make`, `curl`, `unzip`, `rsync` and `git`.
- **2.3** Network access to GitHub (deploy files), PyPI and the
  `mcr.microsoft.com` Playwright image.

## 3. Deployment

Deploy files live in the Deploy & Docs repository and are downloaded at build
time; this repository keeps only the Makefile and the `deploy/` wrappers.

- **3.1** Build and start the whole stack:

```bash
make build
```

- **3.2** `make build` syncs `docs/` and `.ai-agent/` (`make sync`), downloads
  `deploy/parsing-ai-connector/local/build.sh`, builds the images, starts the
  containers and runs `alembic upgrade head`.
- **3.3** Day-to-day commands:

| Command | Action |
| --- | --- |
| `make up` | start the stack |
| `make down` | stop the stack |
| `make logs` | follow container logs |
| `make exec` | shell in the `app` container |
| `make migrate` | apply Alembic migrations |
| `make sync` | refresh `docs/` and `.ai-agent/` from Docs |

- **3.4** The API answers on `http://localhost:8002`; the health endpoint is
  `GET /health`. Compose service names, ports and environment variables are
  listed in `.ai-agent/DECISIONS.md`.

## 4. Testing

Tests and static analysis run inside the `app` container, so start the stack
first (`make up`).

- **4.1** Everything at once:

```bash
make test
```

- **4.2** Individual commands:

| Command | Action |
| --- | --- |
| `make test-unit` | pytest `tests/unit` |
| `make test-integration` | pytest `tests/integration` |
| `make test-db-prepare` | create and migrate the test database |
| `make test-coverage` | pytest with an HTML coverage report |
| `make test-lint` | ruff check |
| `make test-format` | ruff format --check |
| `make test-types` | mypy |
| `make test-md` | markdownlint over tracked Markdown |
| `make test-static` | ruff, mypy and markdownlint together |

- **4.3** Analyzers are not a self-check: run them on request only, as stated
  in `AGENTS.md` §6.

## 5. Documentation

- **5.1** `docs/` is synced from the Deploy & Docs repository; never edit it
  here.
- **5.2** Contracts: `docs/api/parsing-ai-connector/openapi.yaml` (HTTP) and
  `docs/asyncapi/events.yaml` (events).
- **5.3** Agent rules: `AGENTS.md`; project decisions:
  `.ai-agent/DECISIONS.md`.
