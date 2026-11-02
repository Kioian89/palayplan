"""
Contextual Agro-Advisory and Recommendation Engine (PhilRice PalayCheck System).

Cross-references the farmer's current crop growth stage (derived from
start_date + days_to_maturity) against the incoming 7-day weather forecast,
and emits actionable, high-impact agronomic advisories and management tips.

Growth Stages:
  1. Seedbed / Early Transplanting    -> days 0-14
  2. Vegetative / Active Tillering    -> days 15-45
  3. Reproductive / Panicle & Bloom   -> days 46 to (maturity - 20)
  4. Ripening / Harvest               -> days (maturity - 19) to maturity
"""
from datetime import date, timedelta
from app.schemas.weather import WeatherResponse
from app.schemas.yield_prediction import AdvisoryItem


def get_growth_stage(days_since_start: int, days_to_maturity: int) -> str:
    if days_since_start <= 14:
        return "Seedbed / Early Transplanting"
    if days_since_start <= 45:
        return "Vegetative / Active Tillering"
    if days_since_start <= days_to_maturity - 20:
        return "Reproductive / Panicle Initiation"
    return "Ripening / Harvest"


def generate_advisories(
    start_date: date,
    days_to_maturity: int,
    weather: WeatherResponse,
) -> list[AdvisoryItem]:
    advisories: list[AdvisoryItem] = []

    # Track stage-specific base advisories added to prevent duplicate generic items
    added_stage_advice = set()

    for day in weather.daily_forecast:
        days_since_start = (day.forecast_date - start_date).days
        if days_since_start < 0:
            continue

        stage = get_growth_stage(days_since_start, days_to_maturity)

        # --- Rule 1: High rain during vegetative/reproductive topdressing -> Wash-off risk ---
        if stage in ("Vegetative / Active Tillering", "Reproductive / Panicle Initiation") and day.rain_probability_pct >= 55:
            advisories.append(AdvisoryItem(
                stage=stage,
                date=day.forecast_date,
                message=(
                    f"Rain probability is {day.rain_probability_pct}%. "
                    "Delay fertilizer (Urea/Complete) or pesticide spraying by 24-48 hours to prevent chemical runoff and leaching."
                ),
                severity="warning",
            ))

        # --- Rule 2: High humidity + warm temperatures -> Fungal Disease Risk (Blast / Sheath Blight) ---
        if day.humidity_pct >= 82 and day.temperature_c >= 25:
            advisories.append(AdvisoryItem(
                stage=stage,
                date=day.forecast_date,
                message=(
                    f"High humidity ({day.humidity_pct}%) and warm weather favor fungal pathogens. "
                    "Inspect leaf collars for diamond-shaped Blast spots and lower sheaths for water-soaked lesions."
                ),
                severity="warning",
            ))

        # --- Rule 3: Dry & sunny window during ripening -> Ideal harvest & solar drying ---
        if stage == "Ripening / Harvest" and day.rain_probability_pct <= 25:
            advisories.append(AdvisoryItem(
                stage=stage,
                date=day.forecast_date,
                message=(
                    "Favorable sunny weather with low rain chance. "
                    "Optimal window for harvesting 85% golden panicles and outdoor concrete solar drying."
                ),
                severity="info",
            ))

        # --- Rule 4: Strong wind -> Lodging risk near maturity ---
        if stage == "Ripening / Harvest" and day.wind_speed_kph >= 35:
            advisories.append(AdvisoryItem(
                stage=stage,
                date=day.forecast_date,
                message=(
                    f"Elevated wind speeds ({day.wind_speed_kph} km/h) forecasted. "
                    "High risk of crop lodging. Drain excess field water to firm soil and brace heavy panicle stalks."
                ),
                severity="critical",
            ))

        # --- Rule 5: AWD Water Management in Vegetative Stage ---
        if stage == "Vegetative / Active Tillering" and stage not in added_stage_advice:
            added_stage_advice.add(stage)
            advisories.append(AdvisoryItem(
                stage=stage,
                date=day.forecast_date,
                message=(
                    "PalayCheck AWD Tip: Maintain shallow water (2-3 cm). "
                    "Allow water to naturally recede before reflooding to stimulate deep root anchoring and vigorous tillers."
                ),
                severity="info",
            ))

        # --- Rule 6: Terminal Drainage 7-10 Days before harvest ---
        if stage == "Ripening / Harvest" and days_since_start >= days_to_maturity - 10 and stage not in added_stage_advice:
            added_stage_advice.add(stage)
            advisories.append(AdvisoryItem(
                stage=stage,
                date=day.forecast_date,
                message=(
                    "Terminal Drainage Window: Cut off irrigation and drain field completely "
                    "7-10 days before harvest to hasten uniform grain drying and allow mechanical harvester mobility."
                ),
                severity="info",
            ))

    return advisories
