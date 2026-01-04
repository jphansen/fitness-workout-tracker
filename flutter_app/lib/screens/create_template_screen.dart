import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../models/workout_template.dart';
import '../models/exercise.dart';

class CreateTemplateScreen extends StatefulWidget {
  final WorkoutTemplate? templateToEdit;

  const CreateTemplateScreen({super.key, this.templateToEdit});

  @override
  State<CreateTemplateScreen> createState() => _CreateTemplateScreenState();
}

class _CreateTemplateScreenState extends State<CreateTemplateScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _workoutType;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<Exercise> _exercises = [];
  final List<String> _workoutTypes = ['A', 'B', 'C', 'D'];

  @override
  void initState() {
    super.initState();
    _workoutType = 'A';
    
    if (widget.templateToEdit != null) {
      _workoutType = widget.templateToEdit!.workoutType;
      _nameController.text = widget.templateToEdit!.name;
      _descriptionController.text = widget.templateToEdit!.description;
      _exercises.addAll(widget.templateToEdit!.exercises);
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
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
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

  Future<void> _saveTemplate() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<WorkoutProvider>(context, listen: false);
      
      final template = WorkoutTemplate(
        id: widget.templateToEdit?.id,
        workoutType: _workoutType,
        name: _nameController.text,
        description: _descriptionController.text,
        exercises: List.from(_exercises),
      );

      try {
        if (widget.templateToEdit != null && widget.templateToEdit!.id != null) {
          await provider.updateTemplate(widget.templateToEdit!.id!, template);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Template updated successfully')),
          );
        } else {
          await provider.createTemplate(template);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Template created successfully')),
          );
        }
        
        if (mounted) {
          Navigator.pop(context);
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
        title: Text(widget.templateToEdit != null ? 'Edit Template' : 'Create Template'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTemplate,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // Template Name and Type
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Template Details',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Template Name',
                          hintText: 'Enter template name...',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a template name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Description',
                          hintText: 'Enter template description...',
                        ),
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
                          labelText: 'Workout Type',
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

              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _saveTemplate,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  widget.templateToEdit != null ? 'Update Template' : 'Create Template',
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
}
