from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.database import Base, engine
from app import models  # noqa: F401 - ensures models are registered before create_all
from app.routers import weather, advisory, prediction, auth

app = FastAPI(
    title="PalayPlan API",
    description="Smart Agro-Weather backend for rice yield & schedule optimization.",
    version="0.1.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # tighten this to the mobile app's origin(s) in production
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(weather.router)
app.include_router(advisory.router)
app.include_router(prediction.router)


@app.on_event("startup")
def on_startup():
    # For quick local dev only — use Alembic migrations in production.
    Base.metadata.create_all(bind=engine)


@app.get("/health", tags=["Health"])
def health_check():
    return {"status": "ok", "service": "PalayPlan API"}
