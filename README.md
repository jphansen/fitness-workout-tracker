# Fitness Workout Tracker

A full-stack workout tracking application with Flutter frontend and FastAPI backend.

## Features

- **Workout Logging**: Track daily workouts with exercises, customizable parameters
- **Exercise Library**: Browse and log exercises from your workout history
- **Exercise Types**: Support for weight training (weight/reps/sets) and cardio (time/speed/distance/calories)
- **Workout Types**: Daily, Morning, Evening, or Custom workout classifications
- **Total Volume Calculation**: Automatic calculation of total volume/score based on exercise type
- **Dark Theme**: Modern dark theme UI with Material Design
- **REST API**: FastAPI backend with MongoDB integration
- **State Management**: Provider pattern for efficient state management
- **Authentication**: JWT-based user authentication

## Project Structure

```
fitness-workout-tracker/
├── flutter_app/          # Flutter frontend application
│   ├── lib/
│   │   ├── models/      # Data models (Workout, Exercise, User)
│   │   ├── services/    # API and auth services
│   │   ├── providers/   # State management with Provider
│   │   └── screens/     # UI screens (WorkoutList, ExerciseLibrary, CreateWorkout)
│   ├── pubspec.yaml     # Flutter dependencies
│   └── ...
├── fastapi_backend/     # Python FastAPI backend
│   ├── app/
│   │   ├── main.py      # FastAPI application entry point
│   │   ├── database/    # MongoDB connection utilities
│   │   ├── models/      # Pydantic models for data validation
│   │   ├── routes/      # API endpoints (workouts, auth)
│   │   └── auth/        # JWT authentication handlers
│   ├── pyproject.toml   # Python dependencies (UV)
│   ├── migrate_exercises.py  # Migration script for exercise type field
│   └── ...
└── app-foundation.txt   # Original requirements
```

## Architecture

### Simplified Workflow
1. **Exercise Library**: Browse exercises from workout history
2. **Log Exercise**: Select exercise, adjust parameters, log to today's workout
3. **View Workouts**: See workout history with total volume/score calculations

### Exercise Types

#### Weight Training
- **Fields**: weight (kg), reps, sets, RPE (1-10), notes
- **Volume Calculation**: weight × reps × sets
- **Examples**: Bench Press, Squats, Deadlifts

#### Cardio
- **Fields**: time (minutes), speed (km/h), distance (km), calories, RPE (1-10), notes
- **Score Calculation**: time × speed × RPE
- **Examples**: Running, Cycling, Rowing

### Workout Types
- **Daily**: Standard daily workout log (default)
- **Morning**: Morning session workouts
- **Evening**: Evening session workouts
- **Custom**: User-defined workout classifications

## Setup Instructions

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd fastapi_backend
   ```

2. Install dependencies using UV:
   ```bash
   uv sync
   ```

3. Start the FastAPI server:
   ```bash
   uv run uvicorn app.main:app --host 0.0.0.0 --port 8888 --reload
   ```

4. The API will be available at `http://localhost:8888`
   - API Documentation: `http://localhost:8888/docs`
   - Health Check: `http://localhost:8888/health`

### Frontend Setup

1. Navigate to the Flutter app directory:
   ```bash
   cd flutter_app
   ```

2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Run the Flutter app:
   ```bash
   flutter run
   ```

4. Ensure the backend is running before starting the Flutter app.

## API Endpoints

### Authentication
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login and get JWT token

### Workouts
- `GET /workouts/` - List all workouts for authenticated user
- `GET /workouts/{id}` - Get specific workout
- `POST /workouts/` - Create new workout
- `PUT /workouts/{id}` - Update workout
- `DELETE /workouts/{id}` - Delete workout

## Data Models

### Workout
```json
{
  "date": "2026-01-18T10:30:00",
  "workout_type": "Daily",
  "exercises": [
    {
      "name": "Bench Press",
      "type": "weight",
      "weight": 80.0,
      "reps": 10,
      "sets": 3,
      "rpe": 7,
      "notes": "Good form"
    },
    {
      "name": "Running",
      "type": "cardio",
      "time": 30.0,
      "speed": 12.0,
      "distance": 6.0,
      "calories": 350,
      "rpe": 6
    }
  ],
  "notes": "Great workout",
  "total_volume": 2400.0
}
```

### Exercise (Weight Training)
- **name**: Exercise description (required)
- **type**: "weight" (required)
- **weight**: Weight in kg (optional)
- **reps**: Number of repetitions (optional)
- **sets**: Number of sets (optional)
- **rpe**: Rate of perceived exertion 1-10 (default: 5)
- **notes**: Additional notes (optional)

### Exercise (Cardio)
- **name**: Exercise description (required)
- **type**: "cardio" (required)
- **time**: Duration in minutes (optional)
- **speed**: Speed in km/h (optional)
- **distance**: Distance in km (optional)
- **calories**: Calories burned (optional)
- **rpe**: Rate of perceived exertion 1-10 (default: 5)
- **notes**: Additional notes (optional)

## Development Notes

- **Backend**: FastAPI with Pydantic v2 models, PyMongo for MongoDB, JWT authentication
- **Frontend**: Flutter with Provider state management, HTTP package for API calls
- **Database**: MongoDB (connection configured via environment variables)
- **Theme**: Dark theme with FlexColorScheme for consistent styling
- **Package Manager**: UV for Python dependencies

