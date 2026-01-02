from typing import List
from fastapi import APIRouter, HTTPException, status
from bson import ObjectId

from app.database.mongodb import get_workouts_collection
from app.models.workout import (
    WorkoutCreate, WorkoutUpdate, WorkoutResponse, WorkoutInDB
)

router = APIRouter(prefix="/workouts", tags=["workouts"])


@router.get("/", response_model=List[WorkoutResponse])
def get_workouts():
    """Get all workouts"""
    collection = get_workouts_collection()
    workouts = list(collection.find().limit(100))
    return workouts


@router.get("/{workout_id}", response_model=WorkoutResponse)
def get_workout(workout_id: str):
    """Get a specific workout by ID"""
    collection = get_workouts_collection()
    
    if not ObjectId.is_valid(workout_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid workout ID format"
        )
    
    workout = collection.find_one({"_id": ObjectId(workout_id)})
    
    if not workout:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Workout not found"
        )
    
    return workout


@router.post("/", response_model=WorkoutResponse, status_code=status.HTTP_201_CREATED)
def create_workout(workout: WorkoutCreate):
    """Create a new workout"""
    collection = get_workouts_collection()
    
    # Create WorkoutInDB instance
    workout_in_db = WorkoutInDB(**workout.dict())
    
    # Calculate total volume
    workout_in_db.total_volume = workout_in_db.calculate_total_volume()
    
    # Insert into database
    result = collection.insert_one(workout_in_db.dict(by_alias=True))
    
    # Retrieve the created workout
    created_workout = collection.find_one({"_id": result.inserted_id})
    
    return created_workout


@router.put("/{workout_id}", response_model=WorkoutResponse)
def update_workout(workout_id: str, workout_update: WorkoutUpdate):
    """Update an existing workout"""
    collection = get_workouts_collection()
    
    if not ObjectId.is_valid(workout_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid workout ID format"
        )
    
    # Get existing workout
    existing = collection.find_one({"_id": ObjectId(workout_id)})
    
    if not existing:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Workout not found"
        )
    
    # Prepare update data
    update_data = workout_update.dict(exclude_unset=True)
    
    # If exercises are updated, recalculate total volume
    if "exercises" in update_data:
        # Create temporary workout to calculate volume
        temp_workout = WorkoutInDB(**existing)
        temp_workout.exercises = update_data["exercises"]
        update_data["total_volume"] = temp_workout.calculate_total_volume()
    
    # Perform update
    collection.update_one(
        {"_id": ObjectId(workout_id)},
        {"$set": update_data}
    )
    
    # Return updated workout
    updated_workout = collection.find_one({"_id": ObjectId(workout_id)})
    
    return updated_workout


@router.delete("/{workout_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_workout(workout_id: str):
    """Delete a workout"""
    collection = get_workouts_collection()
    
    if not ObjectId.is_valid(workout_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid workout ID format"
        )
    
    result = collection.delete_one({"_id": ObjectId(workout_id)})
    
    if result.deleted_count == 0:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Workout not found"
        )
