# 🌾 PalayPlan

<p align="center">
  <img src="mobile/assets/icons/app_logo.png" alt="PalayPlan Logo" width="120" style="border-radius: 24px;" />
</p>

<p align="center">
  <strong>Smart Agro-Weather & Rice Yield Optimization Mobile Application</strong><br>
  <em>Powered by PhilRice PalayCheck System, On-Device AI Disease Detection, and Real-Time Satellite Radar</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/FastAPI-0.115-009688?logo=fastapi&logoColor=white" alt="FastAPI" />
  <img src="https://img.shields.io/badge/Python-3.10+-3776AB?logo=python&logoColor=white" alt="Python" />
  <img src="https://img.shields.io/badge/AI-TensorFlow%20Lite-FF6F00?logo=tensorflow&logoColor=white" alt="TFLite" />
  <img src="https://img.shields.io/badge/Tests-34%20Passing-brightgreen" alt="Tests" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-4CAF50" alt="Platform" />
  <img src="https://img.shields.io/badge/Language-English%20%7C%20Filipino%20%7C%20Bisaya-FF7E55" alt="Trilingual" />
</p>

---

## 📖 Overview

**PalayPlan** is a mobile agro-technology application designed specifically for Philippine rice farmers. It combines localized meteorological data, PhilRice PalayCheck agronomic science, on-device machine learning, and live satellite radar tracking to protect crop investments, prevent chemical runoff, detect leaf pathogens early, and maximize harvest yields.

The application is built **offline-first**, ensuring that smallholder farmers in rural provincial fields with intermittent cell reception can continue scanning crops, managing cropping schedules, and monitoring field recommendations without an active internet connection.

---

## ✨ Key Features

### 1. 🔍 On-Device AI Rice Leaf Disease Scanner
* **10 Rice Leaf Pathogen Classes**: Detects Bacterial Leaf Blight, Brown Spot, Leaf Blast, Neck Blast, Sheath Blight, Tungro Virus, Rice Hispa, Leaf Scald, Narrow Brown Spot, and Healthy Leaves.
* **100% Offline Inference**: Powered by an on-device TensorFlow Lite (`.tflite`) computer vision model running with 95.8% accuracy. No photo upload or internet connection required.
* **Agronomic Advice**: Actionable chemical, cultural, and biological treatments tailored for Philippine field conditions.

### 2. 🌾 PhilRice PalayCheck Agro-Decision Engine
* **4 Growth Stages**: Tailored recommendations for Seedbed / Nursery (Days 1–14), Active Vegetative (Days 15–45), Reproductive / Panicle Initiation (Days 46–90), and Ripening / Harvest (Days 91+).
* **Weather-Aware Rain Delay Alerts**: Automatically detects incoming rain probabilities ($\ge 50\%$) and alerts farmers to delay urea/complete topdressing and pesticide applications by 24–48 hours to prevent expensive chemical runoff.
* **3-Tab Management**: Nutrient & Fertilizer scheduling, Alternate Wetting & Drying (AWD) water conservation, and Pest & Disease scouting.

### 3. 🛰️ Live Satellite, Rain Radar & Typhoon Tracking (Zoom Earth)
* **Direct Field Coordinates**: Real-time integration with Zoom Earth centered on the farmer's specific rice field latitude and longitude.
* **Layer Shortcuts**:
  * 🌧️ **Doppler Rain Radar**: Live precipitation and moving rain cell animations.
  * 🛰️ **Satellite Imagery**: Real-time cloud cover, convection zones, and storm formation.
  * 🌀 **Wind & Typhoon Track**: Monsoon wind fields and approaching tropical depression paths.
* **In-App Experience**: Runs inside the app using hardware-accelerated Chrome Custom Tabs / Safari View Controller for smooth 60 FPS WebGL radar playback.

### 4. 🗺️ Multi-Field Management & Custom Geolocation
* **Multiple Paddies**: Farmers can add, track, and switch between separate rice fields (e.g., *Main Paddy (1.0 ha)*, *North Parcel (2.5 ha)*, *Upper Terraces (0.75 ha)*).
* **Custom Location Input**: Type any municipality and province in the Philippines (*e.g., Tuguegarao, Cagayan; Victoria, Tarlac; San Jose, Occidental Mindoro*).
* **Exact Paddy Pinning**: Interactive OpenStreetMap map-pin picker and phone GPS auto-detection to pin exact boundary coordinates.