## Database Migration

If upgrading from an older version, run the migration script to add the `type` field to existing exercises:

```bash
cd fastapi_backend
uv run python migrate_exercises.py
```

This will set all existing exercises to `type='weight'` by default.

## Recent Updates

- ✅ Removed template system, simplified to Exercise Library → Workouts workflow
- ✅ Added exercise type support (weight/cardio) with conditional fields
- ✅ Fixed null type errors in exercise logging
- ✅ Changed workout types from A/B/C/D to Daily/Morning/Evening/Custom
- ✅ Made workout_type optional with "Daily" as default
- ✅ Improved exercise library with filtering and search
- ✅ Fixed UI issues with overlapping icons in input fields

## Next Steps (Future Enhancements)

1. **Exercise Management**: CRUD operations for custom exercises
2. **Statistics & Charts**: Progress tracking with visualizations
3. **Workout Programs**: Pre-built training programs
4. **Export Data**: Export workouts to CSV or PDF
5. **Notifications**: Reminders for workout schedules
6. **Social Features**: Share workouts with friends
7. **Offline Support**: Local storage for offline functionality

## Requirements Met

- [x] Flutter app for workout tracking
- [x] Exercise Library for browsing and selecting exercises
- [x] Multiple exercise types (weight training and cardio)
- [x] Workout types: Daily, Morning, Evening, Custom
- [x] Exercise parameters: Weight, Reps, Sets, Time, Speed, Distance, Calories, RPE, Notes
- [x] Automatic volume/score calculation
- [x] Date defaults to now() but editable
- [x] FastAPI backend with MongoDB integration
- [x] JWT authentication
- [x] Dark theme UI
- [x] Complete CRUD operations for workouts

## GitHub Repository Setup

To push this project to GitHub and share it with others:

### 1. Initialize Git Repository
```bash
cd /home/jph/SRC/fitness
git init
```

### 2. Create .gitignore File
Create a `.gitignore` file in the root directory with the following content:
```
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# Virtual Environments
.venv/
venv/
env/
ENV/
env.bak/
venv.bak/

# Flutter/Dart
.dart_tool/
.packages
.pub-cache/
.pub/
build/
.flutter-plugins
.flutter-plugins-dependencies
.fvm/
*.iml
*.lock
*.log
*.swp

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# MongoDB
*.ns
*.0
*.1
*.2
*.3
*.4
*.5
*.6
*.7
*.8
*.9
*.log
*.lock
*.tmp
*.pid
mongod.log
```

### 3. Add Files and Commit
```bash
git add .
git commit -m "Initial commit: Fitness Workout Tracker with Flutter frontend and FastAPI backend"
```

### 4. Create GitHub Repository
1. Go to [GitHub](https://github.com) and create a new repository (e.g., `fitness-workout-tracker`)
2. Do NOT initialize with README, .gitignore, or license (since we already have them)

### 5. Connect Local Repository to GitHub
```bash
git remote add origin https://github.com/jphansen/fitness-workout-tracker.git
git branch -M main
git push -u origin main
```

### 6. Environment Variables (For Production)
For security, create a `.env` file in the `fastapi_backend` directory:
```bash
MONGODB_URI=mongodb://fitness:Juelsminde2025@172.32.0.3:27017
DATABASE_NAME=fitness
```

Add `.env` to `.gitignore` to keep credentials secure.

### 7. Clone the Repository (For Other Developers)
```bash
git clone https://github.com/jphansen/fitness-workout-tracker.git
cd fitness-workout-tracker
```

### 8. Project Structure for Git
The repository will maintain the following structure:
```
fitness-workout-tracker/
├── flutter_app/          # Flutter frontend
├── fastapi_backend/      # FastAPI backend
├── README.md            # This documentation
├── .gitignore           # Git ignore rules
└── app-foundation.txt   # Original requirements
```

## Deployment Options

### Backend Deployment (FastAPI)
- **Render**: Easy deployment with Python support
- **Railway**: Simple deployment with MongoDB integration
- **Heroku**: Traditional PaaS with add-ons
- **Docker**: Containerize for any cloud provider

### Frontend Deployment (Flutter)
- **Web**: Build for web deployment
- **Android**: Generate APK for Google Play Store
- **iOS**: Build for App Store (requires macOS)
- **Desktop**: Build for Windows, macOS, Linux

### Database (MongoDB)
- **MongoDB Atlas**: Cloud-hosted MongoDB (free tier available)
- **Self-hosted**: Use the provided connection string for local development

## Repository Status
✅ **Successfully pushed to GitHub**: [https://github.com/jphansen/fitness-workout-tracker](https://github.com/jphansen/fitness-workout-tracker)

The repository contains the complete fitness workout tracker application with:
- Full Flutter frontend implementation
- Complete FastAPI backend with MongoDB integration
- Comprehensive documentation
- MIT License
- Proper .gitignore configuration

## Contributing
1. Fork the repository at [https://github.com/jphansen/fitness-workout-tracker](https://github.com/jphansen/fitness-workout-tracker)
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License
This project is open source and available under the [MIT License](LICENSE).
