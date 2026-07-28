from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .core.config import settings
from .db.database import engine, Base
from .routers import auth, users

app = FastAPI(
    title=settings.PROJECT_NAME,
    openapi_url=f"{settings.API_V1_STR}/openapi.json"
)

# Configure CORS for the React Admin Panel
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

from sqlalchemy import text
from sqlalchemy.future import select
from .models.user import User
from .core.security import get_password_hash

@app.on_event("startup")
async def startup_event():
    settings.validate_runtime_secrets()
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
        # Compatibility migration for the original local SQLite database.
        # Production deployments should use versioned migrations.
        if settings.get_database_url.startswith("sqlite"):
            columns = await conn.execute(text("PRAGMA table_info(users)"))
            existing = {row[1] for row in columns}
            if "failed_login_attempts" not in existing:
                await conn.execute(text("ALTER TABLE users ADD COLUMN failed_login_attempts INTEGER NOT NULL DEFAULT 0"))
            if "locked_until" not in existing:
                await conn.execute(text("ALTER TABLE users ADD COLUMN locked_until DATETIME"))
        
    # Bootstrap an administrator only when an explicit one-time password is supplied.
    from .db.database import AsyncSessionLocal
    async with AsyncSessionLocal() as session:
        if settings.BOOTSTRAP_ADMIN_PASSWORD:
            result = await session.execute(select(User).where(User.employee_id == "ADMIN"))
            admin = result.scalars().first()
        else:
            admin = True
        if not admin and settings.BOOTSTRAP_ADMIN_PASSWORD:
            db_admin = User(
                employee_id="ADMIN",
                name="Super Administrator",
                role="Admin",
                hashed_password=get_password_hash(settings.BOOTSTRAP_ADMIN_PASSWORD),
            )
            session.add(db_admin)
            await session.commit()

app.include_router(auth.router, prefix=f"{settings.API_V1_STR}/auth", tags=["Authentication"])
app.include_router(users.router, prefix=f"{settings.API_V1_STR}/users", tags=["Users"])

@app.get("/")
def root():
    return {"message": "Vinayak SmartLoad Central Auth Server is running"}
