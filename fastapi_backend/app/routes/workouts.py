from typing import List
from fastapi import APIRouter, HTTPException, status
from bson import ObjectId

from app.database.mongodb import get_workouts_collection
from app.models.workout import (
    WorkoutCreate, WorkoutUpdate, WorkoutResponse, WorkoutInDB, Exercise
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
    
    # Try to find by ObjectId first (for new workouts)
    if ObjectId.is_valid(workout_id):
        workout = collection.find_one({"_id": ObjectId(workout_id)})
        if workout:
            return workout
    
    # If not found by ObjectId, try as string (for existing workouts with string IDs)
    workout = collection.find_one({"_id": workout_id})
    
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
    workout_in_db = WorkoutInDB(**workout.model_dump())
    
    # Calculate total volume
    workout_in_db.total_volume = workout_in_db.calculate_total_volume()
    
    # Prepare document for insertion - convert model to dict but keep ObjectId as ObjectId
    workout_dict = workout_in_db.model_dump(by_alias=True, exclude={"id"})
    # Add _id as ObjectId
    workout_dict["_id"] = workout_in_db.id
    
    # Insert into database
    result = collection.insert_one(workout_dict)
    
    # Retrieve the created workout
    created_workout = collection.find_one({"_id": result.inserted_id})
    
    return created_workout


@router.put("/{workout_id}", response_model=WorkoutResponse)
def update_workout(workout_id: str, workout_update: WorkoutUpdate):
    """Update an existing workout"""
    collection = get_workouts_collection()
    
    # Try to find by ObjectId first
    existing = None
    if ObjectId.is_valid(workout_id):
        existing = collection.find_one({"_id": ObjectId(workout_id)})
    
    # If not found by ObjectId, try as string
    if not existing:
        existing = collection.find_one({"_id": workout_id})
    
    if not existing:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Workout not found"
        )
    
    # Prepare update data
    update_data = workout_update.model_dump(exclude_unset=True)
    
    # If exercises are updated, recalculate total volume
    if "exercises" in update_data:
        # Convert exercise dictionaries to Exercise instances for volume calculation
        exercise_instances = [Exercise(**ex) for ex in update_data["exercises"]]
        # Create temporary workout to calculate volume
        temp_workout = WorkoutInDB(**existing)
        temp_workout.exercises = exercise_instances
        update_data["total_volume"] = temp_workout.calculate_total_volume()
    
    # Perform update - use the same ID format as found
    if ObjectId.is_valid(workout_id) and isinstance(existing.get("_id"), ObjectId):
        query_id = ObjectId(workout_id)
    else:
        query_id = workout_id
    
    collection.update_one(
        {"_id": query_id},
        {"$set": update_data}
    )
    
    # Return updated workout
    updated_workout = collection.find_one({"_id": query_id})
    
    return updated_workout


@router.delete("/{workout_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_workout(workout_id: str):
    """Delete a workout"""
    collection = get_workouts_collection()
    
    # Try to delete by ObjectId first
    deleted_count = 0
    if ObjectId.is_valid(workout_id):
        result = collection.delete_one({"_id": ObjectId(workout_id)})
        deleted_count = result.deleted_count
    
    # If not deleted by ObjectId, try as string
    if deleted_count == 0:
        result = collection.delete_one({"_id": workout_id})
        deleted_count = result.deleted_count
    
    if deleted_count == 0:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Workout not found"
        )
