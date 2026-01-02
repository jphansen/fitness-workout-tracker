from pymongo import MongoClient
from pymongo.errors import ConnectionFailure
import os
from dotenv import load_dotenv


load_dotenv()


class MongoDB:
    """MongoDB connection manager"""
    
    def __init__(self):
        # Use provided connection string or fallback to environment variable
        self.connection_string = os.getenv(
            "MONGODB_URI", 
            "mongodb://fitness:Juelsminde2025@172.32.0.3:27017"
        )
        self.database_name = os.getenv("MONGODB_DB", "fitness")
        self.client = None
        self.db = None
        
    def connect(self):
        """Establish connection to MongoDB"""
        try:
            self.client = MongoClient(self.connection_string)
            # Test the connection
            self.client.admin.command('ping')
            self.db = self.client[self.database_name]
            print(f"Connected to MongoDB database: {self.database_name}")
            return self.db
        except ConnectionFailure as e:
            print(f"Failed to connect to MongoDB: {e}")
            raise
            
    def get_database(self):
        """Get database instance"""
        if self.db is None:
            self.connect()
        return self.db
    
    def get_collection(self, collection_name):
        """Get a specific collection"""
        db = self.get_database()
        return db[collection_name]
    
    def close(self):
        """Close the MongoDB connection"""
        if self.client:
            self.client.close()
            print("MongoDB connection closed")


# Create a global instance
mongodb = MongoDB()


# Collections
def get_workouts_collection():
    return mongodb.get_collection("workouts")


def get_templates_collection():
    return mongodb.get_collection("templates")


def get_users_collection():
    return mongodb.get_collection("users")
