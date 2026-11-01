from sqlalchemy import Column, Integer, String, Float, Date, ForeignKey, DateTime
from sqlalchemy.sql import func

from app.database import Base


class CropLog(Base):
    """
    Represents one planting cycle for a farmer: seed variety, start date,
    field size, and the resulting ML-generated schedule/yield estimate.
    """
    __tablename__ = "crop_logs"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    seed_variety = Column(String(80), nullable=False)       # e.g. "IR64", "NSIC Rc216"
    days_to_maturity = Column(Integer, nullable=False)        # e.g. 110 or 120
    field_size_hectares = Column(Float, nullable=False)
    start_date = Column(Date, nullable=False)                 # sowing/transplant date

    soil_type = Column(String(50), nullable=True)

    predicted_yield_cavans = Column(Float, nullable=True)
    climate_risk_level = Column(String(10), nullable=True)    # "low" | "medium" | "high"

    created_at = Column(DateTime(timezone=True), server_default=func.now())
