from datetime import datetime
from app.database.mongodb import get_users_collection

def fix_existing_user():
    """Fix existing user by adding missing fields"""
    users_collection = get_users_collection()
    
    # Find the existing testuser
    user = users_collection.find_one({"username": "testuser"})
    
    if user:
        print(f"Found user: {user['username']}")
        print(f"Current fields: {list(user.keys())}")
        
        # Update missing fields
        update_data = {}
        
        if "created_at" not in user or user["created_at"] is None:
            update_data["created_at"] = datetime.utcnow()
            print("Adding created_at field")
        
        if "updated_at" not in user or user["updated_at"] is None:
            update_data["updated_at"] = datetime.utcnow()
            print("Adding updated_at field")
        
        if "is_active" not in user:
            update_data["is_active"] = True
            print("Adding is_active field")
        
        if update_data:
            result = users_collection.update_one(
                {"_id": user["_id"]},
                {"$set": update_data}
            )
            print(f"Updated user: {result.modified_count} document(s) modified")
        else:
            print("User already has all required fields")
        
        # Show updated user
        updated_user = users_collection.find_one({"_id": user["_id"]})
        print(f"\nUpdated user fields: {list(updated_user.keys())}")
        print(f"created_at: {updated_user.get('created_at')}")
        print(f"updated_at: {updated_user.get('updated_at')}")
        print(f"is_active: {updated_user.get('is_active')}")
    else:
        print("User 'testuser' not found")

if __name__ == "__main__":
    fix_existing_user()
