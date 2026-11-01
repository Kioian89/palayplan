from sqlalchemy import Column, Integer, String, Float, DateTime
from sqlalchemy.sql import func

from app.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String(120), nullable=False)
    phone_number = Column(String(20), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)

    # Location, used to fetch hyper-local weather
    municipality = Column(String(120), nullable=False)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)

    preferred_language = Column(String(10), default="en")  # e.g. "en", "tl", "ceb"
    created_at = Column(DateTime(timezone=True), server_default=func.now())
