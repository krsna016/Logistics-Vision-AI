# FastAPI dependency declarations intentionally use Depends in defaults.
# ruff: noqa: B008

from fastapi import Depends, FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from .core.config import settings
from .db.database import Base, engine, get_db
from .models import sync as sync_model  # noqa: F401 - register table metadata
from .routers import auth, inference, locations, sync, users

app = FastAPI(
    title=settings.PROJECT_NAME,
    openapi_url=f"{settings.API_V1_STR}/openapi.json"
)

# Configure CORS for the React Admin Panel
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type"],
)

from sqlalchemy.future import select

from .core.security import get_password_hash
from .models.user import User


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
            await conn.execute(text(
                "CREATE INDEX IF NOT EXISTS ix_location_pings_recorded_at "
                "ON location_pings (recorded_at)"
            ))
        else:
            # The original production PostgreSQL table predates the login
            # lockout fields. Keep startup self-healing until migrations are
            # introduced, and make each alteration idempotent.
            await conn.execute(text(
                "ALTER TABLE users ADD COLUMN IF NOT EXISTS "
                "failed_login_attempts INTEGER NOT NULL DEFAULT 0"
            ))
            await conn.execute(text(
                "ALTER TABLE users ADD COLUMN IF NOT EXISTS locked_until TIMESTAMP WITH TIME ZONE"
            ))
            await conn.execute(text(
                "CREATE INDEX IF NOT EXISTS ix_location_pings_recorded_at "
                "ON location_pings (recorded_at)"
            ))

        # Canonicalize legacy role names before any authenticated request.
        # Existing operators/managers become Supervisors; only legacy Admin
        # accounts retain elevated access as Administrators.
        await conn.execute(text(
            "UPDATE users SET role = CASE LOWER(role) "
            "WHEN 'admin' THEN 'Administrator' "
            "WHEN 'administrator' THEN 'Administrator' "
            "WHEN 'supervisor' THEN 'Supervisor' "
            "WHEN 'manager' THEN 'Supervisor' "
            "WHEN 'operator' THEN 'Supervisor' "
            "ELSE 'Supervisor' END"
        ))
        
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
                role="Administrator",
                hashed_password=get_password_hash(settings.BOOTSTRAP_ADMIN_PASSWORD),
            )
            session.add(db_admin)
            await session.commit()
        elif admin and settings.BOOTSTRAP_ADMIN_PASSWORD and settings.RESET_ADMIN_PASSWORD:
            # Explicitly opt-in one-time recovery for a known admin credential.
            # Keep this disabled after the password has been reset.
            admin.hashed_password = get_password_hash(settings.BOOTSTRAP_ADMIN_PASSWORD)
            admin.is_active = True
            admin.failed_login_attempts = 0
            admin.locked_until = None
            await session.commit()

app.include_router(auth.router, prefix=f"{settings.API_V1_STR}/auth", tags=["Authentication"])
app.include_router(users.router, prefix=f"{settings.API_V1_STR}/users", tags=["Users"])
app.include_router(locations.router, prefix=f"{settings.API_V1_STR}/locations", tags=["Locations"])
app.include_router(sync.router, prefix=f"{settings.API_V1_STR}/sync", tags=["Synchronization"])
app.include_router(inference.router, prefix=f"{settings.API_V1_STR}/inference", tags=["Inference"])

@app.get("/")
def root():
    return {"message": "Vinayak SmartLoad Central Auth Server is running"}

@app.get("/health")
async def health_check(db: AsyncSession = Depends(get_db)):
    """Read-only deployment probe that confirms the API can reach its database."""
    try:
        await db.execute(text("SELECT 1"))
        return {
            "status": "ok",
            "database": "connected",
            "auth_policy": "exp-issuer-audience-required",
        }
    except Exception as exc:
        raise HTTPException(status_code=503, detail="Database unavailable") from exc
