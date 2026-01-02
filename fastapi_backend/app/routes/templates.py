from typing import List
from fastapi import APIRouter, HTTPException, status, Depends
from bson import ObjectId

from app.database.mongodb import get_templates_collection
from app.models.template import (
    WorkoutTemplate, WorkoutTemplateCreate, WorkoutTemplateUpdate, WORKOUT_TEMPLATES
)
from app.auth.dependencies import get_current_user

router = APIRouter(prefix="/templates", tags=["templates"])


@router.get("/", response_model=List[WorkoutTemplate])
async def get_templates(current_user: dict = Depends(get_current_user)):
    """Get all workout templates for the current user"""
    collection = get_templates_collection()
    templates = list(collection.find({"user_id": current_user["_id"]}))
    return templates


@router.get("/{template_id}", response_model=WorkoutTemplate)
async def get_template(
    template_id: str,
    current_user: dict = Depends(get_current_user)
):
    """Get a specific template by ID (only if owned by user)"""
    collection = get_templates_collection()
    
    # Build query based on ID type
    query = {"user_id": current_user["_id"]}
    
    # Try to find by ObjectId first
    if ObjectId.is_valid(template_id):
        query["_id"] = ObjectId(template_id)
        template = collection.find_one(query)
        if template:
            return template
    
    # If not found by ObjectId, try as string
    query["_id"] = template_id
    template = collection.find_one(query)
    
    if not template:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Template not found or access denied"
        )
    
    return template


@router.get("/type/{workout_type}", response_model=List[WorkoutTemplate])
async def get_templates_by_type(
    workout_type: str,
    current_user: dict = Depends(get_current_user)
):
    """Get templates by workout type (A, B, C, D) for the current user"""
    collection = get_templates_collection()
    
    if workout_type.upper() not in ["A", "B", "C", "D"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Workout type must be A, B, C, or D"
        )
    
    templates = list(collection.find({
        "workout_type": workout_type.upper(),
        "user_id": current_user["_id"]
    }))
    return templates


@router.post("/", response_model=WorkoutTemplate, status_code=status.HTTP_201_CREATED)
async def create_template(
    template: WorkoutTemplateCreate,
    current_user: dict = Depends(get_current_user)
):
    """Create a new workout template for the current user"""
    collection = get_templates_collection()
    
    # Create WorkoutTemplate instance with user_id
    template_data = template.model_dump()
    template_data["user_id"] = current_user["_id"]
    template_in_db = WorkoutTemplate(**template_data)
    
    # Prepare document for insertion
    template_dict = template_in_db.model_dump(by_alias=True, exclude={"id"})
    template_dict["_id"] = template_in_db.id
    
    # Insert into database
    result = collection.insert_one(template_dict)
    
    # Retrieve the created template
    created_template = collection.find_one({"_id": result.inserted_id})
    
    return created_template


@router.put("/{template_id}", response_model=WorkoutTemplate)
async def update_template(
    template_id: str,
    template_update: WorkoutTemplateUpdate,
    current_user: dict = Depends(get_current_user)
):
    """Update an existing template (only if owned by user)"""
    collection = get_templates_collection()
    
    # Build query based on ID type
    query = {"user_id": current_user["_id"]}
    
    # Try to find by ObjectId first
    existing = None
    if ObjectId.is_valid(template_id):
        query["_id"] = ObjectId(template_id)
        existing = collection.find_one(query)
    
    # If not found by ObjectId, try as string
    if not existing:
        query["_id"] = template_id
        existing = collection.find_one(query)
    
    if not existing:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Template not found or access denied"
        )
    
    # Prepare update data
    update_data = template_update.model_dump(exclude_unset=True)
    
    # Determine the ID to use for update
    if ObjectId.is_valid(template_id) and isinstance(existing.get("_id"), ObjectId):
        query_id = ObjectId(template_id)
    else:
        query_id = template_id
    
    # Update the template
    collection.update_one(
        {"_id": query_id, "user_id": current_user["_id"]},
        {"$set": update_data}
    )
    
    # Return updated template
    updated_template = collection.find_one({"_id": query_id, "user_id": current_user["_id"]})
    
    return updated_template


@router.delete("/{template_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_template(
    template_id: str,
    current_user: dict = Depends(get_current_user)
):
    """Delete a template (only if owned by user)"""
    collection = get_templates_collection()
    
    # Build query based on ID type
    query = {"user_id": current_user["_id"]}
    
    # Try to delete by ObjectId first
    deleted_count = 0
    if ObjectId.is_valid(template_id):
        query["_id"] = ObjectId(template_id)
        result = collection.delete_one(query)
        deleted_count = result.deleted_count
    
    # If not deleted by ObjectId, try as string
    if deleted_count == 0:
        query["_id"] = template_id
        result = collection.delete_one(query)
        deleted_count = result.deleted_count
    
    if deleted_count == 0:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Template not found or access denied"
        )


@router.post("/seed", response_model=List[WorkoutTemplate])
async def seed_templates(current_user: dict = Depends(get_current_user)):
    """Seed the database with predefined templates for the current user"""
    collection = get_templates_collection()
    
    # Clear existing templates for this user
    collection.delete_many({"user_id": current_user["_id"]})
    
    # Insert predefined templates with user_id
    inserted_ids = []
    for template_data in WORKOUT_TEMPLATES:
        template_data_with_user = template_data.copy()
        template_data_with_user["user_id"] = current_user["_id"]
        template = WorkoutTemplate(**template_data_with_user)
        
        # Prepare document for insertion
        template_dict = template.model_dump(by_alias=True, exclude={"id"})
        template_dict["_id"] = template.id
        
        result = collection.insert_one(template_dict)
        inserted_ids.append(result.inserted_id)
    
    # Retrieve and return all seeded templates for this user
    seeded_templates = list(collection.find({
        "_id": {"$in": inserted_ids},
        "user_id": current_user["_id"]
    }))
    return seeded_templates
