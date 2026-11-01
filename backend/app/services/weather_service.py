"""
Wraps the OpenWeatherMap One Call API to fetch a 7-day forecast for a given
lat/lon, and normalizes the payload into our DailyForecast schema.
"""
import httpx
from datetime import date, timedelta

from app.config import settings
from app.schemas.weather import DailyForecast, WeatherResponse


async def get_weekly_forecast(municipality: str, lat: float, lon: float) -> WeatherResponse:
    params = {
        "lat": lat,
        "lon": lon,
        "appid": settings.openweather_api_key,
        "units": "metric",
        "exclude": "current,minutely,hourly,alerts",
    }
    url = f"{settings.openweather_base_url}/onecall"

    async with httpx.AsyncClient(timeout=10.0) as client:
        resp = await client.get(url, params=params)
        resp.raise_for_status()
        data = resp.json()

    daily = []
    for i, day in enumerate(data.get("daily", [])[:7]):
        daily.append(
            DailyForecast(
                forecast_date=date.today() + timedelta(days=i),
                rain_probability_pct=round(day.get("pop", 0) * 100, 1),
                temperature_c=day["temp"]["day"],
                humidity_pct=day["humidity"],
                wind_speed_kph=round(day["wind_speed"] * 3.6, 1),
            )
        )

    return WeatherResponse(
        municipality=municipality,
        latitude=lat,
        longitude=lon,
        daily_forecast=daily,
    )
