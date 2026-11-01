from fastapi import APIRouter, HTTPException

from app.schemas.yield_prediction import YieldPredictionRequest, YieldPredictionResponse
from app.services.weather_service import get_weekly_forecast
from app.ml.predict import predict_yield_and_risk

router = APIRouter(prefix="/predict", tags=["Prediction"])


@router.post("/yield", response_model=YieldPredictionResponse)
async def predict_yield(req: YieldPredictionRequest, lat: float, lon: float):
    """
    ML-Powered Harvest Yield & Climate Risk Prediction.
    Pulls the live forecast for the field's location, aggregates it into
    season-level features, and runs it through the trained model.
    """
    try:
        weather = await get_weekly_forecast(req.municipality, lat, lon)
    except Exception as exc:
        raise HTTPException(status_code=502, detail=f"Weather provider error: {exc}")

    if not weather.daily_forecast:
        raise HTTPException(status_code=502, detail="No forecast data available.")

    avg_temp = sum(d.temperature_c for d in weather.daily_forecast) / len(weather.daily_forecast)
    avg_humidity = sum(d.humidity_pct for d in weather.daily_forecast) / len(weather.daily_forecast)
    total_rainfall = sum(d.rain_probability_pct * 3 for d in weather.daily_forecast)  # rough proxy
    max_wind = max(d.wind_speed_kph for d in weather.daily_forecast)

    return predict_yield_and_risk(
        req,
        avg_temp_c=avg_temp,
        avg_humidity_pct=avg_humidity,
        total_rainfall_mm=total_rainfall,
        max_wind_kph=max_wind,
    )
