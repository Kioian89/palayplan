"""
Contextual Agro-Advisory engine.

This is the layer that makes PalayPlan more than "just a weather app": it
cross-references the farmer's current crop growth STAGE (derived from
start_date + days_to_maturity) against the incoming weather forecast, and
emits actionable advisories.

Growth stages (simplified 4-phase model used across the calendar + advisories):
  1. Land Prep / Sowing      -> days 0-10
  2. Vegetative (Transplant) -> days 11-45
  3. Reproductive (Fertilization / Flowering) -> days 46-75
  4. Ripening / Harvest      -> days 76-maturity
"""
from datetime import date, timedelta
from app.schemas.weather import WeatherResponse
from app.schemas.yield_prediction import AdvisoryItem


def get_growth_stage(days_since_start: int, days_to_maturity: int) -> str:
    if days_since_start <= 10:
        return "Land Preparation / Sowing"
    if days_since_start <= 45:
        return "Vegetative / Transplanting"
    if days_since_start <= days_to_maturity - 20:
        return "Reproductive / Fertilization"
    return "Ripening / Harvest"


def generate_advisories(
    start_date: date,
    days_to_maturity: int,
    weather: WeatherResponse,
) -> list[AdvisoryItem]:
    advisories: list[AdvisoryItem] = []

    for day in weather.daily_forecast:
        days_since_start = (day.forecast_date - start_date).days
        if days_since_start < 0:
            continue

        stage = get_growth_stage(days_since_start, days_to_maturity)

        # --- Rule 1: heavy rain during fertilization -> wash-off risk ---
        if stage == "Reproductive / Fertilization" and day.rain_probability_pct >= 60:
            advisories.append(AdvisoryItem(
                stage=stage,
                date=day.forecast_date,
                message="High rain probability during fertilization window. "
                        "Hold off on applying fertilizer/pesticide to avoid wash-off.",
                severity="warning",
            ))

        # --- Rule 2: high humidity -> pest/fungal disease risk ---
        if day.humidity_pct >= 85:
            advisories.append(AdvisoryItem(
                stage=stage,
                date=day.forecast_date,
                message="Sustained high humidity increases risk of rice blast "
                        "and other fungal diseases. Inspect fields closely.",
                severity="warning",
            ))

        # --- Rule 3: dry window during ripening -> good harvest/drying day ---
        if stage == "Ripening / Harvest" and day.rain_probability_pct <= 20:
            advisories.append(AdvisoryItem(
                stage=stage,
                date=day.forecast_date,
                message="Low rain probability — good window for harvesting "
                        "and open-air palay drying.",
                severity="info",
            ))

        # --- Rule 4: strong wind -> lodging risk near maturity ---
        if stage == "Ripening / Harvest" and day.wind_speed_kph >= 40:
            advisories.append(AdvisoryItem(
                stage=stage,
                date=day.forecast_date,
                message="Strong winds forecast near maturity — risk of stalk "
                        "lodging. Consider early harvest if grain is ready.",
                severity="critical",
            ))

    return advisories
