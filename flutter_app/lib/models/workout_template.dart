import 'exercise.dart';

class WorkoutTemplate {
  final String? id;
  final String workoutType;
  final String name;
  final String description;
  final List<Exercise> exercises;

  WorkoutTemplate({
    this.id,
    required this.workoutType,
    required this.name,
    required this.description,
    required this.exercises,
  });

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json) {
    return WorkoutTemplate(
      id: json['_id'] as String?,
      workoutType: json['workout_type'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      exercises: (json['exercises'] as List)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'workout_type': workoutType,
      'name': name,
      'description': description,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }

  WorkoutTemplate copyWith({
    String? id,
    String? workoutType,
    String? name,
    String? description,
    List<Exercise>? exercises,
  }) {
    return WorkoutTemplate(
      id: id ?? this.id,
      workoutType: workoutType ?? this.workoutType,
      name: name ?? this.name,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
    );
  }
}
