from datetime import datetime, timedelta
from pathlib import Path

import firebase_admin
from firebase_admin import auth as firebase_auth, credentials
from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from passlib.context import CryptContext
from jose import jwt
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.config import settings
from app.database import get_db
from app.models.user import User

router = APIRouter(prefix="/auth", tags=["Auth"])
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
bearer_scheme = HTTPBearer(auto_error=False)


class RegisterRequest(BaseModel):
    full_name: str
    phone_number: str
    password: str
    municipality: str
    latitude: float | None = None
    longitude: float | None = None
    preferred_language: str = "en"


class LoginRequest(BaseModel):
    phone_number: str
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


class FirebaseIdentityResponse(BaseModel):
    uid: str
    email: str | None = None
    display_name: str | None = None
    phone_number: str | None = None
    email_verified: bool = False
    sign_in_provider: str | None = None


def _firebase_app():
    try:
        return firebase_admin.get_app()
    except ValueError:
        credentials_path = settings.firebase_credentials_path.strip()
        if credentials_path:
            path = Path(credentials_path).expanduser()
            if not path.is_file():
                raise HTTPException(
                    status_code=503,
                    detail=(
                        "Firebase authentication is not configured. "
                        "FIREBASE_CREDENTIALS_PATH does not point to a service-account file."
                    ),
                )
            return firebase_admin.initialize_app(credentials.Certificate(str(path)))

        # Cloud Run supplies Application Default Credentials to its service account.
        return firebase_admin.initialize_app()


def _verify_firebase_id_token(token: str) -> dict:
    try:
        return firebase_auth.verify_id_token(
            token,
            app=_firebase_app(),
            check_revoked=True,
        )
    except (
        firebase_auth.InvalidIdTokenError,
        firebase_auth.ExpiredIdTokenError,
        firebase_auth.RevokedIdTokenError,
        firebase_auth.UserDisabledError,
    ) as error:
        raise HTTPException(
            status_code=401,
            detail="Invalid or expired Firebase ID token.",
            headers={"WWW-Authenticate": "Bearer"},
        ) from error


def create_access_token(user_id: int) -> str:
    secret = settings.jwt_secret_key.strip()
    if not secret:
        raise HTTPException(
            status_code=500,
            detail="JWT secret is not configured.",
        )

    expire = datetime.utcnow() + timedelta(minutes=settings.access_token_expire_minutes)
    payload = {"sub": str(user_id), "exp": expire}
    return jwt.encode(payload, secret, algorithm=settings.jwt_algorithm)


@router.post("/register", response_model=TokenResponse)
def register(req: RegisterRequest, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.phone_number == req.phone_number).first()
    if existing:
        raise HTTPException(status_code=400, detail="Phone number already registered.")

    user = User(
        full_name=req.full_name,
        phone_number=req.phone_number,
        hashed_password=pwd_context.hash(req.password),
        municipality=req.municipality,
        latitude=req.latitude,
        longitude=req.longitude,
        preferred_language=req.preferred_language,
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    return TokenResponse(access_token=create_access_token(user.id))


@router.post("/login", response_model=TokenResponse)
def login(req: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.phone_number == req.phone_number).first()
    if not user or not pwd_context.verify(req.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Invalid phone number or password.")

    return TokenResponse(access_token=create_access_token(user.id))


@router.get("/me", response_model=FirebaseIdentityResponse)
def firebase_identity(
    credentials_header: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
):
    if credentials_header is None:
        raise HTTPException(
            status_code=401,
            detail="A Firebase ID token is required.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    decoded_token = _verify_firebase_id_token(credentials_header.credentials)
    firebase_claims = decoded_token.get("firebase") or {}
    return FirebaseIdentityResponse(
        uid=decoded_token["uid"],
        email=decoded_token.get("email"),
        display_name=decoded_token.get("name"),
        phone_number=decoded_token.get("phone_number"),
        email_verified=decoded_token.get("email_verified", False),
        sign_in_provider=firebase_claims.get("sign_in_provider"),
    )
