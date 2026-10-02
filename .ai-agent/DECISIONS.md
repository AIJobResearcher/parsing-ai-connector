# Decisions

Status: living · Date: 2026-09-21 · Owner: engineering

1. Local runtime is the Deploy & Docs Compose stack in
   `deploy/parsing-ai-connector/local/docker-compose.yml`, services `app`,
   `worker`, `worker-browser`, `beat`, `postgres`, `rabbitmq`, `redis`,
   `qdrant` — one source of truth for names and ports — 2026-10-02.
2. Containers are named `parsing-ai-<service>` and run as non-root user `app`
   with uid/gid from build args `UID`/`GID` (default 1000) — the `.:/app` bind
   mount needs host-matching permissions — 2026-10-02.
3. Host ports: app `${APP_PORT}` (8002 locally) → 8000, postgres 5434 → 5432,
   rabbitmq 5674 → 5672 and 15674 → 15672, redis 6381 → 6379, qdrant 6333 and
   6334 → the same — avoids clashes with the other services — 2026-10-02.
4. Celery module is `app.worker`; `worker` consumes queue `default`,
   `worker-browser` consumes `browser`, and `beat` runs one replica —
   2026-10-02.
5. Container environment is owned by Compose: `AI_PROVIDER=deepseek`,
   `DEEPSEEK_API_KEY`, `DEEPSEEK_MODEL`, `EMBEDDING_PROVIDER`,
   `EMBEDDING_MODEL`, `DATABASE_URL`, `CELERY_BROKER_URL`,
   `CELERY_RESULT_BACKEND`, `REDIS_URL`, `QDRANT_URL` — `.env` supplies only
   the substitution inputs — 2026-10-02.
6. Redis divides logical databases: result backend `1`, cache and locks `2` —
   one instance without key collisions — 2026-10-02.
7. The app exposes `GET /health` — used by the Compose healthcheck of `app` —
   2026-10-02.
