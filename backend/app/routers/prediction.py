from fastapi import APIRouter, HTTPException

from app.schemas.yield_prediction import YieldPredictionRequest, YieldPredictionResponse
from app.services.weather_service import get_weekly_forecast
from app.ml.predict import predict_yield_and_risk

router = APIRouter(prefix="/predict", tags=["Prediction"])


@router.post("/yield", response_model=YieldPredictionResponse)
async def predict_yield(req: YieldPredictionRequest, lat: float, lon: float):
    """
    Estimates yield from a trained PSA regional baseline and assesses
    short-term climate risk with transparent forecast thresholds.
    """
    try:
        weather = await get_weekly_forecast(req.municipality, lat, lon)
    except Exception as exc:
        raise HTTPException(status_code=502, detail=f"Weather provider error: {exc}")

    if not weather.daily_forecast:
        raise HTTPException(status_code=502, detail="No forecast data available.")

    max_rain_probability = max(d.rain_probability_pct for d in weather.daily_forecast)
    max_wind = max(d.wind_speed_kph for d in weather.daily_forecast)

    return predict_yield_and_risk(
        req,
        latitude=lat,
        longitude=lon,
        max_rain_probability_pct=max_rain_probability,
        max_wind_kph=max_wind,
    )
