from pydantic import Field
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "Vinayak SmartLoad Backend"
    API_V1_STR: str = "/api"
    SECRET_KEY: str = Field(default="", validation_alias="SECRET_KEY")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    BOOTSTRAP_ADMIN_PASSWORD: str = Field(default="", validation_alias="BOOTSTRAP_ADMIN_PASSWORD")
    RESET_ADMIN_PASSWORD: bool = Field(default=False, validation_alias="RESET_ADMIN_PASSWORD")
    ADMIN_CORS_ORIGINS: str = Field(default="http://localhost:5173", validation_alias="ADMIN_CORS_ORIGINS")
    
    # SQLite for development, Postgres for prod
    DATABASE_URL: str = Field(default="sqlite+aiosqlite:///./sql_app.db", validation_alias="DATABASE_URL")

    @property
    def cors_origins(self) -> list[str]:
        configured = [origin.strip() for origin in self.ADMIN_CORS_ORIGINS.split(",") if origin.strip()]
        # Keep the production admin origin available even if Render was
        # provisioned with the original localhost-only default.
        required = ["https://logistics-vision-ai.vercel.app"]
        return list(dict.fromkeys(configured + required))

    def validate_runtime_secrets(self) -> None:
        if not self.SECRET_KEY or len(self.SECRET_KEY) < 32:
            raise RuntimeError("SECRET_KEY must be configured and at least 32 characters long")

    @property
    def get_database_url(self) -> str:
        # Render and Heroku provide "postgres://", but async sqlalchemy needs "postgresql+asyncpg://"
        url = self.DATABASE_URL
        if url.startswith("postgres://"):
            url = url.replace("postgres://", "postgresql+asyncpg://", 1)
        # If it's a synchronous postgresql url, convert it to async
        elif url.startswith("postgresql://"):
            url = url.replace("postgresql://", "postgresql+asyncpg://", 1)
        return url

settings = Settings()
