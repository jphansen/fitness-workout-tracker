# Fitness Workout Tracker

A full-stack workout tracking application with Flutter frontend and FastAPI backend.

## Features

- **Workout Logging**: Track workouts with date, type (A/B/C/D), exercises, weight, reps, sets, RPE, notes
- **Workout Templates**: Pre-defined templates for workout types A-D as specified in requirements
- **Total Volume Calculation**: Automatic calculation of total volume (weight × reps × sets)
- **Dark Theme**: Modern dark theme UI with Material Design
- **REST API**: FastAPI backend with MongoDB integration
- **State Management**: Provider pattern for efficient state management

## Project Structure

```
fitness/
├── flutter_app/          # Flutter frontend application
│   ├── lib/
│   │   ├── models/      # Data models (Workout, Exercise, Template)
│   │   ├── services/    # API service for backend communication
│   │   ├── providers/   # State management with Provider
│   │   ├── screens/     # UI screens (WorkoutListScreen)
│   │   └── widgets/     # Reusable UI components
│   ├── pubspec.yaml     # Flutter dependencies
│   └── ...
├── fastapi_backend/     # Python FastAPI backend
│   ├── app/
│   │   ├── main.py      # FastAPI application entry point
│   │   ├── database/    # MongoDB connection utilities
│   │   ├── models/      # Pydantic models for data validation
│   │   └── routes/      # API endpoints (workouts, templates)
│   ├── pyproject.toml   # Python dependencies (UV)
│   └── ...
└── app-foundation.txt   # Original requirements
```

## Workout Types (A-D)

### Type A: Full Body Strength + HIIT
- Warm-up: 5 min (rowing machine or cross-trainer)
- Strength training (30 min): Chest Press, Lat Pulldown, Shoulder Press, etc.
- HIIT Finisher: 5 min sprint/walk intervals

### Type B: Leg Day + Cardio
- Warm-up: 5 min cycling
- Leg exercises: Leg Press, Leg Curl, Leg Extension, Calf Raises, Glute Machine
- Steady Cardio: 10 min cross-trainer at 70% max effort

### Type C: Circuit Training
- Circuit format (3 rounds, minimal rest)
- Kettlebell Swings, Push-ups, Bodyweight Squats, Dumbbell Rows, Plank

### Type D: Cardio Variation
- Weekly cardio variations (treadmill, cycling, rowing, stair machine)
- Heart rate zone 2 (60-70% max)

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

### Workouts
- `GET /workouts/` - List all workouts
- `GET /workouts/{id}` - Get specific workout
- `POST /workouts/` - Create new workout
- `PUT /workouts/{id}` - Update workout
- `DELETE /workouts/{id}` - Delete workout

### Templates
- `GET /templates/` - List all workout templates
- `GET /templates/type/{type}` - Get templates by type (A, B, C, D)
- `POST /templates/seed` - Seed database with predefined templates

## Data Models

### Workout
```json
{
  "date": "2024-01-15T10:30:00",
  "workout_type": "C",
  "exercises": [
    {
      "name": "Kettlebell Swings: 45 sec / 15 sec rest",
      "weight": 10.0,
      "reps": 15,
      "sets": 3,
      "rpe": 5,
      "notes": "Focus on form"
    }
  ],
  "notes": "Circuit workout completed",
  "total_volume": 450.0
}
```

### Exercise
- Name: Exercise description
- Weight: Weight in kg (default: 10.0)
- Reps: Number of repetitions (default: 15)
- Sets: Number of sets (default: 3)
- RPE: Rate of perceived exertion 1-10 (default: 5)
- Notes: Additional notes

## Development Notes

- **Backend**: Uses FastAPI with Pydantic models for validation, PyMongo for MongoDB access
- **Frontend**: Uses Provider for state management, HTTP package for API calls
- **Database**: MongoDB with connection string: `mongodb://fitness:Juelsminde2025@172.32.0.3:27017`
- **Theme**: Dark theme with FlexColorScheme for consistent styling

## Next Steps (Future Enhancements)

1. **Complete CRUD Operations**: Add create, edit, and detail screens for workouts
2. **Template Selection**: Allow users to select from templates when creating workouts
3. **Statistics**: Add charts and statistics for workout progress
4. **Authentication**: Implement JWT authentication for user accounts
5. **Offline Support**: Add local storage for offline functionality
6. **Export Data**: Export workouts to CSV or PDF
7. **Notifications**: Reminders for workout schedules

## Requirements Met

- [x] Flutter app for workout tracking
- [x] Four workout types (A-D) with predefined templates
- [x] Workout parameters: Date, Type, Exercise, Weight, Reps, Sets, RPE, Notes, Total Volume
- [x] Date defaults to now() but editable
- [x] Default values for exercises (Weight: 10, Reps: 15, Sets: 3, RPE: 5)
- [x] FastAPI backend with MongoDB integration
- [x] Dark theme UI
- [x] MVP functionality with basic CRUD operations

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
git remote add origin https://github.com/YOUR_USERNAME/fitness-workout-tracker.git
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
git clone https://github.com/YOUR_USERNAME/fitness-workout-tracker.git
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

## Contributing
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License
This project is open source and available under the [MIT License](LICENSE).
