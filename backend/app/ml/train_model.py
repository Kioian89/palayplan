"""Train a regional rice-yield baseline from PSA OpenSTAT data.

Run from the backend directory:
    python -m app.ml.train_model

The target is regional palay production divided by harvested area, not
farm-level yield. Climate-risk labels are not available in the source data.
"""
import argparse
import io
import re
from pathlib import Path

import httpx
import joblib
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import HistGradientBoostingRegressor
from sklearn.metrics import mean_absolute_error, mean_absolute_percentage_error, r2_score
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder

from app.ml.geography import REGION_CENTERS, normalize_psa_region

API_BASE = "https://openstat.psa.gov.ph/PXWeb/api/v1/en/DB/2E/CS"
PRODUCTION_TABLE = "0012E4EVCP0.px"
AREA_TABLE = "0022E4EAHC0.px"
SOURCE_CATEGORIES = ["0", "1"]  # Irrigated Palay and Rainfed Palay
SOURCE_PERIODS = ["0", "1", "3", "4"]  # Quarters 1-4
MAX_TRAINING_YEAR = 2025  # 2026 is incomplete during the current reporting year
VALIDATION_START_YEAR = 2022
FEATURES = ["region", "ecosystem_type", "harvest_quarter", "harvest_year"]
TARGET = "yield_tons_per_hectare"


def _download_table(table_id: str) -> pd.DataFrame:
    query = {
        "query": [
            {
                "code": "Ecosystem/Croptype",
                "selection": {"filter": "item", "values": SOURCE_CATEGORIES},
            },
            {"code": "Geolocation", "selection": {"filter": "all", "values": ["*"]}},
            {"code": "Year", "selection": {"filter": "all", "values": ["*"]}},
            {
                "code": "Period",
                "selection": {"filter": "item", "values": SOURCE_PERIODS},
            },
        ],
        "response": {"format": "csv"},
    }
    url = f"{API_BASE}/{table_id}"
    response = httpx.post(url, json=query, timeout=60.0)
    response.raise_for_status()
    if not response.text.strip():
        raise ValueError(f"PSA returned an empty dataset for {table_id}")
    return pd.read_csv(io.StringIO(response.text))


def fetch_psa_tables() -> tuple[pd.DataFrame, pd.DataFrame]:
    """Fetch quarterly production and harvested-area tables from PSA OpenSTAT."""
    return _download_table(PRODUCTION_TABLE), _download_table(AREA_TABLE)


def _quarter_columns(frame: pd.DataFrame) -> list[str]:
    columns = [
        column
        for column in frame.columns
        if re.fullmatch(r"\d{4} Quarter [1-4]", str(column))
    ]
    if not columns:
        raise ValueError("PSA table contains no quarterly observations")
    return columns


def _regional_long_table(frame: pd.DataFrame, value_name: str) -> pd.DataFrame:
    required = {"Ecosystem/Croptype", "Geolocation"}
    if not required.issubset(frame.columns):
        raise ValueError(f"PSA table is missing columns: {sorted(required - set(frame.columns))}")

    quarterly_columns = _quarter_columns(frame)
    selected = frame.loc[
        frame["Ecosystem/Croptype"].isin(["Irrigated Palay", "Rainfed Palay"]),
        ["Ecosystem/Croptype", "Geolocation", *quarterly_columns],
    ].copy()
    selected["region"] = selected["Geolocation"].map(normalize_psa_region)
    selected = selected.loc[selected["region"].notna()]
    if selected.empty:
        raise ValueError("PSA table contains no recognized regional observations")

    long = selected.melt(
        id_vars=["Ecosystem/Croptype", "region"],
        value_vars=quarterly_columns,
        var_name="period",
        value_name=value_name,
    )
    long[["harvest_year", "harvest_quarter"]] = long["period"].str.extract(
        r"^(\d{4}) Quarter ([1-4])$"
    )
    long["harvest_year"] = pd.to_numeric(long["harvest_year"], errors="coerce")
    long[value_name] = pd.to_numeric(long[value_name], errors="coerce")
    long = long.dropna(subset=["harvest_year", "harvest_quarter", value_name])
    # Keep ecosystem_type as a separate axis so irrigated/rainfed yields are
    # modelled independently rather than averaged together.
    return (
        long.rename(columns={"Ecosystem/Croptype": "ecosystem_type"})
        .groupby(
            ["ecosystem_type", "region", "harvest_year", "harvest_quarter"],
            as_index=False,
        )[value_name]
        .sum()
    )


def build_training_data(
    production_table: pd.DataFrame,
    area_table: pd.DataFrame,
) -> pd.DataFrame:
    """Join PSA regional quarterly production and area into yield per hectare.

    Returns one row per (ecosystem_type, region, harvest_year, harvest_quarter)
    so the model can learn separate yield levels for irrigated vs. rainfed.
    """
    production = _regional_long_table(production_table, "production_tons")
    area = _regional_long_table(area_table, "area_hectares")
    data = production.merge(
        area,
        on=["ecosystem_type", "region", "harvest_year", "harvest_quarter"],
        how="inner",
        validate="one_to_one",
    )
    data = data.loc[
        (data["production_tons"] > 0)
        & (data["area_hectares"] > 0)
        & (data["harvest_year"] <= MAX_TRAINING_YEAR)
    ].copy()
    data[TARGET] = data["production_tons"] / data["area_hectares"]
    data["harvest_year"] = data["harvest_year"].astype(int)
    data["harvest_quarter"] = data["harvest_quarter"].astype(str)
    data = data.loc[data["region"].isin(REGION_CENTERS)]
    if data.empty:
        raise ValueError("No matching regional production and area records were found")
    return data.sort_values(
        ["harvest_year", "region", "ecosystem_type", "harvest_quarter"]
    ).reset_index(drop=True)


