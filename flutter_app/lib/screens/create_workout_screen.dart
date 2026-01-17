import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../models/workout.dart';
import '../models/exercise.dart';

class CreateWorkoutScreen extends StatefulWidget {
  final Workout? workoutToEdit;

  const CreateWorkoutScreen({super.key, this.workoutToEdit});

  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late String _workoutType;
  final TextEditingController _notesController = TextEditingController();
  final List<Exercise> _exercises = [];
  final List<String> _workoutTypes = ['A', 'B', 'C', 'D'];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _workoutType = 'A';
    
    if (widget.workoutToEdit != null) {
      _selectedDate = widget.workoutToEdit!.date;
      _workoutType = widget.workoutToEdit!.workoutType;
      _notesController.text = widget.workoutToEdit!.notes ?? '';
      _exercises.addAll(widget.workoutToEdit!.exercises);
    } else {
      // Add a default exercise
      _exercises.add(Exercise(
        name: 'Bench Press',
        type: 'weight',
        weight: 10.0,
        reps: 15,
        sets: 3,
      ));
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _addExercise() {
    setState(() {
      _exercises.add(Exercise(
        name: 'New Exercise',
        type: 'weight',
        weight: 10.0,
        reps: 15,
        sets: 3,
      ));
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }

  void _updateExercise(int index, Exercise exercise) {
    setState(() {
      _exercises[index] = exercise;
    });
  }

  // Template methods removed - use Exercise Library instead

  Future<void> _browseExercises() async {
    // Navigate to Exercise Library for browsing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Use the Exercise Library from the menu to manage exercises'),
        duration: Duration(seconds: 2),
      ),
    );
    
    /* Future enhancement: Add exercise selection from Exercise Library
    if (mounted) {
      final selectedExercise = await showDialog<Exercise>(
        context: context,
        builder: (context) => _ExerciseBrowserDialog(
          exercises: [], // Load from Exercise Library API
        ),
      );
      
      if (selectedExercise != null) {
        setState(() {
          // Add the exercise as a template - user will customize the values
          _exercises.add(selectedExercise.copyWith());
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${selectedExercise.name}. Customize the values below.'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
    */
  }

  Future<void> _saveWorkout() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<WorkoutProvider>(context, listen: false);
      
      final workout = Workout(
        id: widget.workoutToEdit?.id,
        date: _selectedDate,
        workoutType: _workoutType,
        exercises: List.from(_exercises),
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      ).withCalculatedVolume();

      try {
        if (widget.workoutToEdit != null && widget.workoutToEdit!.id != null) {
          try {
            await provider.updateWorkout(widget.workoutToEdit!.id!, workout);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Workout updated successfully')),
            );
            if (mounted) {
              Navigator.pop(context);
            }
          } catch (updateError) {
            // If update fails, offer to create a new copy instead
            if (mounted) {
              final shouldCreateCopy = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Update Failed'),
                  content: const Text(
                    'Could not update the existing workout. Would you like to save as a new workout instead?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Save as New'),
                    ),
                  ],
                ),
              );
              
