from datetime import date
from pydantic import BaseModel, Field


class DailyForecast(BaseModel):
    forecast_date: date
    rain_probability_pct: float = Field(..., ge=0, le=100)
    temperature_c: float
    humidity_pct: float = Field(..., ge=0, le=100)
    wind_speed_kph: float


class WeatherResponse(BaseModel):
    municipality: str
    latitude: float
    longitude: float
    daily_forecast: list[DailyForecast]
