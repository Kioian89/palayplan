"""
Loads the trained model artifact and exposes a predict() function used by
the /predict API route. Falls back to a simple heuristic if no trained
artifact exists yet, so the API stays functional during early development.
"""
import os
from datetime import timedelta

import joblib
import pandas as pd

from app.config import settings
from app.ml.geography import nearest_region
from app.schemas.yield_prediction import YieldPredictionRequest, YieldPredictionResponse

_CAVAN_TO_TON = 0.05  # 1 cavan (50kg bag) = 0.05 metric tons

_model_cache: dict | None = None


def _load_model() -> dict | None:
    global _model_cache
    if _model_cache is None and os.path.exists(settings.model_artifact_path):
        artifact = joblib.load(settings.model_artifact_path)
        if artifact.get("model_version") != 3 or "yield_pipeline" not in artifact:
            raise ValueError(
                f"Unsupported yield model artifact at {settings.model_artifact_path}"
            )
        _model_cache = artifact
    return _model_cache


def _heuristic_predict(req: YieldPredictionRequest) -> YieldPredictionResponse:
    """Fallback used when the PSA-trained model artifact is not installed."""
    base_yield = 90 * req.field_size_hectares
    return YieldPredictionResponse(
        predicted_yield_cavans=round(base_yield, 1),
        predicted_yield_tons=round(base_yield * _CAVAN_TO_TON, 2),
        climate_risk_level="medium" if req.days_to_maturity >= 120 else "low",
        risk_factors=["Climate-risk category is a heuristic, not a trained classifier."],
        prediction_note="Yield fallback is a heuristic; the PSA-trained model is not installed.",
    )


def predict_yield_and_risk(
    req: YieldPredictionRequest,
    latitude: float,
    longitude: float,
    max_rain_probability_pct: float,
    max_wind_kph: float,
) -> YieldPredictionResponse:
    model = _load_model()
    if model is None:
        yield_per_hectare_tons = None
        region = None
    else:
        harvest_date = req.start_date + timedelta(days=req.days_to_maturity)
        region = nearest_region(latitude, longitude)
        harvest_quarter = str((harvest_date.month - 1) // 3 + 1)
        harvest_year = harvest_date.year

        # Resolve ecosystem type: use the farmer's input if provided, otherwise
        # blend irrigated and rainfed predictions weighted by the regional average.
        _PSA_ECOSYSTEM = {
            "irrigated": "Irrigated Palay",
            "rainfed": "Rainfed Palay",
        }
        eco = req.ecosystem_type
        if eco is not None:
            features = pd.DataFrame([{
                "region": region,
                "ecosystem_type": _PSA_ECOSYSTEM[eco],
                "harvest_quarter": harvest_quarter,
                "harvest_year": harvest_year,
            }])
            yield_per_hectare_tons = max(
                0.0, float(model["yield_pipeline"].predict(features)[0])
            )
        else:
            # Weighted blend using historical irrigated fraction for this region
            irr_frac = model.get("irrigated_fraction_by_region", {}).get(region, 0.65)
            features_irr = pd.DataFrame([{
                "region": region,
                "ecosystem_type": "Irrigated Palay",
                "harvest_quarter": harvest_quarter,
                "harvest_year": harvest_year,
            }])
            features_raf = pd.DataFrame([{
                "region": region,
                "ecosystem_type": "Rainfed Palay",
                "harvest_quarter": harvest_quarter,
                "harvest_year": harvest_year,
            }])
            yield_irr = max(0.0, float(model["yield_pipeline"].predict(features_irr)[0]))
            yield_raf = max(0.0, float(model["yield_pipeline"].predict(features_raf)[0]))
            yield_per_hectare_tons = irr_frac * yield_irr + (1 - irr_frac) * yield_raf

    risk_factors = []
    if max_rain_probability_pct >= 60:
        risk_factors.append(
            f"Rain probability reaches {max_rain_probability_pct:.0f}% in the 7-day forecast."
        )
    if max_wind_kph > 35:
        risk_factors.append(
            f"Forecast wind reaches {max_wind_kph:.0f} km/h; monitor for lodging risk."
        )
    if not risk_factors:
        risk_factors.append("No 7-day forecast thresholds were triggered.")

    climate_risk = "low"
    if max_rain_probability_pct >= 80 or max_wind_kph >= 50:
        climate_risk = "high"
    elif max_rain_probability_pct >= 60 or max_wind_kph > 35:
        climate_risk = "medium"

    if yield_per_hectare_tons is None:
        return _heuristic_predict(req).model_copy(
            update={
                "climate_risk_level": climate_risk,
                "risk_factors": risk_factors,
            }
        )

    predicted_yield_tons = yield_per_hectare_tons * req.field_size_hectares
    predicted_yield_cavans = predicted_yield_tons / _CAVAN_TO_TON
    eco_label = (
        req.ecosystem_type.capitalize() if req.ecosystem_type
        else "irrigated/rainfed blend"
    )
    return YieldPredictionResponse(
        predicted_yield_cavans=round(predicted_yield_cavans, 1),
        predicted_yield_tons=round(predicted_yield_tons, 2),
        climate_risk_level=climate_risk,
        risk_factors=risk_factors,
        prediction_note=(
            f"Nearest PSA region: {region} ({eco_label}). Yield is an experimental "
            "regional baseline (1987-2025), not a field-level estimate. "
            "Climate risk is a heuristic based on the 7-day forecast."
        ),
    )
