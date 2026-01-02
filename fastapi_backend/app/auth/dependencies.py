from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from typing import Optional

from app.auth.auth_handler import verify_token, get_username_from_token
from app.database.mongodb import get_users_collection

security = HTTPBearer()


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security)
) -> dict:
    """Get current user from JWT token"""
    token = credentials.credentials
    
    # Verify token
    payload = verify_token(token)
    if payload is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    username = payload.get("sub")
    if username is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Get user from database
    users_collection = get_users_collection()
    user = users_collection.find_one({"username": username})
    
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Convert ObjectId to string for JSON serialization
    user["_id"] = str(user["_id"])
    return user


async def get_current_active_user(
    current_user: dict = Depends(get_current_user)
) -> dict:
    """Get current active user"""
    if not current_user.get("is_active", True):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Inactive user"
        )
    return current_user


def get_current_username(
    credentials: HTTPAuthorizationCredentials = Depends(security)
) -> str:
    """Get username from JWT token (simpler version for basic auth)"""
    token = credentials.credentials
    username = get_username_from_token(token)
    
    if username is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    return username
