"""Health endpoint used by the Compose healthcheck of `app`."""

from fastapi import APIRouter

router = APIRouter(tags=["health"])


@router.get("/health")
async def health() -> dict[str, str]:
    """Report that the process is alive."""
    return {"status": "ok"}
