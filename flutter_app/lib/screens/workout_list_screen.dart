import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../models/workout.dart';

class WorkoutListScreen extends StatefulWidget {
  const WorkoutListScreen({super.key});

  @override
  State<WorkoutListScreen> createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends State<WorkoutListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = Provider.of<WorkoutProvider>(context, listen: false);
    await provider.loadWorkouts();
    await provider.loadTemplates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to create workout screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Create workout feature coming soon!'),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<WorkoutProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.workouts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.workouts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.fitness_center, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No workouts yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start by creating your first workout',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to create workout screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Create workout feature coming soon!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Workout'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.workouts.length,
            itemBuilder: (context, index) {
              final workout = provider.workouts[index];
              return _buildWorkoutCard(workout, provider);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to create workout screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Create workout feature coming soon!'),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWorkoutCard(Workout workout, WorkoutProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getWorkoutTypeColor(workout.workoutType),
          child: Text(
            workout.workoutType,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(workout.formattedDate),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${workout.exercises.length} exercises'),
            Text('Total Volume: ${workout.totalVolume.toStringAsFixed(1)} kg'),
            if (workout.notes != null && workout.notes!.isNotEmpty)
              Text(
                'Notes: ${workout.notes!}',
                style: const TextStyle(fontStyle: FontStyle.italic),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            _showDeleteDialog(workout, provider);
          },
        ),
        onTap: () {
          // TODO: Navigate to workout detail screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Viewing workout ${workout.id}'),
            ),
          );
        },
      ),
    );
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

  void _showDeleteDialog(Workout workout, WorkoutProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout'),
        content: Text('Are you sure you want to delete the workout from ${workout.formattedDate}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (workout.id != null) {
                await provider.deleteWorkout(workout.id!);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
