from typing import List
from fastapi import APIRouter, HTTPException, status
from bson import ObjectId

from app.database.mongodb import get_templates_collection
from app.models.template import WorkoutTemplate, WORKOUT_TEMPLATES

router = APIRouter(prefix="/templates", tags=["templates"])


@router.get("/", response_model=List[WorkoutTemplate])
def get_templates():
    """Get all workout templates"""
    collection = get_templates_collection()
    templates = list(collection.find())
    return templates


@router.get("/{template_id}", response_model=WorkoutTemplate)
def get_template(template_id: str):
    """Get a specific template by ID"""
    collection = get_templates_collection()
    
    # Try to find by ObjectId first (for new templates)
    if ObjectId.is_valid(template_id):
        template = collection.find_one({"_id": ObjectId(template_id)})
        if template:
            return template
    
    # If not found by ObjectId, try as string (for existing templates with string IDs)
    template = collection.find_one({"_id": template_id})
    
    if not template:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Template not found"
        )
    
    return template


@router.get("/type/{workout_type}", response_model=List[WorkoutTemplate])
def get_templates_by_type(workout_type: str):
    """Get templates by workout type (A, B, C, D)"""
    collection = get_templates_collection()
    
    if workout_type.upper() not in ["A", "B", "C", "D"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Workout type must be A, B, C, or D"
        )
    
    templates = list(collection.find({"workout_type": workout_type.upper()}))
    return templates


@router.post("/seed", response_model=List[WorkoutTemplate])
def seed_templates():
    """Seed the database with predefined templates"""
    collection = get_templates_collection()
    
    # Clear existing templates
    collection.delete_many({})
    
    # Insert predefined templates
    inserted_ids = []
    for template_data in WORKOUT_TEMPLATES:
        template = WorkoutTemplate(**template_data)
        # Prepare document for insertion - convert model to dict but keep ObjectId as ObjectId
        template_dict = template.model_dump(by_alias=True, exclude={"id"})
        # Add _id as ObjectId
        template_dict["_id"] = template.id
        result = collection.insert_one(template_dict)
        inserted_ids.append(result.inserted_id)
    
    # Retrieve and return all seeded templates
    seeded_templates = list(collection.find({"_id": {"$in": inserted_ids}}))
    return seeded_templates
