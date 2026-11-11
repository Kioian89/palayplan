"""
Central application configuration, loaded from environment variables (.env).
"""
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
        protected_namespaces=("settings_",),
    )

    # Database
    database_url: str = "sqlite:///./palayplan.db"

    # Weather
    openweather_api_key: str = ""
    openweather_base_url: str = "https://api.openweathermap.org/data/3.0"

    # Auth
    jwt_secret_key: str = ""
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 60

    # CORS / app runtime
    allowed_origins: str = "*"
    app_env: str = "development"

    # ML
    model_artifact_path: str = "app/ml/model_artifact/yield_model.joblib"

    # Firebase (optional)
    firebase_credentials_path: str = ""

    @property
    def normalized_allowed_origins(self) -> list[str]:
        origins = [origin.strip() for origin in self.allowed_origins.split(",")]
        filtered = [origin for origin in origins if origin]
        return filtered or ["*"]


settings = Settings()
