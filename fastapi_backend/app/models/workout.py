from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, Field
from pydantic_core import core_schema
from bson import ObjectId


class PyObjectId(ObjectId):
    """Custom type for MongoDB ObjectId"""
    @classmethod
    def __get_pydantic_core_schema__(cls, source_type, handler):
        return core_schema.with_info_plain_validator_function(
            cls.validate,
            serialization=core_schema.plain_serializer_function_ser_schema(
                lambda x: str(x),
                return_schema=core_schema.str_schema(),
            ),
        )

    @classmethod
    def validate(cls, v, info):
        if isinstance(v, ObjectId):
            return v
        if isinstance(v, str):
            if ObjectId.is_valid(v):
                return ObjectId(v)
        raise ValueError("Invalid ObjectId")


class Exercise(BaseModel):
    """Exercise model within a workout"""
    name: str = Field(..., description="Name of the exercise")
    type: str = Field("weight", description="Exercise type: 'weight' or 'cardio'")
    
    # Weight training fields
    weight: Optional[float] = Field(None, description="Weight in kg")
    reps: Optional[int] = Field(None, description="Number of repetitions")
    sets: Optional[int] = Field(None, description="Number of sets")
    
    # Cardio fields
    time: Optional[float] = Field(None, description="Time in minutes")
    speed: Optional[float] = Field(None, description="Speed (km/h or similar)")
    distance: Optional[float] = Field(None, description="Distance in km")
    calories: Optional[int] = Field(None, description="Calories burned")
    
    # Common fields
    rpe: int = Field(
        5, ge=1, le=10, description="Rate of perceived exertion (1-10)"
    )
    notes: Optional[str] = Field(None, description="Additional notes")
    
    @property
    def volume(self) -> float:
        """Calculate exercise volume/score based on type"""
        if self.type == "weight":
            return (self.weight or 0) * (self.reps or 0) * (self.sets or 0)
        elif self.type == "cardio":
            return (self.time or 0) * (self.speed or 0) * self.rpe
        return 0.0
    
    class Config:
        json_schema_extra = {
            "example": {
                "name": "Kettlebell Swings",
                "type": "weight",
                "weight": 10.0,
                "reps": 15,
                "sets": 3,
                "rpe": 5,
                "notes": "Focus on form"
            }
        }


class WorkoutCreate(BaseModel):
    """Model for creating a new workout"""
    date: datetime = Field(default_factory=datetime.now, description="Workout date")
    workout_type: str = Field("Daily", description="Workout type (optional, default: Daily)")
    exercises: List[Exercise] = Field(..., description="List of exercises")
    notes: Optional[str] = Field(None, description="Overall workout notes")
    user_id: Optional[str] = Field(None, description="User ID (will be set from auth token)")
    
    class Config:
        json_schema_extra = {
            "example": {
                "workout_type": "C",
                "exercises": [{
                    "name": "Kettlebell Swings: 45 sec / 15 sec rest",
                    "weight": 10.0,
                    "reps": 15,
                    "sets": 3,
                    "rpe": 5
                }],
                "notes": "Circuit workout completed"
            }
        }


class WorkoutUpdate(BaseModel):
    """Model for updating a workout"""
    date: Optional[datetime] = None
    workout_type: Optional[str] = None
    exercises: Optional[List[Exercise]] = None
    notes: Optional[str] = None


class WorkoutInDB(WorkoutCreate):
    """Workout model as stored in database"""
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    total_volume: float = Field(
        0.0, description="Total volume (weight × reps × sets)"
    )
    
    class Config:
        populate_by_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
    
    def calculate_total_volume(self) -> float:
        """Calculate total volume from all exercises"""
        total = 0.0
        for exercise in self.exercises:
            total += exercise.volume
        return total


class WorkoutResponse(WorkoutInDB):
    """Workout model for API responses"""
    pass
