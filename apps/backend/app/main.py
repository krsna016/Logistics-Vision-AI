import asyncio
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
    allow_origins=["*"], # In production, restrict this to the admin panel URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

from sqlalchemy.future import select
from .models.user import User
from .core.security import get_password_hash

@app.on_event("startup")
async def startup_event():
    async with engine.begin() as conn:
        # For development only: automatically create tables
        await conn.run_sync(Base.metadata.create_all)
        
    # Seed default admin user if none exists
    from .db.database import AsyncSessionLocal
    async with AsyncSessionLocal() as session:
        result = await session.execute(select(User).where(User.employee_id == "ADMIN"))
        admin = result.scalars().first()
        if not admin:
            db_admin = User(
                employee_id="ADMIN",
                name="Super Administrator",
                role="Admin",
                hashed_password=get_password_hash("admin123"),
            )
            session.add(db_admin)
            await session.commit()

app.include_router(auth.router, prefix=f"{settings.API_V1_STR}/auth", tags=["Authentication"])
app.include_router(users.router, prefix=f"{settings.API_V1_STR}/users", tags=["Users"])

@app.get("/")
def root():
    return {"message": "Vinayak SmartLoad Central Auth Server is running"}
