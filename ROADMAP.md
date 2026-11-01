# PalayPlan — Development Roadmap

This scaffold gives you a working skeleton end-to-end (backend boots, mobile
app compiles against it, ML pipeline runs on synthetic data). The list below
is the order I'd tackle remaining work in, organized into phases you can
hand back to me one at a time as follow-up prompts.

## Phase 1 — Get the scaffold running locally
- [ ] Get an OpenWeatherMap API key (One Call API 3.0) and drop it into `backend/.env`
- [ ] `pip install -r backend/requirements.txt` and run `uvicorn app.main:app --reload`
- [ ] Hit `/health` and `/docs` to confirm the API is alive
- [ ] Install Flutter SDK, run `flutter pub get` in `mobile/`, then `flutter run`
      against an emulator (update `ApiService.baseUrl` if not using Android emulator)
- **Follow-up prompt:** *"Walk me through installing Flutter and running this on
  [Android/iOS/web]"* or *"I got this error when running X — help me fix it"*

## Phase 2 — Real data model & auth hardening
- [ ] Swap SQLite → MySQL (or Firebase, per the brief) and set up Alembic migrations
- [ ] Add `Depends(get_current_user)` guard using the JWT from `auth.py` to
      protect `/predict` and crop-log endpoints
- [ ] Build the CropLog CRUD endpoints (create/list/update a planting cycle)
      so the mobile calendar can save real user data instead of hardcoded values
- **Follow-up prompt:** *"Add authenticated CRUD endpoints for crop logs and
  wire the Flutter calendar screen to save/load them"*

## Phase 3 — Real ML model
- [ ] Source or collect historical yield data (PhilRice, PSA, or local agri-coop
      records) matching the CSV schema documented in `train_model.py`
- [ ] Retrain with real data, evaluate R²/accuracy, tune hyperparameters
- [ ] Version model artifacts (e.g. `yield_model_v1.joblib`) and add a
      `/predict/model-info` endpoint reporting which version is live
- **Follow-up prompt:** *"Here's a sample of our historical yield dataset —
  help me adapt train_model.py to it and evaluate model performance"*

## Phase 4 — Mobile polish & accessibility
- [ ] Wire farmer's real location (GPS or manual municipality picker) into
      `HomeScreen`/`WeatherScreen` instead of the hardcoded sample coordinates
- [ ] Add local language support (Tagalog/Cebuano) via `flutter_localizations`
      + `.arb` files
- [ ] Add offline caching (`shared_preferences` or `sqflite`) so the last
      forecast/advisories show even without signal — important for rural areas
- [ ] Push notifications for critical advisories (Firebase Cloud Messaging)
- **Follow-up prompt:** *"Add Tagalog and Cebuano localization to the Flutter
  app"* or *"Add offline caching so the dashboard works without internet"*

## Phase 5 — Deployment
- [ ] Containerize backend (Dockerfile + docker-compose with MySQL)
- [ ] Deploy API (Render/Railway/AWS) and point mobile app's `API_BASE_URL` at it
- [ ] Build signed Android APK/AAB (`flutter build appbundle`) for Play Store
      internal testing track
- **Follow-up prompt:** *"Write a Dockerfile and docker-compose.yml for the
  backend"* or *"Help me prep this for Play Store internal testing"*

## Open decisions worth settling early
1. **MySQL vs Firebase** — the brief lists both; MySQL is more capital-defense-friendly
   (clear ER diagrams, SQL you can demo), Firebase is faster to stand up and has
   built-in auth/offline sync. Pick one to avoid maintaining two data layers.
2. **Weather data granularity** — OpenWeatherMap's One Call API gives forecasts
   by lat/lon, not by named municipality; you'll want a small lookup table
   mapping municipalities to coordinates for the "select your municipality" UX.
3. **Rice variety/stage rules** — the 4-phase model in `advisory_engine.py` and
   `calendar_screen.dart` is a reasonable default but should be validated against
   actual PhilRice cropping calendars for the varieties you're targeting.
