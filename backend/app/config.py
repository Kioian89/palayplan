"""
Central application configuration, loaded from environment variables (.env).
"""
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    # Database
    database_url: str = "mysql+pymysql://palayplan_user:password@localhost:3306/palayplan_db"

    # Weather
    openweather_api_key: str = ""
    openweather_base_url: str = "https://api.openweathermap.org/data/3.0"

    # Auth
    jwt_secret_key: str = "dev-secret-change-me"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 1440

    # ML
    model_artifact_path: str = "app/ml/model_artifact/yield_model.joblib"

    # Firebase (optional)
    firebase_credentials_path: str = "firebase-service-account.json"


settings = Settings()
