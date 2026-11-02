# PalayPlan — Roadmap & Feature Changelog

> **Stack:** Flutter (mobile) + FastAPI (backend) + TFLite (on-device AI)  
> **Target:** Philippine smallholder rice farmers — Wet & Dry Season management

---

## ✅ Shipped Features

### Core App (v1.0)
- **On-Device Disease Scanner** — TFLite model classifies 10 rice leaf conditions with 95.8% accuracy
- **Trilingual Support** — Full English / Filipino (Tagalog) / Bisaya (Cebuano) via `AppStrings`
- **Field Profile** — Variety, planting date, area, and GPS/map-pin location
- **5-Screen Navigation** — Home, Weather, Scanner, Calendar, Advisories
- **Firebase Auth** — Google Sign-In + guest (offline) mode
- **Offline Caching** — All API responses cached for offline use via `ApiCache`

### AI & Recommendations (v1.1)
- **PhilRice PalayCheck Smart Recommendation Engine**
  - 4-phase decision logic: Seedbed → Vegetative → Reproductive → Ripening
  - Weather-aware: delays fertilizer recommendation when rain risk ≥ 50%
  - 3-tab UI: Nutrient & Fertilizer | AWD Water | Pest & Disease Scouting
  - Rain delay badge shown on fertilizer tab when risk is high
  - Trilingual recommendations via `AppLanguage` parameter
- **Enhanced Advisory Engine (Backend)**
  - 6 agronomic rules (up from 4): fungal blast risk, wash-off prevention,
    harvest window, lodging alert, AWD tip, terminal drainage
  - Cross-references crop growth stage + 7-day weather forecast

### Weather (v1.1)
- **Zoom Earth Live Satellite & Radar** — Live satellite imagery, Doppler precipitation radar, and typhoon wind tracking centered on farmer field coordinates
- **Open-Meteo Fallback** — Free weather API used automatically when OpenWeatherMap key is missing or fails
- **Weather Descriptions** — Human-readable conditions (Sunny, Partly Cloudy, Heavy Rain, etc.) on Today hero card and all 7-day forecast cards
- **Field Risk Classification** — Traffic-light (low/medium/high) badge per day

### Yield Estimation (v1.1)
- **Yield Estimator Screen** — Full UI to submit field profile and get estimated cavans/ha
  - Breakdown: total cavans, metric tons, cavans per hectare
  - Climate risk level badge (low/medium/high) with risk factors list
  - Numbered yield improvement tips
  - Model confidence progress bar
  - Heuristic model (90 cav/ha baseline × field area × weather modifiers)
- **Backend `/predict/yield` endpoint** — ML or heuristic model with weather integration

### Rice Farm Photography (v1.0)
- 5 authentic Philippine rice farm photos from Unsplash integrated as feature card headers and hero banners
- Custom PalayPlan logo replacing Flutter default

### Backend Resiliency (v1.1)
- SQLite `check_same_thread=False` for local development
- Emulator loopback (`10.0.2.2`) as default API base URL
- `.env.example` documenting all configuration variables

---

## 🚧 In Progress / Planned

### Near-term (v1.2)
- [ ] **Scan History** — Save and review past leaf disease scans with timestamps
- [ ] **Push Notifications** — Advisory alerts triggered by backend weather events
- [ ] **PWA / Web Build** — Flutter Web support for desktop farmers
- [ ] **Yield History Chart** — Season-over-season yield trend visualization

### Medium-term (v1.3)
- [ ] **Pest Scouting Log** — Manual entry for observed pests with count thresholds
- [ ] **Market Price Widget** — Live NFA palay buying prices per municipality
- [ ] **SMS Advisory Fallback** — Send advisories via SMS when no internet (Twilio or Semaphore PH)
- [ ] **Multi-field Support** — Manage multiple paddies per farmer account

### Long-term (v2.0)
- [ ] **Satellite NDVI Integration** — Field health from Sentinel-2 NDVI index
- [ ] **Cooperative Mode** — Shared advisories for barangay-level farming clusters
- [ ] **DA / PhilRice API Integration** — Live certified seed prices and location-specific advisories
- [ ] **Offline TFLite Disease Model Updates** — OTA model refresh without app store release

---

## 🧪 Test Coverage

| Test File | Tests | Status |
|-----------|-------|--------|
| `recommendation_service_test.dart` | 4 | ✅ All pass |
| `full_app_test.dart` | 7 | ✅ All pass |
| `disease_classifier_test.dart` | 1 | ✅ All pass |
| `field_profile_test.dart` | 4 | ✅ All pass |
| `language_switching_test.dart` | 4 | ✅ All pass |
| `settings_privacy_test.dart` | 3 | ✅ All pass |
| `widget_test.dart` | 1 | ✅ All pass |
| `yield_screen_test.dart` | 1 | ✅ All pass |
| `zoom_earth_test.dart` | 2 | ✅ All pass |
| **Total** | **32** | ✅ **All pass** |

---

## 🏗️ Architecture

```
palayplan/
├── mobile/                   # Flutter app
│   ├── lib/
│   │   ├── l10n/             # AppStrings — EN/FIL/CEB
│   │   ├── models/           # WeatherForecast, Advisory, FieldProfile
│   │   ├── providers/        # FieldProvider, LanguageProvider
│   │   ├── screens/          # 6 screens incl. YieldScreen
│   │   ├── services/         # ApiService, RecommendationService, DiseaseClassifier
│   │   └── widgets/          # SmartRecommendationCard, CropArcGauge, etc.
│   ├── assets/
│   │   ├── images/           # Rice farm photos (Unsplash)
│   │   ├── icons/            # App logo
│   │   └── models/           # TFLite disease model
│   └── test/                 # 29 tests
│
└── backend/                  # FastAPI
    ├── app/
    │   ├── routers/          # /weather, /advisory, /predict, /auth
    │   ├── services/         # WeatherService (OWM + Open-Meteo), AdvisoryEngine
    │   ├── ml/               # predict.py — heuristic or ML yield model
    │   └── schemas/          # Pydantic models
    ├── .env.example          # Config template for all environment variables
    └── requirements.txt
```

---

*Last updated: November 2026 — PalayPlan v1.1*
