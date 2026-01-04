# Exercise Type Migration

This migration adds support for two types of exercises: **weight** and **cardio**.

## What Changed

### Backend (Python/FastAPI)
- Updated `Exercise` model in `app/models/workout.py` to support both types
- Added `type` field (default: "weight")
- Weight exercises: weight, reps, sets, rpe, notes
- Cardio exercises: time, speed, distance, calories, rpe, notes
- Volume calculation: 
  - Weight: `weight × reps × sets`
  - Cardio: `time × speed × rpe`

### Frontend (Flutter/Dart)
- Updated `Exercise` model in `lib/models/exercise.dart`
- Updated `create_template_screen.dart` to show type-specific fields
- Updated `create_workout_screen.dart` to show type-specific fields
- Added dropdown to select exercise type (Weight/Cardio)

## Running the Migration

To update existing exercises in the database to have `type='weight'`:

```bash
cd fastapi_backend
python migrate_exercises.py
```

The script will:
1. Connect to your MongoDB database
2. Find all workouts and templates
3. Add `type='weight'` to exercises that don't have a type field
4. Display progress and summary

**Note:** This is a safe operation that only adds the missing field. Existing data is preserved.

## Testing

After migration:
1. Existing workouts should display correctly with weight fields
2. New workouts can use either weight or cardio type
3. Templates can contain mixed exercise types
4. UI dynamically shows relevant fields based on exercise type
