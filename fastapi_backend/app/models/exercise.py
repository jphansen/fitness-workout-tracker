from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, Field
from bson import ObjectId
from .user import PyObjectId


class ExerciseBase(BaseModel):
    """Base exercise model shared by all exercise types"""
    name: str = Field(..., min_length=1, max_length=100)
    type: str = Field(..., pattern="^(weight|cardio)$")
    user_id: Optional[PyObjectId] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    last_used: Optional[datetime] = None
    
    # Default values for quick logging
    default_weight: Optional[float] = Field(None, ge=0)
    default_reps: Optional[int] = Field(None, ge=0)
    default_sets: Optional[int] = Field(None, ge=0)
    default_time: Optional[float] = Field(None, ge=0)
    default_speed: Optional[float] = Field(None, ge=0)
    default_distance: Optional[float] = Field(None, ge=0)
    default_calories: Optional[int] = Field(None, ge=0)
    default_rpe: Optional[int] = Field(5, ge=1, le=10)
    
    # Last used values (for smart defaults)
    last_weight: Optional[float] = None
    last_reps: Optional[int] = None
    last_sets: Optional[int] = None
    last_time: Optional[float] = None
    last_speed: Optional[float] = None
    last_distance: Optional[float] = None
    last_calories: Optional[int] = None
    last_rpe: Optional[int] = None


class ExerciseCreate(ExerciseBase):
    """Model for creating a new exercise"""
    pass


class ExerciseUpdate(BaseModel):
    """Model for updating an existing exercise"""
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    type: Optional[str] = Field(None, pattern="^(weight|cardio)$")
    default_weight: Optional[float] = Field(None, ge=0)
    default_reps: Optional[int] = Field(None, ge=0)
    default_sets: Optional[int] = Field(None, ge=0)
    default_time: Optional[float] = Field(None, ge=0)
    default_speed: Optional[float] = Field(None, ge=0)
    default_distance: Optional[float] = Field(None, ge=0)
    default_calories: Optional[int] = Field(None, ge=0)
    default_rpe: Optional[int] = Field(None, ge=1, le=10)


class Exercise(ExerciseBase):
    """Complete exercise model with database ID"""
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    
    class Config:
        populate_by_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
        json_schema_extra = {
            "example": {
                "name": "Bench Press",
                "type": "weight",
                "default_weight": 60.0,
                "default_reps": 10,
                "default_sets": 3,
                "default_rpe": 7,
                "last_weight": 65.0,
                "last_reps": 8,
                "last_sets": 4,
                "last_rpe": 8,
                "created_at": "2024-01-01T10:00:00",
                "updated_at": "2024-01-02T10:00:00",
                "last_used": "2024-01-02T10:00:00"
            }
        }


class ExerciseInDB(Exercise):
    """Exercise model as stored in database"""
    pass


# Predefined exercises for seeding
PREDEFINED_EXERCISES = [
    {
        "name": "Bench Press",
        "type": "weight",
        "default_weight": 60.0,
        "default_reps": 10,
        "default_sets": 3,
        "default_rpe": 7
    },
    {
        "name": "Squat",
        "type": "weight",
        "default_weight": 80.0,
        "default_reps": 8,
        "default_sets": 4,
        "default_rpe": 8
    },
    {
        "name": "Deadlift",
        "type": "weight",
        "default_weight": 100.0,
        "default_reps": 5,
        "default_sets": 3,
        "default_rpe": 9
    },
    {
        "name": "Running",
        "type": "cardio",
        "default_time": 30.0,
        "default_speed": 10.0,
        "default_distance": 5.0,
        "default_calories": 300,
        "default_rpe": 6
    },
    {
        "name": "Cycling",
        "type": "cardio",
        "default_time": 45.0,
        "default_speed": 20.0,
        "default_distance": 15.0,
        "default_calories": 400,
        "default_rpe": 5
    },
    {
        "name": "Push-ups",
        "type": "weight",
        "default_weight": 0.0,  # Bodyweight
        "default_reps": 15,
        "default_sets": 3,
        "default_rpe": 6
    }
]