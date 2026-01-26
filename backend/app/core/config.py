from pydantic import EmailStr
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file="../.env",
        env_ignore_empty=True,
        extra="ignore",
    )

    API_V1_STR: str = "/api/v1"
    SECRET_KEY: str = "dev-secret-key-change-in-production"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 8  # 8 days

    # SQLite database
    DATABASE_URL: str = "sqlite:///./database.sqlite"

    # First superuser
    FIRST_SUPERUSER: EmailStr = "dev@example.com"
    FIRST_SUPERUSER_PASSWORD: str = "DevPassword"


settings = Settings()