### 5. 📊 Harvest Yield & Climate Risk Estimator
* **Heuristic & ML-Powered**: Calculates expected harvest yield in total cavans, metric tons, and cavans per hectare based on rice variety, maturity duration, parcel area, and 7-day weather conditions.
* **Risk Breakdown**: Traffic-light climate risk badge (low / medium / high) highlighting specific risk factors (prolonged rain, high humidity blast risk, lodging wind speeds) with numbered improvement tips.

### 6. 🌐 Trilingual Localization
* Full native translations across all screens:
  * **English**
  * **Filipino (Tagalog)**
  * **Bisaya (Cebuano)**

### 7. 📶 Offline-First & Authentication
* **Guest Mode**: Farmers can continue offline as guests without an email or account. Scans, profiles, and cached forecasts remain on the device.
* **Firebase Authentication**: One-tap Google Sign-In and Email/Password authentication for cloud backup when connected.

---

## 🏛️ System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            PALAYPLAN MOBILE (Flutter)                       │
│                                                                             │
│  ┌──────────────────┐  ┌──────────────────┐  ┌───────────────────────────┐  │
│  │   HomeScreen     │  │  WeatherScreen   │  │   Rice Disease Scanner    │  │
│  │ - Field Summary  │  │ - 7-Day Forecast │  │ - On-Device TFLite (0.12) │  │
│  │ - Crop Arc Gauge │  │ - Weather Descs  │  │ - 10-Class Classification │  │
│  │ - PalayCheck Card│  │ - Zoom Earth Card│  │ - Treatment Guidance      │  │
│  └─────────┬────────┘  └────────┬─────────┘  └───────────────────────────┘  │
│            │                    │                                           │
│  ┌─────────┴────────┐  ┌────────┴─────────┐  ┌───────────────────────────┐  │
│  │ CalendarScreen   │  │   YieldScreen    │  │     EditFieldSheet        │  │
│  │ - 4 Crop Phases  │  │ - Cavans / Ha    │  │ - Multi-Field Switcher    │  │
│  │ - Water & AWD    │  │ - Risk Factors   │  │ - Map Pin (OpenStreetMap) │  │
│  └──────────────────┘  └──────────────────┘  └───────────────────────────┘  │
│                                                                             │
│     Services: ApiService (Offline Caching) | ZoomEarthService | Auth        │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │ REST API (HTTP)
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                            PALAYPLAN BACKEND (FastAPI)                      │
│                                                                             │
│  Routers:                                                                   │
│   ├── /weather/forecast   -> OWM API with auto-fallback to Open-Meteo       │
│   ├── /advisory/          -> 6 PhilRice PalayCheck Agro-Advisory Rules      │
│   ├── /predict/yield      -> Harvest Yield & Climate Risk Predictor         │
│   └── /auth/              -> JWT Auth + Firebase Admin Token Verification   │
│                                                                             │
│  Database: SQLite (local dev) / PostgreSQL / MySQL                          │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📁 Repository Structure

```
palayplan/
├── mobile/                           # Flutter mobile client
│   ├── lib/
│   │   ├── l10n/
│   │   │   └── app_strings.dart      # Trilingual strings (EN / FIL / CEB)
│   │   ├── models/                   # Data models (Weather, Advisory, FieldProfile)
│   │   ├── providers/                # State management (FieldProvider, LanguageProvider)
│   │   ├── screens/                  # Application screens
│   │   │   ├── home_screen.dart      # Main dashboard with hero & feature grid
│   │   │   ├── weather_screen.dart   # 7-day forecast & Zoom Earth card
│   │   │   ├── scan_screen.dart      # Camera/gallery leaf capture
│   │   │   ├── result_screen.dart    # Disease diagnosis & treatment advice
│   │   │   ├── calendar_screen.dart  # 4-stage cropping calendar
│   │   │   ├── yield_screen.dart     # Harvest yield & risk estimator
│   │   │   └── settings_screen.dart  # Account, language, and privacy settings
│   │   ├── services/                 # API, TFLite classifier, PalayCheck engine, Zoom Earth
│   │   └── widgets/                  # Reusable UI widgets & sheets
│   ├── assets/
│   │   ├── images/                   # Authentic Philippine rice farm photos
│   │   ├── icons/                    # App launcher icons & brand logo
│   │   └── models/                   # Quantized TFLite leaf disease model
│   └── test/                         # 34 comprehensive unit & widget tests
│
├── backend/                          # FastAPI REST backend
│   ├── app/
│   │   ├── routers/                  # API route endpoints (/weather, /advisory, /predict, /auth)
│   │   ├── services/                 # Weather service (Open-Meteo fallback) & Advisory engine
│   │   ├── ml/                       # Yield prediction ML model & heuristic fallback
│   │   ├── models/                   # SQLAlchemy database models
│   │   └── schemas/                  # Pydantic request/response schemas
│   ├── .env.example                  # Environment configuration template
│   └── requirements.txt              # Python dependencies
│
└── ROADMAP.md                        # Project changelog, milestones & test status
```

