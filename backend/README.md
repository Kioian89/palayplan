# PalayPlan Backend (FastAPI)

## Setup
```bash
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env            # fill in OPENWEATHER_API_KEY, DATABASE_URL, JWT_SECRET_KEY
```

For local dev without MySQL, set in `.env`:
```
DATABASE_URL=sqlite:///./palayplan.db
```

## Run
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
Interactive API docs: http://localhost:8000/docs

## Train the ML model
```bash
python -m app.ml.train_model            # uses synthetic data by default
python -m app.ml.train_model --data data/historical_yield.csv
```
This writes `app/ml/model_artifact/yield_model.joblib`, which `predict.py`
loads automatically. Until this file exists, `/predict/yield` falls back to
a simple heuristic so the API stays usable during early development.

## Endpoints
| Method | Path                | Purpose |
|--------|---------------------|---------|
| POST   | /auth/register      | Create farmer account |
| POST   | /auth/login         | Get JWT access token |
| GET    | /weather/forecast   | 7-day hyper-local forecast |
| GET    | /advisory/          | Smart alerts for current crop stage |
| POST   | /predict/yield      | ML yield estimate + climate risk |
| GET    | /health             | Liveness check |
