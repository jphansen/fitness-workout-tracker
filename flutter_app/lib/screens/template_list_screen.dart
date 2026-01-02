import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../models/workout_template.dart';

class TemplateListScreen extends StatelessWidget {
  const TemplateListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Templates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<WorkoutProvider>(context, listen: false).loadTemplates();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Implement template creation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Template creation coming soon')),
              );
            },
          ),
        ],
      ),
      body: Consumer<WorkoutProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.templates.isEmpty) {
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
                    onPressed: () {
                      provider.loadTemplates();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.templates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.folder_copy, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No templates yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Templates will help you create workouts faster',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Provider.of<WorkoutProvider>(context, listen: false)
                          .seedTemplates();
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Load Sample Templates'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.templates.length,
            itemBuilder: (context, index) {
              final template = provider.templates[index];
              return _buildTemplateCard(template, context);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Provider.of<WorkoutProvider>(context, listen: false).seedTemplates();
        },
        child: const Icon(Icons.download),
      ),
    );
  }

  Widget _buildTemplateCard(WorkoutTemplate template, BuildContext context) {
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
                Chip(
                  backgroundColor: _getWorkoutTypeColor(template.workoutType),
                  label: Text(
                    'Type ${template.workoutType}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Edit'),
                        onTap: () {
                          // TODO: Implement template editing
                          Future.delayed(Duration.zero, () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Template editing coming soon')),
                            );
                          });
                        },
                      ),
                      PopupMenuItem(
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        onTap: () {
                          Future.delayed(Duration.zero, () {
                            _showDeleteDialog(template, context);
                          });
                        },
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              template.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              template.description,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.fitness_center, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${template.exercises.length} exercises',
                  style: const TextStyle(fontSize: 14),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    _useTemplateToCreateWorkout(template, context);
                  },
                  child: const Text('USE TEMPLATE'),
                ),
              ],
            ),
            if (template.exercises.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    'Exercises:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...template.exercises.take(3).map((exercise) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• ${exercise.name}: ${exercise.sets}x${exercise.reps} @ ${exercise.weight}kg',
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                  if (template.exercises.length > 3)
                    Text(
                      '+ ${template.exercises.length - 3} more exercises',
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(WorkoutTemplate template, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Are you sure you want to delete the template "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await Provider.of<WorkoutProvider>(context, listen: false)
                    .deleteTemplate(template.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Template "${template.name}" deleted'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete template: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _useTemplateToCreateWorkout(WorkoutTemplate template, BuildContext context) {
    // Navigate to create workout screen with template data
    Navigator.pushNamed(
      context,
      '/create-workout',
      arguments: {
        'template': template,
      },
    ).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Created workout from template: ${template.name}'),
          backgroundColor: Colors.green,
        ),
      );
    });
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
