import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../models/exercise.dart';
import '../models/workout.dart';

class ExerciseListScreen extends StatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterType = 'all'; // 'all', 'weight', 'cardio'
  List<Exercise> _allExercises = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExercises();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    // TODO: Load exercises from Exercise Library API endpoint
    // For now, show exercises from recent workouts
    final provider = Provider.of<WorkoutProvider>(context, listen: false);
    
    await provider.loadWorkouts();
    
    // Extract all unique exercises from workouts
    final Map<String, Exercise> uniqueExercises = {};
    for (var workout in provider.workouts) {
      for (var exercise in workout.exercises) {
        // Ensure exercise has a type (handle legacy data)
        final exerciseWithType = Exercise(
          name: exercise.name,
          type: exercise.type.isEmpty ? 'weight' : exercise.type,
          weight: exercise.weight,
          reps: exercise.reps,
          sets: exercise.sets,
          time: exercise.time,
          speed: exercise.speed,
          distance: exercise.distance,
          calories: exercise.calories,
          rpe: exercise.rpe,
          notes: exercise.notes,
        );
        
        // Use name + type as key to avoid duplicates
        final key = '${exerciseWithType.name}_${exerciseWithType.type}';
        if (!uniqueExercises.containsKey(key)) {
          uniqueExercises[key] = exerciseWithType;
        }
      }
    }
    
    setState(() {
      _allExercises = uniqueExercises.values.toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  List<Exercise> get _filteredExercises {
    return _allExercises.where((exercise) {
      final matchesSearch = exercise.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType = _filterType == 'all' || exercise.type == _filterType;
      return matchesSearch && matchesType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredExercises = _filteredExercises;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadExercises,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filters
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search exercises...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: Text('All (${_allExercises.length})'),
                        selected: _filterType == 'all',
                        onSelected: (selected) {
                          setState(() {
                            _filterType = 'all';
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: Text('Weight (${_allExercises.where((e) => e.type == 'weight').length})'),
                        avatar: const Icon(Icons.fitness_center, size: 18),
                        selected: _filterType == 'weight',
                        onSelected: (selected) {
                          setState(() {
                            _filterType = 'weight';
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: Text('Cardio (${_allExercises.where((e) => e.type == 'cardio').length})'),
                        avatar: const Icon(Icons.directions_run, size: 18),
                        selected: _filterType == 'cardio',
                        onSelected: (selected) {
                          setState(() {
                            _filterType = 'cardio';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredExercises.length} exercise${filteredExercises.length != 1 ? 's' : ''} found',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Exercise list
          Expanded(
            child: filteredExercises.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _allExercises.isEmpty ? Icons.fitness_center : Icons.search_off,
                          size: 64,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _allExercises.isEmpty
                              ? 'No exercises available'
                              : 'No exercises found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _allExercises.isEmpty
                              ? 'Create some templates with exercises first'
                              : 'Try adjusting your search or filters',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = filteredExercises[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: exercise.type == 'weight'
                                ? Colors.blue
                                : Colors.green,
                            child: Icon(
                              exercise.type == 'weight'
                                  ? Icons.fitness_center
                                  : Icons.directions_run,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            exercise.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            exercise.type == 'weight'
                                ? 'Weight Training: ${exercise.sets ?? 0} sets × ${exercise.reps ?? 0} reps @ ${exercise.weight ?? 0}kg'
                                : 'Cardio: ${exercise.time ?? 0} min @ ${exercise.speed ?? 0} km/h',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.info_outline),
                                onPressed: () {
                                  _showExerciseDetails(context, exercise);
                                },
                                tooltip: 'View details',
                              ),
                              Icon(
                                Icons.add_circle,
                                color: Colors.green[400],
                              ),
                            ],
                          ),
                          onTap: () {
                            _logExercise(context, exercise);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _logExercise(BuildContext context, Exercise templateExercise) async {
    final result = await showDialog<Exercise>(
      context: context,
      builder: (context) => _LogExerciseDialog(exercise: templateExercise),
    );
    
    if (result != null) {
      await _saveExerciseToTodayWorkout(result);
    }
  }

  Future<void> _saveExerciseToTodayWorkout(Exercise exercise) async {
    print('DEBUG: Saving exercise to today - name: ${exercise.name}, type: ${exercise.type}');
    final provider = Provider.of<WorkoutProvider>(context, listen: false);
    
    try {
      // Load existing workouts to check if there's already a workout for today
      await provider.loadWorkouts();
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Find if there's already a workout for today
      final existingWorkout = provider.workouts.firstWhere(
        (w) {
          final workoutDate = DateTime(w.date.year, w.date.month, w.date.day);
          return workoutDate.isAtSameMomentAs(today);
        },
        orElse: () => null as dynamic,
      );
      
      print('DEBUG: Existing workout found: ${existingWorkout != null}');
      
      if (existingWorkout != null && existingWorkout is Workout) {
        // Add to existing workout
        print('DEBUG: Adding to existing workout with ${existingWorkout.exercises.length} exercises');
        final updatedExercises = List<Exercise>.from(existingWorkout.exercises)..add(exercise);
        print('DEBUG: Updated exercises count: ${updatedExercises.length}');
        final updatedWorkout = existingWorkout.copyWith(exercises: updatedExercises).withCalculatedVolume();
        print('DEBUG: About to update workout...');
        
        await provider.updateWorkout(existingWorkout.id!, updatedWorkout);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${exercise.name} added to today\'s workout'),
              action: SnackBarAction(
                label: 'View',
                onPressed: () {
                  Navigator.pop(context); // Go back to workout list
                },
              ),
            ),
          );
        }
      } else {
        // Create new workout for today
        print('DEBUG: Creating new workout with exercise: ${exercise.name}');
        final newWorkout = Workout(
          date: DateTime.now(),
          workoutType: 'Daily', // Default type
          exercises: [exercise],
          notes: 'Quick log',
        ).withCalculatedVolume();
        
        print('DEBUG: New workout exercises count: ${newWorkout.exercises.length}');
        print('DEBUG: About to create workout...');
        await provider.createWorkout(newWorkout);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Created today\'s workout with ${exercise.name}'),
              action: SnackBarAction(
                label: 'View',
                onPressed: () {
                  Navigator.pop(context); // Go back to workout list
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('DEBUG: Error in _saveExerciseToTodayWorkout: $e');
      print('DEBUG: Error stack trace: ${StackTrace.current}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving exercise: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showExerciseDetails(BuildContext context, Exercise exercise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              exercise.type == 'weight' ? Icons.fitness_center : Icons.directions_run,
              color: exercise.type == 'weight' ? Colors.blue : Colors.green,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(exercise.name),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Type', exercise.type == 'weight' ? 'Weight Training' : 'Cardio'),
              const Divider(),
              if (exercise.type == 'weight') ...[
                _buildDetailRow('Sets', '${exercise.sets ?? 0}'),
                _buildDetailRow('Reps', '${exercise.reps ?? 0}'),
                _buildDetailRow('Weight', '${exercise.weight ?? 0} kg'),
                _buildDetailRow('Total Volume', '${exercise.volume.toStringAsFixed(1)} kg'),
              ] else ...[
                _buildDetailRow('Time', '${exercise.time ?? 0} min'),
                _buildDetailRow('Speed', '${exercise.speed ?? 0} km/h'),
                _buildDetailRow('Distance', '${exercise.distance ?? 0} km'),
                _buildDetailRow('Calories', '${exercise.calories ?? 0}'),
              ],
              const Divider(),
              _buildDetailRow('RPE', '${exercise.rpe}/10'),
              if (exercise.notes != null && exercise.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Notes:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(exercise.notes!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Log Exercise Dialog
class _LogExerciseDialog extends StatefulWidget {
  final Exercise exercise;

  const _LogExerciseDialog({required this.exercise});

  @override
  State<_LogExerciseDialog> createState() => _LogExerciseDialogState();
}

class _LogExerciseDialogState extends State<_LogExerciseDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _weightController;
  late TextEditingController _repsController;
  late TextEditingController _setsController;
  late TextEditingController _timeController;
  late TextEditingController _speedController;
  late TextEditingController _distanceController;
  late TextEditingController _caloriesController;
  late TextEditingController _notesController;
  int _rpe = 5;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: widget.exercise.weight?.toString() ?? '10.0');
    _repsController = TextEditingController(text: widget.exercise.reps?.toString() ?? '15');
    _setsController = TextEditingController(text: widget.exercise.sets?.toString() ?? '3');
    _timeController = TextEditingController(text: widget.exercise.time?.toString() ?? '30.0');
    _speedController = TextEditingController(text: widget.exercise.speed?.toString() ?? '10.0');
    _distanceController = TextEditingController(text: widget.exercise.distance?.toString() ?? '5.0');
    _caloriesController = TextEditingController(text: widget.exercise.calories?.toString() ?? '300');
    _notesController = TextEditingController();
    _rpe = widget.exercise.rpe;
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _setsController.dispose();
    _timeController.dispose();
    _speedController.dispose();
    _distanceController.dispose();
    _caloriesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            widget.exercise.type == 'weight' ? Icons.fitness_center : Icons.directions_run,
            color: widget.exercise.type == 'weight' ? Colors.blue : Colors.green,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.exercise.name),
                Text(
                  'Log Exercise',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.exercise.type == 'weight') ...[
                TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter weight';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _repsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Reps',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _setsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Sets',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ] else ...[
                TextFormField(
                  controller: _timeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Time (minutes)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter time';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _speedController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Speed (km/h)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter speed';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _distanceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Distance (km)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _caloriesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Calories',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('RPE (Rate of Perceived Exertion): $_rpe/10'),
                  Slider(
                    value: _rpe.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: _rpe.toString(),
                    onChanged: (value) {
                      setState(() {
                        _rpe = value.round();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                  hintText: 'Add any notes...',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.check),
          label: const Text('Log Exercise'),
        ),
      ],
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      try {
        final Exercise exercise;
        if (widget.exercise.type == 'weight') {
          exercise = Exercise(
            name: widget.exercise.name,
            type: 'weight',
            weight: double.tryParse(_weightController.text),
            reps: int.tryParse(_repsController.text),
            sets: int.tryParse(_setsController.text),
            rpe: _rpe,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
          );
        } else {
          exercise = Exercise(
            name: widget.exercise.name,
            type: 'cardio',
            time: double.tryParse(_timeController.text),
            speed: double.tryParse(_speedController.text),
            distance: double.tryParse(_distanceController.text),
            calories: int.tryParse(_caloriesController.text),
            rpe: _rpe,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
          );
        }
        
        print('DEBUG: Created exercise - name: ${exercise.name}, type: ${exercise.type}');
        Navigator.pop(context, exercise);
      } catch (e) {
        print('DEBUG: Error creating exercise: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating exercise: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
