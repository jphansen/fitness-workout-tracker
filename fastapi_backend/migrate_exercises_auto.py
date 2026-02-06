#!/usr/bin/env python3
"""
Migration script to add 'type' field to existing exercises in workouts.
Sets all existing exercises to type='weight' with their existing fields.
"""
import os
import sys
from pymongo import MongoClient
from dotenv import load_dotenv

load_dotenv()


def migrate_exercises():
    """Migrate all exercises in workouts to have type='weight'"""
    
    # Connect to MongoDB
    connection_string = os.getenv(
        "MONGODB_URI", 
        "mongodb://fitness:Juelsminde2025@172.32.0.3:27017"
    )
    database_name = os.getenv("MONGODB_DB", "fitness")
    
    try:
        client = MongoClient(connection_string)
        client.admin.command('ping')
        db = client[database_name]
        print(f"✓ Connected to MongoDB database: {database_name}")
    except Exception as e:
        print(f"✗ Failed to connect to MongoDB: {e}")
        sys.exit(1)
    
    # Get collections
    workouts_collection = db["workouts"]
    
    # Migrate workouts
    print("\n=== Migrating Workouts ===")
    workouts_updated = 0
    workouts = workouts_collection.find({})
    
    for workout in workouts:
        if "exercises" in workout:
            exercises_modified = False
            for exercise in workout["exercises"]:
                if "type" not in exercise:
                    exercise["type"] = "weight"
                    exercises_modified = True
            
            if exercises_modified:
                workouts_collection.update_one(
                    {"_id": workout["_id"]},
                    {"$set": {"exercises": workout["exercises"]}}
                )
                workouts_updated += 1
                print(f"  Updated workout {workout['_id']} - {len(workout['exercises'])} exercises")
    
    print(f"\n✓ Migrated {workouts_updated} workouts")
    
    # Summary
    print("\n=== Migration Summary ===")
    print(f"Total workouts updated: {workouts_updated}")
    print("\n✓ Migration completed successfully!")
    
    client.close()


if __name__ == "__main__":
    print("Exercise Type Migration Script")
    print("=" * 50)
    print("This script will add type='weight' to all existing exercises")
    print("in workouts that don't have a type field.")
    print()
    
    # Auto-proceed without asking for input
    print("Auto-proceeding with migration...")
    migrate_exercises()