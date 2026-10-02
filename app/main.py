"""FastAPI application entry point."""

from fastapi import FastAPI

from app.presentation.http.health import router as health_router


def create_app() -> FastAPI:
    """Build the ASGI application."""
    application = FastAPI(
        title="Parsing&AIConnector",
        version="0.1.0",
    )
    application.include_router(health_router)
    return application


app = create_app()
