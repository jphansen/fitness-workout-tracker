from typing import List
from fastapi import APIRouter, HTTPException, status, Depends
from bson import ObjectId

from app.database.mongodb import get_workouts_collection
from app.models.workout import (
    WorkoutCreate, WorkoutUpdate, WorkoutResponse, WorkoutInDB, Exercise
)
from app.auth.dependencies import get_current_user

router = APIRouter(prefix="/workouts", tags=["workouts"])


@router.get("/", response_model=List[WorkoutResponse])
async def get_workouts(current_user: dict = Depends(get_current_user)):
    """Get all workouts for the current user"""
    collection = get_workouts_collection()
    workouts = list(collection.find({"user_id": current_user["_id"]}).limit(100))
    return workouts


@router.get("/{workout_id}", response_model=WorkoutResponse)
async def get_workout(
    workout_id: str,
    current_user: dict = Depends(get_current_user)
):
    """Get a specific workout by ID (only if owned by user)"""
    collection = get_workouts_collection()
    
    # Build query based on ID type
    query = {"user_id": current_user["_id"]}
    
    # Try to find by ObjectId first
    if ObjectId.is_valid(workout_id):
        query["_id"] = ObjectId(workout_id)
        workout = collection.find_one(query)
        if workout:
            return workout
    
    # If not found by ObjectId, try as string
    query["_id"] = workout_id
    workout = collection.find_one(query)
    
    if not workout:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Workout not found or access denied"
        )
    
    return workout


@router.post("/", response_model=WorkoutResponse, status_code=status.HTTP_201_CREATED)
async def create_workout(
    workout: WorkoutCreate,
    current_user: dict = Depends(get_current_user)
):
    """Create a new workout for the current user"""
    collection = get_workouts_collection()
    
    # Create WorkoutInDB instance with user_id
    workout_data = workout.model_dump()
    workout_data["user_id"] = current_user["_id"]
    workout_in_db = WorkoutInDB(**workout_data)
    
    # Calculate total volume
    workout_in_db.total_volume = workout_in_db.calculate_total_volume()
    
    # Prepare document for insertion
    workout_dict = workout_in_db.model_dump(by_alias=True, exclude={"id"})
    workout_dict["_id"] = workout_in_db.id
    
    # Insert into database
    result = collection.insert_one(workout_dict)
    
    # Retrieve the created workout
    created_workout = collection.find_one({"_id": result.inserted_id})
    
    return created_workout


@router.put("/{workout_id}", response_model=WorkoutResponse)
async def update_workout(
    workout_id: str,
    workout_update: WorkoutUpdate,
    current_user: dict = Depends(get_current_user)
):
    """Update an existing workout (only if owned by user)"""
    collection = get_workouts_collection()
    
    # Build query based on ID type
    query = {"user_id": current_user["_id"]}
    
    # Try to find by ObjectId first
    existing = None
    if ObjectId.is_valid(workout_id):
        query["_id"] = ObjectId(workout_id)
        existing = collection.find_one(query)
    
    # If not found by ObjectId, try as string
    if not existing:
        query["_id"] = workout_id
        existing = collection.find_one(query)
    
    if not existing:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Workout not found or access denied"
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
    
    # Determine the ID to use for update
    if ObjectId.is_valid(workout_id) and isinstance(existing.get("_id"), ObjectId):
        query_id = ObjectId(workout_id)
    else:
        query_id = workout_id
    
    # Update the workout
    collection.update_one(
        {"_id": query_id, "user_id": current_user["_id"]},
        {"$set": update_data}
    )
    
    # Return updated workout
    updated_workout = collection.find_one({"_id": query_id, "user_id": current_user["_id"]})
    
    return updated_workout


@router.delete("/{workout_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_workout(
    workout_id: str,
    current_user: dict = Depends(get_current_user)
):
    """Delete a workout (only if owned by user)"""
    collection = get_workouts_collection()
    
    # Build query based on ID type
    query = {"user_id": current_user["_id"]}
    
    # Try to delete by ObjectId first
    deleted_count = 0
    if ObjectId.is_valid(workout_id):
        query["_id"] = ObjectId(workout_id)
        result = collection.delete_one(query)
        deleted_count = result.deleted_count
    
    # If not deleted by ObjectId, try as string
    if deleted_count == 0:
        query["_id"] = workout_id
        result = collection.delete_one(query)
        deleted_count = result.deleted_count
    
    if deleted_count == 0:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Workout not found or access denied"
        )
