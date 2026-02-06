from datetime import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from bson import ObjectId

from app.database.mongodb import get_exercises_collection
from app.models.exercise import Exercise, ExerciseCreate, ExerciseUpdate, PREDEFINED_EXERCISES
from app.auth.dependencies import get_current_user

router = APIRouter(prefix="/exercises", tags=["exercises"])


@router.get("/", response_model=List[Exercise])
async def get_exercises(
    current_user: dict = Depends(get_current_user),
    type_filter: Optional[str] = Query(None, pattern="^(weight|cardio|all)$"),
    search: Optional[str] = None,
    skip: int = 0,
    limit: int = 100
):
    """
    Get exercises for the current user.
    
    - **type_filter**: Filter by exercise type (weight, cardio, or all)
    - **search**: Search by exercise name
    - **skip**: Number of exercises to skip (for pagination)
    - **limit**: Maximum number of exercises to return
    """
    collection = get_exercises_collection()
    
    # Build query
    query = {"user_id": current_user["_id"]}
    
    if type_filter and type_filter != "all":
        query["type"] = type_filter
    
    if search:
        query["name"] = {"$regex": search, "$options": "i"}
    
    # Get exercises
    cursor = collection.find(query).skip(skip).limit(limit).sort("name", 1)
    exercises = list(cursor)
    
    # Convert ObjectId to string for response
    for exercise in exercises:
        exercise["_id"] = str(exercise["_id"])
        if "user_id" in exercise and exercise["user_id"]:
            exercise["user_id"] = str(exercise["user_id"])
    
    return exercises


@router.get("/{exercise_id}", response_model=Exercise)
async def get_exercise(
    exercise_id: str,
    current_user: dict = Depends(get_current_user)
):
    """
    Get a specific exercise by ID.
    """
    collection = get_exercises_collection()
    
    try:
        exercise = collection.find_one({
            "_id": ObjectId(exercise_id),
            "user_id": current_user["_id"]
        })
    except:
        exercise = None
    
    if not exercise:
        raise HTTPException(status_code=404, detail="Exercise not found")
    
    exercise["_id"] = str(exercise["_id"])
    if "user_id" in exercise and exercise["user_id"]:
        exercise["user_id"] = str(exercise["user_id"])
    
    return exercise


@router.post("/", response_model=Exercise)
async def create_exercise(
    exercise: ExerciseCreate,
    current_user: dict = Depends(get_current_user)
):
    """
    Create a new exercise.
    """
    collection = get_exercises_collection()
    
    # Check if exercise with same name already exists for this user
    existing = collection.find_one({
        "name": exercise.name,
        "user_id": current_user["_id"]
    })
    
    if existing:
        raise HTTPException(
            status_code=400,
            detail=f"Exercise with name '{exercise.name}' already exists"
        )
    
    # Prepare exercise data
    exercise_data = exercise.dict(exclude_unset=True)
    exercise_data["user_id"] = current_user["_id"]
    exercise_data["created_at"] = datetime.utcnow()
    exercise_data["updated_at"] = datetime.utcnow()
    
    # Insert exercise
    result = collection.insert_one(exercise_data)
    
    # Get the created exercise
    created_exercise = collection.find_one({"_id": result.inserted_id})
    created_exercise["_id"] = str(created_exercise["_id"])
    created_exercise["user_id"] = str(created_exercise["user_id"])
    
    return created_exercise


@router.put("/{exercise_id}", response_model=Exercise)
async def update_exercise(
    exercise_id: str,
    exercise_update: ExerciseUpdate,
    current_user: dict = Depends(get_current_user)
):
    """
    Update an existing exercise.
    """
    collection = get_exercises_collection()
    
    # Check if exercise exists and belongs to user
    try:
        existing = collection.find_one({
            "_id": ObjectId(exercise_id),
            "user_id": current_user["_id"]
        })
    except:
        existing = None
    
    if not existing:
        raise HTTPException(status_code=404, detail="Exercise not found")
    
    # Check if name change would cause conflict
    if exercise_update.name and exercise_update.name != existing.get("name"):
        name_conflict = collection.find_one({
            "name": exercise_update.name,
            "user_id": current_user["_id"],
            "_id": {"$ne": ObjectId(exercise_id)}
        })
        
        if name_conflict:
            raise HTTPException(
                status_code=400,
                detail=f"Exercise with name '{exercise_update.name}' already exists"
            )
    
    # Prepare update data
    update_data = exercise_update.dict(exclude_unset=True)
    update_data["updated_at"] = datetime.utcnow()
    
    # Update exercise
    collection.update_one(
        {"_id": ObjectId(exercise_id)},
        {"$set": update_data}
    )
    
    # Get updated exercise
    updated_exercise = collection.find_one({"_id": ObjectId(exercise_id)})
    updated_exercise["_id"] = str(updated_exercise["_id"])
    updated_exercise["user_id"] = str(updated_exercise["user_id"])
    
    return updated_exercise


