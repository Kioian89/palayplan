"""
Wraps the OpenWeatherMap One Call API to fetch a 7-day forecast for a given
lat/lon, with an automatic fallback to Open-Meteo (free global agro-weather API)
when no OpenWeather API key is configured or when the service is unreachable.
"""
import logging
import httpx
from datetime import date, timedelta

from app.config import settings
from app.schemas.weather import DailyForecast, WeatherResponse

logger = logging.getLogger("palayplan.weather")


async def _get_open_meteo_forecast(municipality: str, lat: float, lon: float) -> WeatherResponse:
    """Free fallback provider with no API key requirement."""
    url = "https://api.open-meteo.com/v1/forecast"
    params = {
        "latitude": lat,
        "longitude": lon,
        "daily": "temperature_2m_max,relative_humidity_2m_mean,precipitation_probability_max,windspeed_10m_max",
        "timezone": "Asia/Manila",
    }
    async with httpx.AsyncClient(timeout=10.0) as client:
        resp = await client.get(url, params=params)
        resp.raise_for_status()
        data = resp.json()

    daily_data = data.get("daily", {})
    dates = daily_data.get("time", [])
    temps = daily_data.get("temperature_2m_max", [])
    humidities = daily_data.get("relative_humidity_2m_mean", [])
    pops = daily_data.get("precipitation_probability_max", [])
    winds = daily_data.get("windspeed_10m_max", [])

    daily = []
    for i in range(min(7, len(dates))):
        daily.append(
            DailyForecast(
                forecast_date=date.fromisoformat(dates[i]),
                rain_probability_pct=float(pops[i]) if pops and i < len(pops) and pops[i] is not None else 20.0,
                temperature_c=float(temps[i]) if temps and i < len(temps) and temps[i] is not None else 29.0,
                humidity_pct=int(humidities[i]) if humidities and i < len(humidities) and humidities[i] is not None else 75,
                wind_speed_kph=float(winds[i]) if winds and i < len(winds) and winds[i] is not None else 10.0,
            )
        )

    return WeatherResponse(
        municipality=municipality,
        latitude=lat,
        longitude=lon,
        daily_forecast=daily,
    )


async def get_weekly_forecast(municipality: str, lat: float, lon: float) -> WeatherResponse:
    # If OpenWeather API key is present, try OpenWeather first
    if settings.openweather_api_key and settings.openweather_api_key.strip():
        params = {
            "lat": lat,
            "lon": lon,
            "appid": settings.openweather_api_key.strip(),
            "units": "metric",
            "exclude": "current,minutely,hourly,alerts",
        }
        url = f"{settings.openweather_base_url}/onecall"
        try:
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
        except Exception as exc:
            logger.warning("OpenWeather request failed (%s), falling back to Open-Meteo", exc)

    # Fallback to Open-Meteo
    return await _get_open_meteo_forecast(municipality, lat, lon)
