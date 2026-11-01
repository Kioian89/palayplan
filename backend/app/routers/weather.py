from fastapi import APIRouter, HTTPException

from app.schemas.weather import WeatherResponse
from app.services.weather_service import get_weekly_forecast

router = APIRouter(prefix="/weather", tags=["Weather"])


@router.get("/forecast", response_model=WeatherResponse)
async def forecast(municipality: str, lat: float, lon: float):
    """Hyper-local 7-day forecast for the farmer's registered location."""
    try:
        return await get_weekly_forecast(municipality, lat, lon)
    except Exception as exc:
        raise HTTPException(status_code=502, detail=f"Weather provider error: {exc}")