---

## 🚀 Quick Start Guide

### Prerequisites
* **Flutter SDK**: `>= 3.3.0`
* **Python**: `>= 3.10`
* **Android Studio / Xcode** (for mobile deployment)

---

### Backend Setup

1. **Navigate to the backend directory**:
   ```bash
   cd backend
   ```

2. **Create a Python virtual environment and activate it**:
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Configure environment variables**:
   ```bash
   cp .env.example .env
   # Edit .env with your settings (works out-of-the-box with SQLite and Open-Meteo)
   ```

5. **Start the development server**:
   ```bash
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```
   * Interactive API docs: `http://localhost:8000/docs`

---

### Mobile Setup

1. **Navigate to the mobile directory**:
   ```bash
   cd mobile
   ```

2. **Install Flutter packages**:
   ```bash
   flutter pub get
   ```

3. **Run code analysis and tests**:
   ```bash
   flutter analyze   # 0 issues
   flutter test      # 34 passed
   ```

4. **Launch the application**:
   ```bash
   flutter run
   ```
   * *For Android Emulator, the app connects to the backend at `http://10.0.2.2:8000` automatically.*
   * *To specify a custom backend IP*:
     ```bash
     flutter run --dart-define=API_BASE_URL=http://YOUR_LOCAL_IP:8000
     ```

---

## 🧪 Test Coverage

The test suite contains **34 automated tests** covering core agronomy, ML models, offline persistence, multi-field management, and UI flows:

| Test Suite | File | Tests | Status |
|:---|:---|:---:|:---:|
| **PhilRice PalayCheck Engine** | `test/recommendation_service_test.dart` | 4 | ✅ Pass |
| **Disease Classifier Model** | `test/disease_classifier_test.dart` | 1 | ✅ Pass |
| **Full App Navigation Flow** | `test/full_app_test.dart` | 7 | ✅ Pass |
| **Field Profile & Map Pin** | `test/field_profile_test.dart` | 4 | ✅ Pass |
| **Multi-Field Management** | `test/multi_field_test.dart` | 2 | ✅ Pass |
| **Zoom Earth Radar URLs** | `test/zoom_earth_test.dart` | 2 | ✅ Pass |
| **Yield Estimator Screen** | `test/yield_screen_test.dart` | 1 | ✅ Pass |
| **Trilingual Translations** | `test/language_switching_test.dart` | 4 | ✅ Pass |
| **Offline Cache & Fallback** | `test/offline_api_test.dart` | 3 | ✅ Pass |
| **Settings & Privacy** | `test/settings_privacy_test.dart` | 3 | ✅ Pass |
| **App Smoke Test** | `test/widget_test.dart` | 3 | ✅ Pass |
| **Total** | | **34** | **100% Pass** |

---

## 🇵🇭 Philippine Agronomic Standards

* **PhilRice PalayCheck**: Recommendations follow the Philippine Rice Research Institute's 8 Key Checks for irrigated lowland and rainfed ecosystems.
* **NSIC Catalog**: Integrated Philippine National Seed Industry Council rice varieties (e.g., *NSIC Rc 222 (Tubigan 21)*, *NSIC Rc 160*, *NSIC Rc 440*, *PSB Rc 10*, *Mestiso 20*).
* **Weather Integration**: Hyperlocal agro-weather via Open-Meteo & OpenWeatherMap, with live satellite and typhoon tracking via Zoom Earth.

---

## 📄 License & Attribution

* Developed for Philippine smallholder rice farmers and agricultural technicians.
* OpenStreetMap contributors for map tiles.
* Unsplash Philippine agricultural photography.
