from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

from app.routes import workouts, templates, auth
from app.database.mongodb import mongodb

# Create FastAPI app
app = FastAPI(
    title="Fitness Workout Tracker API",
    description="API for tracking workout sessions with templates A-D",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for development
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router)
app.include_router(workouts.router)
app.include_router(templates.router)


@app.on_event("startup")
def startup_db_client():
    """Initialize MongoDB connection on startup"""
    mongodb.connect()
    print("FastAPI application started")


@app.on_event("shutdown")
def shutdown_db_client():
    """Close MongoDB connection on shutdown"""
    mongodb.close()
    print("FastAPI application shutting down")


@app.get("/")
def read_root():
    """Root endpoint"""
    return {
        "message": "Fitness Workout Tracker API",
        "version": "1.0.0",
        "docs": "/docs",
        "endpoints": {
            "workouts": "/workouts",
            "templates": "/templates"
        }
    }


@app.get("/health")
def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "service": "fitness-tracker-api"}


if __name__ == "__main__":
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8888,
        reload=True
    )
