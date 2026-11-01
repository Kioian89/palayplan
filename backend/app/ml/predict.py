"""
Loads the trained model artifact and exposes a predict() function used by
the /predict API route. Falls back to a simple heuristic if no trained
artifact exists yet, so the API stays functional during early development.
"""
import os
import joblib
import pandas as pd

from app.config import settings
from app.schemas.yield_prediction import YieldPredictionRequest, YieldPredictionResponse

_CAVAN_TO_TON = 0.05  # 1 cavan (50kg bag) = 0.05 metric tons

_model_cache = None


def _load_model():
    global _model_cache
    if _model_cache is None and os.path.exists(settings.model_artifact_path):
        _model_cache = joblib.load(settings.model_artifact_path)
    return _model_cache


def _heuristic_predict(req: YieldPredictionRequest) -> YieldPredictionResponse:
    """Simple fallback used before a trained model artifact exists."""
    base_yield = 90 * req.field_size_hectares
    risk = "low"
    if req.days_to_maturity >= 120:
        risk = "medium"
    return YieldPredictionResponse(
        predicted_yield_cavans=round(base_yield, 1),
        predicted_yield_tons=round(base_yield * _CAVAN_TO_TON, 2),
        climate_risk_level=risk,
        risk_factors=["Heuristic estimate — trained model not yet deployed."],
    )


def predict_yield_and_risk(
    req: YieldPredictionRequest,
    avg_temp_c: float,
    avg_humidity_pct: float,
    total_rainfall_mm: float,
    max_wind_kph: float,
) -> YieldPredictionResponse:
    model = _load_model()
    if model is None:
        return _heuristic_predict(req)

    features = pd.DataFrame([{
        "days_to_maturity": req.days_to_maturity,
        "field_size_hectares": req.field_size_hectares,
        "soil_type": req.soil_type or "loam",
        "avg_temp_c": avg_temp_c,
        "avg_humidity_pct": avg_humidity_pct,
        "total_rainfall_mm": total_rainfall_mm,
        "max_wind_kph": max_wind_kph,
    }])

    predicted_yield = float(model["yield_pipeline"].predict(features)[0])
    predicted_risk = str(model["risk_pipeline"].predict(features)[0])

    risk_factors = []
    if total_rainfall_mm > 300:
        risk_factors.append("Above-average rainfall forecast for the season.")
    if max_wind_kph > 35:
        risk_factors.append("Elevated wind speeds increase lodging risk.")
    if not risk_factors:
        risk_factors.append("No major climate risk factors detected.")

    return YieldPredictionResponse(
        predicted_yield_cavans=round(predicted_yield, 1),
        predicted_yield_tons=round(predicted_yield * _CAVAN_TO_TON, 2),
        climate_risk_level=predicted_risk,
        risk_factors=risk_factors,
    )
