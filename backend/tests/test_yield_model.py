import sys
from pathlib import Path

# Add backend directory to sys.path so 'app' imports work from anywhere
BACKEND_DIR = Path(__file__).resolve().parent.parent
if str(BACKEND_DIR) not in sys.path:
    sys.path.insert(0, str(BACKEND_DIR))

import unittest
from unittest.mock import AsyncMock, patch

import pandas as pd

from app.ml.geography import nearest_region, normalize_psa_region
from app.ml.predict import predict_yield_and_risk
from app.routers.prediction import predict_yield
from app.ml.train_model import build_training_data
from app.schemas.weather import DailyForecast, WeatherResponse
from app.schemas.yield_prediction import YieldPredictionRequest


class _FixedPipeline:
    def __init__(self) -> None:
        self.features = None

    def predict(self, features: pd.DataFrame) -> list[float]:
        self.features = features
        return [4.25]


class YieldModelTests(unittest.TestCase):
    def test_build_training_data_splits_irrigated_and_rainfed(self) -> None:
        """Irrigated and Rainfed are kept as separate rows, not summed."""
        production = pd.DataFrame(
            [
                {
                    "Ecosystem/Croptype": "Irrigated Palay",
                    "Geolocation": "..REGION I (ILOCOS REGION)",
                    "2021 Quarter 1": 100,
                },
                {
                    "Ecosystem/Croptype": "Rainfed Palay",
                    "Geolocation": "..REGION I (ILOCOS REGION)",
                    "2021 Quarter 1": 50,
                },
                {
                    "Ecosystem/Croptype": "Irrigated Palay",
                    "Geolocation": "....Abra",
                    "2021 Quarter 1": 900,
                },
            ]
        )
        area = pd.DataFrame(
            [
                {
                    "Ecosystem/Croptype": "Irrigated Palay",
                    "Geolocation": "..REGION I (ILOCOS REGION)",
                    "2021 Quarter 1": 20,
                },
                {
                    "Ecosystem/Croptype": "Rainfed Palay",
                    "Geolocation": "..REGION I (ILOCOS REGION)",
                    "2021 Quarter 1": 10,
                },
                {
                    "Ecosystem/Croptype": "Irrigated Palay",
                    "Geolocation": "....Abra",
                    "2021 Quarter 1": 1,
                },
            ]
        )

        dataset = build_training_data(production, area)

        # Province-level rows are excluded; 2 regional rows remain (one per ecosystem)
        self.assertEqual(len(dataset), 2)
        self.assertTrue((dataset["region"] == "REGION I (ILOCOS REGION)").all())
        irr = dataset.loc[dataset["ecosystem_type"] == "Irrigated Palay"]
        raf = dataset.loc[dataset["ecosystem_type"] == "Rainfed Palay"]
        self.assertAlmostEqual(irr["yield_tons_per_hectare"].iloc[0], 5.0)  # 100/20
        self.assertAlmostEqual(raf["yield_tons_per_hectare"].iloc[0], 5.0)  # 50/10

    def test_psa_labels_and_coordinates_resolve_to_supported_region(self) -> None:
        self.assertEqual(
            normalize_psa_region(
                "..BANGSAMORO AUTONOMOUS REGION IN MUSLIM MINDANAO (BARMM)d/"
            ),
            "BANGSAMORO AUTONOMOUS REGION IN MUSLIM MINDANAO (BARMM)",
        )
        self.assertIsNone(normalize_psa_region("....Abra"))
        self.assertEqual(
            nearest_region(16.41639, 120.59306),
            "CORDILLERA ADMINISTRATIVE REGION (CAR)",
        )

    def test_prediction_uses_harvest_quarter_and_returns_field_total(self) -> None:
        request = YieldPredictionRequest(
            seed_variety="Test",
            days_to_maturity=120,
            field_size_hectares=2.0,
            start_date="2026-01-01",
            soil_type=None,
            municipality="Baguio",
            ecosystem_type="irrigated",
        )
        pipeline = _FixedPipeline()
        artifact = {
            "yield_pipeline": pipeline,
            "irrigated_fraction_by_region": {},
        }

        with patch("app.ml.predict._load_model", return_value=artifact):
            result = predict_yield_and_risk(
                request,
                latitude=16.41639,
                longitude=120.59306,
                max_rain_probability_pct=85,
                max_wind_kph=10,
            )

        self.assertEqual(pipeline.features.loc[0, "region"], "CORDILLERA ADMINISTRATIVE REGION (CAR)")
        self.assertEqual(pipeline.features.loc[0, "ecosystem_type"], "Irrigated Palay")
        self.assertEqual(pipeline.features.loc[0, "harvest_quarter"], "2")
        self.assertEqual(pipeline.features.loc[0, "harvest_year"], 2026)
        self.assertEqual(result.predicted_yield_tons, 8.5)
        self.assertEqual(result.predicted_yield_cavans, 170.0)
        self.assertEqual(result.climate_risk_level, "high")
        self.assertIn("experimental regional baseline", result.prediction_note)
        self.assertIn("CORDILLERA", result.prediction_note)


class YieldRouteTests(unittest.IsolatedAsyncioTestCase):
    async def test_route_returns_heuristic_when_no_model_installed(self) -> None:
        """Without a trained artifact the route falls back to the heuristic."""
        request = YieldPredictionRequest(
            seed_variety="Test",
            days_to_maturity=120,
            field_size_hectares=1.5,
            start_date="2026-01-01",
            soil_type=None,
            municipality="Baguio",
        )
        forecast = WeatherResponse(
            municipality="Baguio",
            latitude=16.41639,
            longitude=120.59306,
            daily_forecast=[
                DailyForecast(
                    forecast_date="2026-01-01",
                    rain_probability_pct=65,
                    temperature_c=28,
                    humidity_pct=75,
                    wind_speed_kph=20,
                )
            ],
        )
        with (
            patch(
                "app.routers.prediction.get_weekly_forecast",
                new_callable=AsyncMock,
                return_value=forecast,
            ),
            patch("app.ml.predict._load_model", return_value=None),
        ):
            result = await predict_yield(request, 16.41639, 120.59306)

        self.assertGreater(result.predicted_yield_tons, 0)
        self.assertEqual(result.climate_risk_level, "medium")
        self.assertIn("heuristic", result.prediction_note)


if __name__ == "__main__":
    unittest.main()
