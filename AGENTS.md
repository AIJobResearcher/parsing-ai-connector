# Agent Instructions

## 1. General

- **Stack:** Python 3.14, FastAPI, Celery, RabbitMQ.
- **Approaches:** Clean Architecture (DDD, event-driven, CQRS); GRASP, SOLID,
  YAGNI, KISS.

## 2. Documentation

- Docs are not gospel; report contradictions to the user.
- Key files (reference and Ubiquitous Language):
  `docs/domain/bounded-contexts/parsing-ai-connector.md`,
  `docs/api/parsing-ai-connector/openapi.yaml`,
  `docs/asyncapi/events.yaml`, `docs/event-storming/ai-parsing.md`,
  `docs/context-map.md`.
- If an answer exists there, provide a reference, not a summary.
- Before implementing or changing an endpoint, read its OpenAPI section and
  compare it with the current code; on divergence report it in one line and
  ask which side is authoritative before writing code.

## 3. Technical Requirements

- Use current stack features (see 1), avoid outdated approaches; code must
  pass the formatter, linter and type checker configured in `pyproject.toml`
  (see `.ai-agent/standards/python-standards.md`).
- Dependency direction: Presentation → Application → Domain; Domain must not
  depend on Infrastructure. Business logic in Domain, orchestration in
  Application.
- Schema changes only via Alembic migrations.
- Validate every request with Pydantic at the boundary; use framework
  security defaults; centralize error handling and structured logging.
- Long work runs in a Celery task, never inside a FastAPI request; every task
  and consumer is idempotent and retry-safe (at-least-once delivery).
- Local runtime: the service is shipped as a container and run with Docker
  Compose; check behaviour through the service container (`curl`, broker CLI),
  never a host Python process.

## 4. Code Quality

- Before editing or writing any file, load and strictly obey its standard:
  - Python code → `.ai-agent/standards/python-standards.md`
  - Tests → `.ai-agent/standards/testing-standards.md`
  - Text in `*.md` files → `.ai-agent/standards/md-files-standards.md`

## 5. Token Efficiency

- `.ai-agent/standards/token-economy-rules.md` is the single home for the
  reading, context, deliberation, asking, verification and reporting cost
  rules; load it before any task that reads, searches, or edits the
  repository.

## 5a. Definition of done

- A task is done only when its requested scope is fully addressed — no
  partial hand-offs expecting a follow-up. Ask on genuine blockers; otherwise
  complete it and report per Token Efficiency (see 5).

## 6. Limitations

- Only the Parsing&AIConnector service. Do not change API, architecture,
  existing files, configs (`pyproject.toml`, `Dockerfile`,
  `docker-compose.yml`, CI workflows, etc.), dependencies, or documentation
  without explicit request.
- Never run analyzers/tests/migrations/dependency updates on your own
  initiative (formatter, linter, type checker, pytest, Alembic, `uv`/`pip`).
  Run them ONLY on an explicit "run" request or "fix and verify"; a pasted
  error list alone means fix exactly what is reported and STOP — no tool
  runs, no extra analyzers, no widened scope. Do not self-verify edits by
  running gates; self-check with `python -m py_compile` and a container
  runtime call (see 3) instead. On an explicit run request, scope to the
  changed files only and re-report briefly.
