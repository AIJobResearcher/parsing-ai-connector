"""Celery application and queue routing.

The `default` queue is consumed by the `worker` service, the `browser` queue by
`worker-browser` (see `.ai-agent/DECISIONS.md`).
"""

from celery import Celery

from app.config import settings

celery = Celery(
    "parsing_ai",
    broker=settings.celery_broker_url,
    backend=settings.celery_result_backend,
)
celery.conf.task_default_queue = "default"
celery.conf.task_routes = {"app.tasks.browser.*": {"queue": "browser"}}
celery.conf.imports = ("app.tasks",)
# RabbitMQ 4 rejects transient non-exclusive queues by default, and Celery's
# pidbox (control/mingle) and event (gossip/heartbeat) queues are exactly that.
# Durable queues are allowed and keep the shared queues usable by every worker.
celery.conf.control_queue_durable = True
celery.conf.event_queue_durable = True

# `celery -A app.worker` resolves a module-level application instance.
app = celery
