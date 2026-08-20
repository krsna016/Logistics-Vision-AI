from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    PROJECT_NAME: str = "Vinayak SmartLoad Backend"
    ENVIRONMENT: str = Field(default="development", validation_alias="ENVIRONMENT")
    API_V1_STR: str = "/api"
    SECRET_KEY: str = Field(default="", validation_alias="SECRET_KEY")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    JWT_ISSUER: str = "vinayak-smartload"
    JWT_AUDIENCE: str = "vinayak-smartload-clients"
    BOOTSTRAP_ADMIN_PASSWORD: str = Field(default="", validation_alias="BOOTSTRAP_ADMIN_PASSWORD")
    RESET_ADMIN_PASSWORD: bool = Field(default=False, validation_alias="RESET_ADMIN_PASSWORD")
    ADMIN_CORS_ORIGINS: str = Field(default="http://localhost:5173", validation_alias="ADMIN_CORS_ORIGINS")
    TRUSTED_HOSTS: str = Field(default="localhost,127.0.0.1,testserver", validation_alias="TRUSTED_HOSTS")
    AUTO_CREATE_SCHEMA: bool = Field(default=True, validation_alias="AUTO_CREATE_SCHEMA")
    
    # SQLite for development, Postgres for prod
    DATABASE_URL: str = Field(default="sqlite+aiosqlite:///./sql_app.db", validation_alias="DATABASE_URL")

    ROBOFLOW_API_KEY: str = Field(default="", validation_alias="ROBOFLOW_API_KEY")
    ROBOFLOW_WORKSPACE: str = Field(
        default="anurags-workspace-hfvt2", validation_alias="ROBOFLOW_WORKSPACE"
    )
    ROBOFLOW_WORKFLOW_ID: str = Field(
        default="general-segmentation-api", validation_alias="ROBOFLOW_WORKFLOW_ID"
    )
    ROBOFLOW_CLASSES: str = Field(
        default="Cardboxes,Carton", validation_alias="ROBOFLOW_CLASSES"
    )
    ROBOFLOW_API_URL: str = Field(
        default="https://serverless.roboflow.com", validation_alias="ROBOFLOW_API_URL"
    )

    @property
    def is_production(self) -> bool:
        return self.ENVIRONMENT.strip().lower() == "production"

    @property
    def cors_origins(self) -> list[str]:
        return list(dict.fromkeys(
            origin.strip() for origin in self.ADMIN_CORS_ORIGINS.split(",") if origin.strip()
        ))

    @property
    def trusted_hosts(self) -> list[str]:
        return list(dict.fromkeys(
            host.strip() for host in self.TRUSTED_HOSTS.split(",") if host.strip()
        ))

    def validate_runtime_secrets(self) -> None:
        if self.ENVIRONMENT.strip().lower() not in {"development", "staging", "production"}:
            raise RuntimeError("ENVIRONMENT must be development, staging, or production")
        if not self.SECRET_KEY or len(self.SECRET_KEY) < 32:
            raise RuntimeError("SECRET_KEY must be configured and at least 32 characters long")
        if self.ACCESS_TOKEN_EXPIRE_MINUTES < 5 or self.ACCESS_TOKEN_EXPIRE_MINUTES > 1440:
            raise RuntimeError("ACCESS_TOKEN_EXPIRE_MINUTES must be between 5 and 1440")
        if not self.cors_origins:
            raise RuntimeError("ADMIN_CORS_ORIGINS must contain at least one origin")
        if not self.trusted_hosts:
            raise RuntimeError("TRUSTED_HOSTS must contain at least one host")
        if self.is_production:
            if self.get_database_url.startswith("sqlite"):
                raise RuntimeError("Production requires a managed PostgreSQL DATABASE_URL")
            if self.AUTO_CREATE_SCHEMA:
                raise RuntimeError("AUTO_CREATE_SCHEMA must be false in production; run migrations before startup")
            if "*" in self.trusted_hosts:
                raise RuntimeError("TRUSTED_HOSTS must not contain * in production")
            if any(not origin.startswith("https://") for origin in self.cors_origins):
                raise RuntimeError("Production ADMIN_CORS_ORIGINS must use HTTPS")

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
