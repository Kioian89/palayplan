"""
Trains a Random Forest regressor to estimate rice yield (in cavans/hectare)
and a classifier to bucket climate risk into low/medium/high.

Run standalone once you have real historical data:
    python -m app.ml.train_model --data path/to/historical_yield.csv

Expected CSV columns (rename to match your actual dataset):
    seed_variety, days_to_maturity, field_size_hectares, soil_type,
    avg_temp_c, avg_humidity_pct, total_rainfall_mm, max_wind_kph,
    actual_yield_cavans, climate_risk_level

NOTE: This is a scaffold with synthetic data generation so the pipeline is
runnable end-to-end before real agricultural data is collected. Replace
`load_or_generate_data()` with a real CSV loader as soon as data exists.
"""
import argparse
import joblib
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestRegressor, RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline

NUMERIC_FEATURES = [
    "days_to_maturity", "field_size_hectares",
    "avg_temp_c", "avg_humidity_pct", "total_rainfall_mm", "max_wind_kph",
]
CATEGORICAL_FEATURES = ["soil_type"]


def load_or_generate_data(path: str | None, n_samples: int = 500) -> pd.DataFrame:
    if path:
        return pd.read_csv(path)

    rng = np.random.default_rng(42)
    df = pd.DataFrame({
        "days_to_maturity": rng.choice([105, 110, 115, 120, 125], n_samples),
        "field_size_hectares": rng.uniform(0.5, 5.0, n_samples),
        "soil_type": rng.choice(["clay", "loam", "sandy"], n_samples),
        "avg_temp_c": rng.normal(28, 2, n_samples),
        "avg_humidity_pct": rng.normal(75, 10, n_samples),
        "total_rainfall_mm": rng.gamma(2, 100, n_samples),
        "max_wind_kph": rng.gamma(2, 10, n_samples),
    })
    # Synthetic yield: base + small effects, for pipeline demonstration only
    df["actual_yield_cavans"] = (
        90 * df["field_size_hectares"]
        + 0.5 * df["days_to_maturity"]
        - 0.3 * (df["total_rainfall_mm"] - 200).clip(lower=0)
        + rng.normal(0, 10, n_samples)
    ).clip(lower=0)

    df["climate_risk_level"] = pd.cut(
        df["total_rainfall_mm"] + df["max_wind_kph"] * 2,
        bins=[-np.inf, 200, 350, np.inf],
        labels=["low", "medium", "high"],
    )
    return df


def build_preprocessor() -> ColumnTransformer:
    return ColumnTransformer([
        ("cat", OneHotEncoder(handle_unknown="ignore"), CATEGORICAL_FEATURES),
    ], remainder="passthrough")


def train(data_path: str | None, output_path: str):
    df = load_or_generate_data(data_path)
    X = df[NUMERIC_FEATURES + CATEGORICAL_FEATURES]
    y_yield = df["actual_yield_cavans"]
    y_risk = df["climate_risk_level"]

    X_train, X_test, y_yield_train, y_yield_test, y_risk_train, y_risk_test = train_test_split(
        X, y_yield, y_risk, test_size=0.2, random_state=42
    )

    yield_pipeline = Pipeline([
        ("preprocess", build_preprocessor()),
        ("model", RandomForestRegressor(n_estimators=200, random_state=42)),
    ])
    risk_pipeline = Pipeline([
        ("preprocess", build_preprocessor()),
        ("model", RandomForestClassifier(n_estimators=200, random_state=42)),
    ])

    yield_pipeline.fit(X_train, y_yield_train)
    risk_pipeline.fit(X_train, y_risk_train)

    print(f"Yield model R^2 on test set: {yield_pipeline.score(X_test, y_yield_test):.3f}")
    print(f"Risk model accuracy on test set: {risk_pipeline.score(X_test, y_risk_test):.3f}")

    joblib.dump({"yield_pipeline": yield_pipeline, "risk_pipeline": risk_pipeline}, output_path)
    print(f"Saved model artifact to {output_path}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--data", default=None, help="Path to historical yield CSV")
    parser.add_argument("--out", default="app/ml/model_artifact/yield_model.joblib")
    args = parser.parse_args()
    train(args.data, args.out)
