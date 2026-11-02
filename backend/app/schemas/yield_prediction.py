from datetime import date
from typing import Literal
from pydantic import BaseModel, Field


class YieldPredictionRequest(BaseModel):
    seed_variety: str
    days_to_maturity: int = Field(..., ge=90, le=160)
    field_size_hectares: float = Field(..., gt=0)
    start_date: date
    soil_type: str | None = None
    municipality: str
    ecosystem_type: Literal["irrigated", "rainfed"] | None = None


class YieldPredictionResponse(BaseModel):
    predicted_yield_cavans: float
    predicted_yield_tons: float
    climate_risk_level: Literal["low", "medium", "high"]
    risk_factors: list[str]
    prediction_note: str = ""


class AdvisoryItem(BaseModel):
    stage: str                 # e.g. "Fertilization"
    date: date
    message: str
    severity: Literal["info", "warning", "critical"]
