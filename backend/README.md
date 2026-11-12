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

## Deploy to Google Cloud Run

The API is containerized in `Dockerfile` and can be deployed from this directory.
Cloud Run is the compute target; Firebase Authentication remains the identity
provider. The existing SQLAlchemy models require a relational database, so keep
PostgreSQL rather than switching to Firestore. For an all-Google Cloud setup,
Cloud SQL for PostgreSQL is the recommended database; this requires no app data
model rewrite. Firestore would require a separate redesign of the database
models and queries.

1. Select a Google Cloud project, enable billing, and enable the Cloud Run,
   Cloud Build, Artifact Registry, and (if using Cloud SQL) Cloud SQL Admin APIs.
2. Create a PostgreSQL database. For Cloud SQL, grant the Cloud Run service
   account the `Cloud SQL Client` role and attach the instance to the service.
3. Store `DATABASE_URL` and `JWT_SECRET_KEY` in Secret Manager. The database URL
   should start with `postgresql://`. Optionally store `OPENWEATHER_API_KEY` as
   a secret; weather otherwise falls back to Open-Meteo. Grant the Cloud Run
   runtime service account `Secret Manager Secret Accessor` on each secret.
4. From the `backend` directory, deploy (replace the project, region, and secret
   names with yours):

   ```bash
   gcloud run deploy palayplan-api \
     --source . \
     --project YOUR_PROJECT_ID \
     --region asia-southeast1 \
     --allow-unauthenticated \
     --set-env-vars APP_ENV=production \
     --set-secrets DATABASE_URL=DATABASE_URL:latest,JWT_SECRET_KEY=JWT_SECRET_KEY:latest
   ```

   Add `--add-cloudsql-instances=PROJECT_ID:REGION:INSTANCE_ID` when using
   Cloud SQL. Configure the `DATABASE_URL` secret for the connection method you
   use. The deploying principal must be able to deploy Cloud Run services and
   access the referenced secrets.
5. To verify Firebase ID tokens, assign the Cloud Run runtime service account
   the Firebase Authentication permissions needed to look up users (including
   revoked-token checks). The backend uses Cloud Run Application Default
   Credentials automatically. For local development, set
   `FIREBASE_CREDENTIALS_PATH` to a service-account JSON file instead; never
   commit that file.
6. After deployment, get the service URL with
   `gcloud run services describe palayplan-api --region asia-southeast1 --format='value(status.url)'`
   and verify `<SERVICE_URL>/health`. Set the GitHub Actions repository
   variable `API_BASE_URL` to that service URL before running the mobile build
   workflow. The workflow fails validation if this variable is missing.

The Cloud Run service is public so the mobile client can call it; protect
account-specific routes with the existing Firebase ID-token verification.

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
