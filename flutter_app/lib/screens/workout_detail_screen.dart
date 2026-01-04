import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../models/exercise.dart';
import 'create_workout_screen.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final Workout workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    final totalVolume = workout.calculateTotalVolume();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Workout ${workout.dateOnly}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateWorkoutScreen(workoutToEdit: workout),
                ),
              );
            },
            tooltip: 'Edit workout',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share feature coming soon')),
              );
            },
            tooltip: 'Share workout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workout Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Chip(
                          backgroundColor: _getWorkoutTypeColor(workout.workoutType),
                          label: Text(
                            'Type ${workout.workoutType}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        Text(
                          workout.formattedDate,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (workout.notes != null && workout.notes!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Notes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            workout.notes!,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard(
                          'Exercises',
                          '${workout.exercises.length}',
                          Icons.fitness_center,
                        ),
                        _buildStatCard(
                          'Total Volume',
                          '${totalVolume.toStringAsFixed(1)} kg',
                          Icons.scale,
                        ),
                        _buildStatCard(
                          'Sets',
                          '${_calculateTotalSets(workout.exercises)}',
                          Icons.repeat,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Exercises Section
            const Text(
              'Exercises',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            if (workout.exercises.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(
                    child: Text(
                      'No exercises in this workout',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              )
            else
              ...workout.exercises.asMap().entries.map((entry) {
                final index = entry.key;
                final exercise = entry.value;
                return _buildExerciseCard(index + 1, exercise);
              }).toList(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(int number, Exercise exercise) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$number. ${exercise.name}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(
                    exercise.type == 'weight'
                        ? '${exercise.volume.toStringAsFixed(1)} kg'
                        : 'Score: ${exercise.volume.toStringAsFixed(1)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (exercise.type == 'weight')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildExerciseStat('Weight', '${exercise.weight ?? 0} kg', Icons.fitness_center),
                  _buildExerciseStat('Reps', '${exercise.reps ?? 0}', Icons.repeat),
                  _buildExerciseStat('Sets', '${exercise.sets ?? 0}', Icons.format_list_numbered),
                  _buildExerciseStat('RPE', '${exercise.rpe}/10', Icons.speed),
                ],
              )
            else if (exercise.type == 'cardio')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildExerciseStat('Time', '${exercise.time ?? 0} min', Icons.timer),
                  _buildExerciseStat('Speed', '${exercise.speed ?? 0} km/h', Icons.speed),
                  _buildExerciseStat('Distance', '${exercise.distance ?? 0} km', Icons.straighten),
                  _buildExerciseStat('RPE', '${exercise.rpe}/10', Icons.favorite),
                ],
              ),
            if (exercise.notes != null && exercise.notes!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    'Notes:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exercise.notes!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  int _calculateTotalSets(List<Exercise> exercises) {
    return exercises.fold(0, (sum, exercise) => sum + (exercise.sets ?? 0));
  }

  Color _getWorkoutTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'A':
        return Colors.blue;
      case 'B':
        return Colors.green;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