def build_yield_pipeline() -> Pipeline:
    preprocessor = ColumnTransformer(
        [
            (
                "categorical",
                OneHotEncoder(handle_unknown="ignore", sparse_output=False),
                ["region", "ecosystem_type", "harvest_quarter"],
            ),
            ("year", "passthrough", ["harvest_year"]),
        ]
    )
    return Pipeline(
        [
            ("features", preprocessor),
            (
                "regressor",
                HistGradientBoostingRegressor(
                    max_iter=500,
                    max_leaf_nodes=20,
                    learning_rate=0.05,
                    min_samples_leaf=5,
                    random_state=42,
                ),
            ),
        ]
    )


def _validation_report(data: pd.DataFrame) -> dict[str, float]:
    training = data.loc[data["harvest_year"] < VALIDATION_START_YEAR]
    validation = data.loc[
        data["harvest_year"].between(VALIDATION_START_YEAR, MAX_TRAINING_YEAR)
    ]
    if training.empty or validation.empty:
        raise ValueError("Not enough historical data for a time-based validation split")

    pipeline = build_yield_pipeline()
    pipeline.fit(training[FEATURES], training[TARGET])
    predictions = pipeline.predict(validation[FEATURES])
    baseline_means = training.groupby(["region", "ecosystem_type", "harvest_quarter"])[TARGET].mean()
    fallback_means = training.groupby(["ecosystem_type", "harvest_quarter"])[TARGET].mean()
    baseline = [
        baseline_means.get(
            (row.region, row.ecosystem_type, row.harvest_quarter),
            fallback_means.get(
                (row.ecosystem_type, row.harvest_quarter),
                training[TARGET].mean(),
            ),
        )
        for row in validation[["region", "ecosystem_type", "harvest_quarter"]].itertuples(index=False)
    ]

    report = {
        "validation_start_year": float(VALIDATION_START_YEAR),
        "validation_end_year": float(validation["harvest_year"].max()),
        "validation_rows": float(len(validation)),
        "mae_tons_per_hectare": float(
            mean_absolute_error(validation[TARGET], predictions)
        ),
        "mape_pct": float(
            mean_absolute_percentage_error(validation[TARGET], predictions) * 100
        ),
        "r2": float(r2_score(validation[TARGET], predictions)),
        "baseline_mae_tons_per_hectare": float(
            mean_absolute_error(validation[TARGET], baseline)
        ),
    }
    if report["mae_tons_per_hectare"] >= report["baseline_mae_tons_per_hectare"]:
        raise ValueError(
            "The trained model did not beat the regional-quarter average baseline "
            "on held-out years; refusing to save it."
        )
    return report


def train(output_path: str) -> dict[str, object]:
    production_table, area_table = fetch_psa_tables()
    data = build_training_data(production_table, area_table)
    validation = _validation_report(data)

    # Compute irrigated fraction per region (averaged over training years).
    # Used at inference time when the farmer doesn't specify ecosystem_type.
    area_pivot = (
        data.groupby(["region", "ecosystem_type"])["area_hectares"]
        .mean()
        .unstack(fill_value=0.0)
    )
    irr_col = "Irrigated Palay"
    raf_col = "Rainfed Palay"
    total_area = area_pivot.get(irr_col, 0.0) + area_pivot.get(raf_col, 0.0)
    irrigated_fraction: dict[str, float] = (
        (area_pivot.get(irr_col, 0.0) / total_area.replace(0.0, 1.0))
        .round(4)
        .to_dict()
    )

    pipeline = build_yield_pipeline()
    pipeline.fit(data[FEATURES], data[TARGET])

    artifact = {
        "model_version": 3,
        "yield_pipeline": pipeline,
        "irrigated_fraction_by_region": irrigated_fraction,
        "validation": validation,
        "training": {
            "source": "PSA OpenSTAT quarterly palay production and harvested area",
            "production_table": PRODUCTION_TABLE,
            "area_table": AREA_TABLE,
            "years": [
                int(data["harvest_year"].min()),
                int(data["harvest_year"].max()),
            ],
            "rows": int(len(data)),
            "regions": sorted(data["region"].unique().tolist()),
            "ecosystems": sorted(data["ecosystem_type"].unique().tolist()),
            "target": "regional production metric tons / regional harvested hectares",
        },
    }
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    joblib.dump(artifact, destination)
    return artifact


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--out",
        default="app/ml/model_artifact/yield_model.joblib",
        help="Path to write the trained model artifact",
    )
    args = parser.parse_args()

    artifact = train(args.out)
    print(f"Training records: {artifact['training']['rows']} ({', '.join(artifact['training']['ecosystems'])})")
    print(
        "Time-based validation "
        f"({int(artifact['validation']['validation_start_year'])}-"
        f"{int(artifact['validation']['validation_end_year'])}): "
        f"MAE {artifact['validation']['mae_tons_per_hectare']:.3f} t/ha, "
        f"MAPE {artifact['validation']['mape_pct']:.1f}%, "
        f"R² {artifact['validation']['r2']:.3f}"
    )
    print(
        "Regional-quarter baseline MAE: "
        f"{artifact['validation']['baseline_mae_tons_per_hectare']:.3f} t/ha"
    )
    print(f"Saved model artifact to {args.out}")


if __name__ == "__main__":
    main()