@router.delete("/{exercise_id}")
async def delete_exercise(
    exercise_id: str,
    current_user: dict = Depends(get_current_user)
):
    """
    Delete an exercise.
    """
    collection = get_exercises_collection()
    
    # Check if exercise exists and belongs to user
    try:
        existing = collection.find_one({
            "_id": ObjectId(exercise_id),
            "user_id": current_user["_id"]
        })
    except:
        existing = None
    
    if not existing:
        raise HTTPException(status_code=404, detail="Exercise not found")
    
    # Delete exercise
    result = collection.delete_one({"_id": ObjectId(exercise_id)})
    
    if result.deleted_count == 1:
        return {"message": "Exercise deleted successfully"}
    else:
        raise HTTPException(status_code=500, detail="Failed to delete exercise")


@router.post("/seed", response_model=List[Exercise])
async def seed_exercises(
    current_user: dict = Depends(get_current_user)
):
    """
    Seed predefined exercises for the current user.
    """
    collection = get_exercises_collection()
    
    # Check if user already has exercises
    user_exercise_count = collection.count_documents({"user_id": current_user["_id"]})
    
    if user_exercise_count > 0:
        raise HTTPException(
            status_code=400,
            detail="User already has exercises. Seeding only allowed for empty exercise library."
        )
    
    # Create predefined exercises for the user
    seeded_exercises = []
    now = datetime.utcnow()
    
    for predefined in PREDEFINED_EXERCISES:
        exercise_data = predefined.copy()
        exercise_data["user_id"] = current_user["_id"]
        exercise_data["created_at"] = now
        exercise_data["updated_at"] = now
        
        # Insert exercise
        result = collection.insert_one(exercise_data)
        
        # Get the created exercise
        created_exercise = collection.find_one({"_id": result.inserted_id})
        created_exercise["_id"] = str(created_exercise["_id"])
        created_exercise["user_id"] = str(created_exercise["user_id"])
        seeded_exercises.append(created_exercise)
    
    return seeded_exercises


@router.post("/{exercise_id}/log")
async def log_exercise_usage(
    exercise_id: str,
    weight: Optional[float] = None,
    reps: Optional[int] = None,
    sets: Optional[int] = None,
    time: Optional[float] = None,
    speed: Optional[float] = None,
    distance: Optional[float] = None,
    calories: Optional[int] = None,
    rpe: Optional[int] = None,
    current_user: dict = Depends(get_current_user)
):
    """
    Update an exercise's last used values when it's logged in a workout.
    This helps provide smart defaults for future logging.
    """
    collection = get_exercises_collection()
    
    # Check if exercise exists and belongs to user
    try:
        existing = collection.find_one({
            "_id": ObjectId(exercise_id),
            "user_id": current_user["_id"]
        })
    except:
        existing = None
    
    if not existing:
        raise HTTPException(status_code=404, detail="Exercise not found")
    
    # Prepare update data for last used values
    update_data = {
        "last_used": datetime.utcnow(),
        "updated_at": datetime.utcnow()
    }
    
    # Update last used values based on exercise type
    if existing.get("type") == "weight":
        if weight is not None:
            update_data["last_weight"] = weight
        if reps is not None:
            update_data["last_reps"] = reps
        if sets is not None:
            update_data["last_sets"] = sets
        if rpe is not None:
            update_data["last_rpe"] = rpe
    else:  # cardio
        if time is not None:
            update_data["last_time"] = time
        if speed is not None:
            update_data["last_speed"] = speed
        if distance is not None:
            update_data["last_distance"] = distance
        if calories is not None:
            update_data["last_calories"] = calories
        if rpe is not None:
            update_data["last_rpe"] = rpe
    
    # Update exercise
    collection.update_one(
        {"_id": ObjectId(exercise_id)},
        {"$set": update_data}
    )
    
    return {"message": "Exercise usage logged successfully"}
