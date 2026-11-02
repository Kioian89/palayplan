# Contributing to PalayPlan 🌾

Thank you for your interest in contributing to **PalayPlan**! Whether you are an agronomist, Flutter developer, Python engineer, machine learning researcher, or local language translator, your contributions help support Philippine rice farmers with smart, science-backed agricultural tools.

---

## 📋 Table of Contents
1. [Code of Conduct](#code-of-conduct)
2. [How to Contribute](#how-to-contribute)
3. [Development Setup](#development-setup)
4. [Contribution Guidelines](#contribution-guidelines)
   - [Mobile (Flutter)](#mobile-flutter)
   - [Backend (FastAPI)](#backend-fastapi)
   - [Machine Learning & Computer Vision](#machine-learning--computer-vision)
   - [Agronomy & PalayCheck Science](#agronomy--palaycheck-science)
   - [Localization (Trilingual Support)](#localization-trilingual-support)
5. [Pull Request Process](#pull-request-process)
6. [Issue Reporting](#issue-reporting)

---

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md). Please treat all contributors, farmers, and extension workers with patience, kindness, and respect.

---

## How to Contribute

- **Report Bugs**: Submit clear bug reports with device logs and steps to reproduce.
- **Propose Features**: Suggest improvements for agro-weather forecasting, disease diagnosis, or yield modeling.
- **Submit Pull Requests**: Fix issues, implement features, or improve documentation and test coverage.
- **Translate**: Improve translations in Filipino (Tagalog) and Bisaya (Cebuano).
- **Verify Agronomy**: Review fertilizer, irrigation, and pest management guidelines against PhilRice PalayCheck and IRRI standards.

---

## Development Setup

### Prerequisites
- **Flutter SDK**: `>= 3.24.0` (Dart `>= 3.5.0`)
- **Python**: `>= 3.10`
- **Git**

### Clone & Branching
```bash
git clone https://github.com/Kioian89/palayplan.git
cd palayplan

# Create a feature branch
git checkout -b feat/your-feature-name
# or for bug fixes:
git checkout -b fix/your-bug-fix
```

### Mobile App Setup
```bash
cd mobile
flutter pub get
flutter analyze
flutter test
flutter run
```

### Backend API Setup
```bash
cd backend
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env
pytest
uvicorn app.main:app --reload
```

---

## Contribution Guidelines

### Mobile (Flutter)
- Maintain **0 analyzer issues**: `flutter analyze` must pass with zero warnings.
- Write unit/widget tests for any new UI or business logic under `mobile/test/`.
- Ensure offline resilience: Never assume internet connectivity; all weather, advisory, and field features must handle offline states gracefully via caching.
- Optimize performance: Keep widget builds lean, use const constructors, and avoid blocking the main UI thread.

### Backend (FastAPI)
- Keep endpoints asynchronous and type-hinted using Pydantic schemas.
- Document any external weather or satellite API integrations with sensible caching and fallbacks.
- Write Pytest tests under `backend/tests/` to verify logic and advisory engines.

### Machine Learning & Computer Vision
- Disease models must operate within mobile memory and compute limits (TFLite quantized models $\le 20$ MB preferred).
- Keep confidence thresholds clear; never provide false high certainty for unknown or non-leaf photos.
- Ensure all 10 rice leaf classes have actionable cultural and chemical treatments aligned with Philippine Fertilizer and Pesticide Authority (FPA) guidelines.

### Agronomy & PalayCheck Science
- Adhere strictly to the **9 Key Checks of PhilRice PalayCheck**:
  - Key Check 1: Used high-quality certified seeds.
  - Key Check 2: Well-leveled, well-prepared land.
  - Key Check 3: Synchronous planting.
  - Key Check 4: Sufficient healthy seedlings.
  - Key Check 5: Correct nutrient & fertilizer timing (avoiding application during heavy rain forecast).
  - Key Check 6: Controlled irrigation via AWD (Alternate Wetting and Drying).
  - Key Check 7: No significant yield loss from pests/diseases.
  - Key Check 8: Harvested at optimum maturity (85–90% golden grains).
  - Key Check 9: Clean, properly dried palay ($\le 14\%$ moisture).

### Localization (Trilingual Support)
- Every new user-facing label or advisory must be added to `mobile/lib/l10n/app_strings.dart` in **all 3 supported languages**:
  1. **English**
  2. **Filipino (Tagalog)**
  3. **Bisaya (Cebuano)**

---

## Pull Request Process

1. Ensure all local tests and static analysis pass before opening your PR:
   ```bash
   cd mobile && flutter analyze && flutter test
   cd ../backend && pytest
   ```
2. Rebase or merge the latest `main` branch:
   ```bash
   git pull origin main --rebase
   ```
3. Open a Pull Request referencing the issue number it resolves.
4. Describe your changes clearly and provide screenshots or GIF recordings for mobile UI changes.
5. Automated CI on GitHub Actions will test and verify the build.

---

## Issue Reporting

When reporting issues, please use our GitHub Issue templates:
- Provide Android device model & OS version.
- Note field parameters (variety name, growth stage day, municipality/province).
- Include terminal logs or screenshots where applicable.
