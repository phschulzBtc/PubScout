from fastapi import FastAPI

from pubscout.config import settings

app = FastAPI(title=settings.app_name, version="0.1.0")


@app.get("/health")
async def health_check():
    return {"status": "ok", "app": settings.app_name}
