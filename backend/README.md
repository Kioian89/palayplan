# PalayPlan Backend (FastAPI)

## Setup
```bash
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env            # fill in API keys and database settings
```

For local development without MySQL, set in `.env`:
```
DATABASE_URL=sqlite:///./palayplan.db
```

## Firebase

The Flutter app uses Firebase Email/Password or Google Authentication directly.
Signed-in field profiles are stored in Cloud Firestore under the authenticated
Firebase UID. The backend continues to provide weather, advisory, and yield
prediction APIs.

`GET /auth/me` remains available for clients that need server-side Firebase
ID-token verification. For that endpoint, set `FIREBASE_CREDENTIALS_PATH` to a
Firebase Admin service-account JSON file on the server. Keep that file out of
source control and never put it in the Flutter app.

The database-backed `/auth/register` and `/auth/login` endpoints remain
available for compatibility; the Flutter app does not use them.

## Run
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
Interactive API docs: http://localhost:8000/docs

## Deploy to Render

The repository includes a Render Blueprint in `../render.yaml`. In Render,
create a new Blueprint Instance from this repository and follow the prompts.
The Blueprint creates the API service; it does not create a database.

Before deploying, create a PostgreSQL database (Render or another provider) and
provide its connection URL as `DATABASE_URL` when prompted. Keep the API and
database in the same region and use the database provider's internal connection
URL when available. The PostgreSQL URL should start with `postgresql://`.

The Blueprint generates `JWT_SECRET_KEY` and configures the service's `/health`
check. If using `GET /auth/me`, add the Firebase service-account JSON as a
secret file in the Render service and set `FIREBASE_CREDENTIALS_PATH` to its
mounted path. Optionally add `OPENWEATHER_API_KEY`; weather otherwise falls
back to Open-Meteo.

After deployment, verify `https://<service-name>.onrender.com/health`, then
build the mobile app with the service URL:

```bash
cd mobile
flutter build apk --release \
  --dart-define=API_BASE_URL=https://<service-name>.onrender.com
```

The free web-service plan may sleep when idle, so the first request after a
period of inactivity can take longer. Choose a paid plan if the API needs to
stay continuously available.

## Train the ML model
```bash
python -m app.ml.train_model
```
The trainer downloads quarterly irrigated and rainfed palay production and
harvested-area tables from PSA OpenSTAT, combines them into regional yield per
hectare, validates on held-out years, and writes
`app/ml/model_artifact/yield_model.joblib`. The model uses region, harvest
quarter, and year; its output is a regional historical baseline, not a
field-level yield forecast. Climate risk remains a 7-day forecast heuristic:
PSA does not provide labeled field-level climate-risk outcomes. The app
discloses these limitations with its prediction.

Sources: [PSA palay production table](https://openstat.psa.gov.ph/PXWeb/api/v1/en/DB/2E/CS/0012E4EVCP0.px)
and [PSA harvested-area table](https://openstat.psa.gov.ph/PXWeb/api/v1/en/DB/2E/CS/0022E4EAHC0.px).

## Endpoints
| Method | Path                | Purpose |
|--------|---------------------|---------|
| POST   | /auth/register      | Legacy farmer account creation |
| POST   | /auth/login         | Legacy JWT token issuance |
| GET    | /auth/me            | Optional Firebase ID-token verification |
| GET    | /weather/forecast   | 7-day hyper-local forecast |
| GET    | /advisory/          | Smart alerts for current crop stage |
| POST   | /predict/yield      | ML yield estimate + climate risk |
| GET    | /health             | Liveness check |
