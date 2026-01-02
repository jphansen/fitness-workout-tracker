import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../models/workout.dart';
import '../models/exercise.dart';
import '../models/workout_template.dart';

class CreateWorkoutScreen extends StatefulWidget {
  final Workout? workoutToEdit;
  final WorkoutTemplate? template;

  const CreateWorkoutScreen({super.key, this.workoutToEdit, this.template});

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
    } else if (widget.template != null) {
      // Use template data
      _workoutType = widget.template!.workoutType;
      _exercises.addAll(widget.template!.exercises);
      _notesController.text = widget.template!.description;
    } else {
      // Add a default exercise
      _exercises.add(Exercise(name: 'Bench Press'));
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
      _exercises.add(Exercise(name: 'New Exercise'));
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

  Future<void> _loadTemplates() async {
    final provider = Provider.of<WorkoutProvider>(context, listen: false);
    final templates = await provider.getTemplatesByType(_workoutType);
    
    if (templates.isNotEmpty && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Template'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                return ListTile(
                  title: Text(template.name),
                  subtitle: Text(template.description),
                  trailing: Text('${template.exercises.length} exercises'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _exercises.clear();
                      _exercises.addAll(template.exercises);
                    });
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No templates found for this workout type'),
        ),
      );
    }
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
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.folder_copy),
                        label: const Text('Load from Template'),
                        onPressed: _loadTemplates,
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
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _addExercise,
                            tooltip: 'Add Exercise',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_exercises.isEmpty)
                        const Center(
                          child: Text(
                            'No exercises added',
                            style: TextStyle(color: Colors.grey),
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
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeExercise(index),
                  tooltip: 'Delete exercise',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: exercise.weight.toStringAsFixed(1),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.fitness_center, size: 18),
                    ),
                    onChanged: (value) {
                      final weight = double.tryParse(value) ?? exercise.weight;
                      _updateExercise(index, exercise.copyWith(weight: weight));
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: exercise.reps.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Reps',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.repeat, size: 18),
                    ),
                    onChanged: (value) {
                      final reps = int.tryParse(value) ?? exercise.reps;
                      _updateExercise(index, exercise.copyWith(reps: reps));
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: exercise.sets.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Sets',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.format_list_numbered, size: 18),
                    ),
                    onChanged: (value) {
                      final sets = int.tryParse(value) ?? exercise.sets;
                      _updateExercise(index, exercise.copyWith(sets: sets));
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: exercise.rpe.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'RPE (1-10)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.speed, size: 18),
                    ),
                    onChanged: (value) {
                      final rpe = int.tryParse(value) ?? exercise.rpe;
                      _updateExercise(index, exercise.copyWith(rpe: rpe.clamp(1, 10)));
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
                    initialValue: exercise.notes ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note, size: 18),
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
                  'Volume: ${exercise.volume.toStringAsFixed(1)} kg',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  'Total: ${exercise.sets}x${exercise.reps} @ ${exercise.weight}kg',
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