              if (shouldCreateCopy == true) {
                // Create a new workout instead (without the ID)
                final newWorkout = workout.copyWith(id: null);
                await provider.createWorkout(newWorkout);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Workout saved as new copy')),
                );
                if (mounted) {
                  Navigator.pop(context);
                }
              }
            }
          }
        } else {
          await provider.createWorkout(workout);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Workout created successfully')),
          );
          if (mounted) {
            Navigator.pop(context);
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workoutToEdit != null ? 'Edit Workout' : 'Create Workout'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveWorkout,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // Date and Time Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date & Time',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.calendar_today),
                              label: Text(
                                '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                              ),
                              onPressed: () => _selectDate(context),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.access_time),
                              label: Text(
                                '${_selectedDate.hour.toString().padLeft(2, '0')}:${_selectedDate.minute.toString().padLeft(2, '0')}',
                              ),
                              onPressed: () => _selectTime(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Workout Type Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Workout Type',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _workoutType,
                        items: _workoutTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text('Type $type'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _workoutType = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Select workout type',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Exercises
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Exercises',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: _browseExercises,
                                tooltip: 'Browse Exercises',
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: _addExercise,
                                tooltip: 'Add New Exercise',
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_exercises.isEmpty)
                        Center(
                          child: Column(
                            children: [
                              const Text(
                                'No exercises added',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _browseExercises,
                                    icon: const Icon(Icons.search),
                                    label: const Text('Browse Exercises'),
                                  ),
                                  const SizedBox(width: 12),
                                  OutlinedButton.icon(
                                    onPressed: _addExercise,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Create New'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      else
                        ..._exercises.asMap().entries.map((entry) {
                          final index = entry.key;
                          final exercise = entry.value;
                          return _buildExerciseCard(index, exercise);
                        }).toList(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Notes
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notes',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Additional notes (optional)',
                          hintText: 'Enter any notes about this workout...',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _saveWorkout,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  widget.workoutToEdit != null ? 'Update Workout' : 'Create Workout',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseCard(int index, Exercise exercise) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.drag_handle, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: exercise.name,
                    decoration: InputDecoration(
                      labelText: 'Exercise ${index + 1}',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.info_outline, size: 18),
                        onPressed: () {
                          _showExerciseTips(context, index, exercise);
                        },
                        tooltip: 'Exercise tips',
                      ),
                    ),
                    onChanged: (value) {
                      _updateExercise(index, exercise.copyWith(name: value));
                    },
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: exercise.type,
                  items: const [
                    DropdownMenuItem(value: 'weight', child: Text('Weight')),
                    DropdownMenuItem(value: 'cardio', child: Text('Cardio')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      _updateExercise(index, exercise.copyWith(type: value));
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeExercise(index),
                  tooltip: 'Delete exercise',
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (exercise.type == 'weight') ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: exercise.weight?.toStringAsFixed(1) ?? '10.0',
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        final weight = double.tryParse(value) ?? 10.0;
                        _updateExercise(index, exercise.copyWith(weight: weight));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: exercise.reps?.toString() ?? '15',
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Reps',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        final reps = int.tryParse(value) ?? 15;
                        _updateExercise(index, exercise.copyWith(reps: reps));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: exercise.sets?.toString() ?? '3',
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Sets',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        final sets = int.tryParse(value) ?? 3;
                        _updateExercise(index, exercise.copyWith(sets: sets));
                      },
                    ),
                  ),
                ],
              ),
            ] else if (exercise.type == 'cardio') ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: exercise.time?.toStringAsFixed(1) ?? '30.0',
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Time (min)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        final time = double.tryParse(value) ?? 30.0;
                        _updateExercise(index, exercise.copyWith(time: time));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: exercise.speed?.toStringAsFixed(1) ?? '10.0',
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Speed (km/h)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        final speed = double.tryParse(value) ?? 10.0;
                        _updateExercise(index, exercise.copyWith(speed: speed));
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: exercise.distance?.toStringAsFixed(1) ?? '5.0',
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Distance (km)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        final distance = double.tryParse(value) ?? 5.0;
                        _updateExercise(index, exercise.copyWith(distance: distance));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: exercise.calories?.toString() ?? '300',
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Calories',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        final calories = int.tryParse(value) ?? 300;
                        _updateExercise(index, exercise.copyWith(calories: calories));
                      },
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: exercise.rpe.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'RPE (1-10)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final rpe = int.tryParse(value) ?? exercise.rpe;
                      _updateExercise(index, exercise.copyWith(rpe: rpe.clamp(1, 10)));
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: exercise.notes ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _updateExercise(index, exercise.copyWith(notes: value.isEmpty ? null : value));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  exercise.type == 'weight'
                      ? 'Volume: ${exercise.volume.toStringAsFixed(1)} kg'
                      : 'Score: ${exercise.volume.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  exercise.type == 'weight'
                      ? 'Total: ${exercise.sets}x${exercise.reps} @ ${exercise.weight}kg'
                      : '${exercise.time}min @ ${exercise.speed}km/h',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showExerciseTips(BuildContext context, int index, Exercise exercise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exercise Tips'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You can edit any field in real-time:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• Name: Exercise name'),
            const Text('• Weight: In kilograms (kg)'),
            const Text('• Reps: Number of repetitions'),
            const Text('• Sets: Number of sets'),
            const Text('• RPE: Rate of Perceived Exertion (1-10)'),
            const Text('• Notes: Additional comments'),
            const SizedBox(height: 16),
            Text(
              'Current exercise: ${exercise.name}',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            Text(
              'Volume: ${exercise.volume.toStringAsFixed(1)} kg',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Exercise Browser Dialog Widget
class _ExerciseBrowserDialog extends StatefulWidget {
  final List<Exercise> exercises;

  const _ExerciseBrowserDialog({required this.exercises});

  @override
  State<_ExerciseBrowserDialog> createState() => _ExerciseBrowserDialogState();
}

class _ExerciseBrowserDialogState extends State<_ExerciseBrowserDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterType = 'all'; // 'all', 'weight', 'cardio'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Exercise> get _filteredExercises {
    return widget.exercises.where((exercise) {
      final matchesSearch = exercise.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType = _filterType == 'all' || exercise.type == _filterType;
      return matchesSearch && matchesType;
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Widget build(BuildContext context) {
    final filteredExercises = _filteredExercises;

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Browse Exercises',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Search field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
                    label: const Text('All'),
                    selected: _filterType == 'all',
                    onSelected: (selected) {
                      setState(() {
                        _filterType = 'all';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Weight Training'),
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
                    label: const Text('Cardio'),
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
            const SizedBox(height: 12),
            
            // Results count
            Text(
              '${filteredExercises.length} exercise${filteredExercises.length != 1 ? 's' : ''} found',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
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
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No exercises found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search or filters',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
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
                                  ? '${exercise.sets ?? 0} sets × ${exercise.reps ?? 0} reps @ ${exercise.weight ?? 0}kg'
                                  : '${exercise.time ?? 0} min @ ${exercise.speed ?? 0} km/h',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: const Icon(Icons.add_circle_outline),
                            onTap: () {
                              Navigator.pop(context, exercise);
                            },
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            
            // Info text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.blue[300]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tap an exercise to add it to your workout. You can customize the values after adding.',
                      style: TextStyle(fontSize: 12, color: Colors.blue[300]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
