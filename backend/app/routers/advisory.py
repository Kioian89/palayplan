from datetime import date
from fastapi import APIRouter, HTTPException

from app.schemas.yield_prediction import AdvisoryItem
from app.services.weather_service import get_weekly_forecast
from app.services.advisory_engine import generate_advisories

router = APIRouter(prefix="/advisory", tags=["Advisory"])


@router.get("/", response_model=list[AdvisoryItem])
async def get_advisories(
    municipality: str,
    lat: float,
    lon: float,
    start_date: date,
    days_to_maturity: int,
):
    """
    Combines the live weather forecast with the crop's current growth stage
    to produce Smart Alerts (e.g. "hold off fertilizing", "good drying day").
    """
    try:
        weather = await get_weekly_forecast(municipality, lat, lon)
    except Exception as exc:
        raise HTTPException(status_code=502, detail=f"Weather provider error: {exc}")

    return generate_advisories(start_date, days_to_maturity, weather)
