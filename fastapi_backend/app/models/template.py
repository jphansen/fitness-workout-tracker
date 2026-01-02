from typing import List, Optional
from pydantic import BaseModel, Field
from bson import ObjectId
from .workout import Exercise, PyObjectId


class WorkoutTemplateCreate(BaseModel):
    """Model for creating a new workout template"""
    workout_type: str = Field(..., description="Workout type (A, B, C, D)")
    name: str = Field(..., description="Template name")
    description: str = Field(..., description="Template description")
    exercises: List[Exercise] = Field(..., description="Predefined exercises")
    user_id: Optional[str] = Field(None, description="User ID (will be set from auth token)")
    
    class Config:
        json_schema_extra = {
            "example": {
                "workout_type": "C",
                "name": "Circuit Workout",
                "description": "Circuit format (3 rounds, minimal rest)",
                "exercises": [
                    {
                        "name": "Kettlebell Swings: 45 sec / 15 sec rest",
                        "weight": 10.0,
                        "reps": 15,
                        "sets": 3,
                        "rpe": 5
                    },
                    {
                        "name": "Push-ups (or Chest Press): 45 sec / 15 sec rest",
                        "weight": 10.0,
                        "reps": 15,
                        "sets": 3,
                        "rpe": 5
                    }
                ]
            }
        }


class WorkoutTemplateUpdate(BaseModel):
    """Model for updating a workout template"""
    workout_type: Optional[str] = None
    name: Optional[str] = None
    description: Optional[str] = None
    exercises: Optional[List[Exercise]] = None


class WorkoutTemplate(WorkoutTemplateCreate):
    """Template for predefined workout types A-D"""
    id: PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    
    class Config(WorkoutTemplateCreate.Config):
        populate_by_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}


# Predefined templates data
WORKOUT_TEMPLATES = [
    {
        "workout_type": "A",
        "name": "Full Body Strength + HIIT",
        "description": "Warm-up, Strength training, HIIT Finisher",
        "exercises": [
            {
                "name": "Warm-up: 5 min (rowing machine or cross-trainer)",
                "weight": 0.0,
                "reps": 1,
                "sets": 1,
                "rpe": 3
            },
            {
                "name": "Chest Press Machine: 3×8-12 (2 min rest)",
                "weight": 10.0,
                "reps": 10,
                "sets": 3,
                "rpe": 5
            },
            {
                "name": "Lat Pulldown: 3×8-12 (2 min rest)",
                "weight": 10.0,
                "reps": 10,
                "sets": 3,
                "rpe": 5
            },
            {
                "name": "Shoulder Press Machine: 3×10-15 (90 sec rest)",
                "weight": 10.0,
                "reps": 12,
                "sets": 3,
                "rpe": 5
            },
            {
                "name": "Seated Row: 3×10-15 (90 sec rest)",
                "weight": 10.0,
                "reps": 12,
                "sets": 3,
                "rpe": 5
            },
            {
                "name": "Bicep Curls: 2×12-15 (60 sec rest)",
                "weight": 10.0,
                "reps": 15,
                "sets": 2,
                "rpe": 5
            },
            {
                "name": "Triceps Pushdown: 2×12-15 (60 sec rest)",
                "weight": 10.0,
                "reps": 15,
                "sets": 2,
                "rpe": 5
            },
            {
                "name": "HIIT Finisher: 5 min - 30 sec sprint / 30 sec walk",
                "weight": 0.0,
                "reps": 5,
                "sets": 1,
                "rpe": 8
            }
        ]
    },
    {
        "workout_type": "B",
        "name": "Leg Day + Cardio",
        "description": "Warm-up, Leg exercises, Steady Cardio",
        "exercises": [
            {
                "name": "Warm-up: 5 min (cycling)",
                "weight": 0.0,
                "reps": 1,
                "sets": 1,
                "rpe": 3
            },
            {
                "name": "Leg Press: 3×8-12 (2 min rest)",
                "weight": 10.0,
                "reps": 10,
                "sets": 3,
                "rpe": 5
            },
            {
                "name": "Leg Curl: 3×10-15 (90 sec rest)",
                "weight": 10.0,
                "reps": 12,
                "sets": 3,
                "rpe": 5
            },
            {
                "name": "Leg Extension: 3×10-15 (90 sec rest)",
                "weight": 10.0,
                "reps": 12,
                "sets": 3,
                "rpe": 5
            },
            {
                "name": "Calf Raises: 3×15-20 (60 sec rest)",
                "weight": 10.0,
                "reps": 18,
                "sets": 3,
                "rpe": 5
            },
            {
                "name": "Glute Machine: 2×12-15 (60 sec rest)",
                "weight": 10.0,
                "reps": 15,
                "sets": 2,
                "rpe": 5
            },
            {
                "name": "Steady Cardio: 10 min - Cross-trainer 70%",
                "weight": 0.0,
                "reps": 1,
                "sets": 1,
                "rpe": 6
            }
        ]
    },
    {
        "workout_type": "C",
        "name": "Circuit Training",
        "description": "Circuit format (3 rounds, minimal rest between exercises)",
        "exercises": [
            {
                "name": "Kettlebell Swings: 45 sec / 15 sec rest",
                "weight": 10.0,
                "reps": 15,
                "sets": 3,
                "rpe": 5
            },
            {
                "name": "Push-ups (or Chest Press): 45 sec / 15 sec",
                "weight": 10.0,
                "reps": 15,
                "sets": 3,
                "rpe": 5
            },
            {
                "name": "Bodyweight Squats: 45 sec / 15 sec rest",
                "weight": 0.0,
                "reps": 15,
                "sets": 3,
                "rpe": 5
            },
            {
                "name": "Dumbbell Rows: 45 sec / 15 sec",
                "weight": 10.0,
                "reps": 15,
                "sets": 3,
                "rpe": 5
            },
            {
                "name": "Plank: 45 sec / 15 sec rest",
                "weight": 0.0,
                "reps": 1,
                "sets": 3,
                "rpe": 5
            }
        ]
    },
    {
        "workout_type": "D",
        "name": "Cardio Variation",
        "description": "Choose different cardio each week",
        "exercises": [
            {
                "name": "Week 1: Incline treadmill walk",
                "weight": 0.0,
                "reps": 1,
                "sets": 1,
                "rpe": 5
            },
            {
                "name": "Week 2: Cycling intervals",
                "weight": 0.0,
                "reps": 1,
                "sets": 1,
                "rpe": 5
            },
            {
                "name": "Week 3: Rowing intervals",
                "weight": 0.0,
                "reps": 1,
                "sets": 1,
                "rpe": 5
            },
            {
                "name": "Week 4: Stair machine",
                "weight": 0.0,
                "reps": 1,
                "sets": 1,
                "rpe": 5
            },
            {
                "name": "Heart rate zone 2 (60-70% max)",
                "weight": 0.0,
                "reps": 1,
                "sets": 1,
                "rpe": 5
            }
        ]
    }
]
