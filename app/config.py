"""Runtime configuration read from the container environment."""

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Settings supplied by Docker Compose."""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    app_env: str = "local"
    log_level: str = "info"

    database_url: str = (
        "postgresql+psycopg://parsing_user:secret@postgres:5432/parsing_ai"
    )
    celery_broker_url: str = "amqp://guest:guest@rabbitmq:5672//"
    celery_result_backend: str = "redis://redis:6379/1"
    redis_url: str = "redis://redis:6379/2"
    qdrant_url: str = "http://qdrant:6333"

    ai_provider: str = "deepseek"
    deepseek_api_key: str = ""
    deepseek_model: str = "deepseek-chat"
    embedding_provider: str = ""
    embedding_model: str = ""


settings = Settings()
