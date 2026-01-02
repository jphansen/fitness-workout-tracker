import 'package:intl/intl.dart';
import 'exercise.dart';

class Workout {
  final String? id;
  final DateTime date;
  final String workoutType;
  final List<Exercise> exercises;
  final String? notes;
  final double totalVolume;

  Workout({
    this.id,
    required this.date,
    required this.workoutType,
    required this.exercises,
    this.notes,
    this.totalVolume = 0.0,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['_id'] as String?,
      date: DateTime.parse(json['date'] as String),
      workoutType: json['workout_type'] as String,
      exercises: (json['exercises'] as List)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
      totalVolume: (json['total_volume'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'date': date.toIso8601String(),
      'workout_type': workoutType,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'notes': notes,
      'total_volume': totalVolume,
    };
  }

  Map<String, dynamic> toJsonForUpdate() {
    return {
      'date': date.toIso8601String(),
      'workout_type': workoutType,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'notes': notes,
      'total_volume': totalVolume,
    };
  }

  String get formattedDate {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  String get dateOnly {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  double calculateTotalVolume() {
    return exercises.fold(0.0, (sum, exercise) => sum + exercise.volume);
  }

  Workout copyWith({
    String? id,
    DateTime? date,
    String? workoutType,
    List<Exercise>? exercises,
    String? notes,
    double? totalVolume,
  }) {
    return Workout(
      id: id ?? this.id,
      date: date ?? this.date,
      workoutType: workoutType ?? this.workoutType,
      exercises: exercises ?? this.exercises,
      notes: notes ?? this.notes,
      totalVolume: totalVolume ?? this.totalVolume,
    );
  }

  Workout withCalculatedVolume() {
    return copyWith(totalVolume: calculateTotalVolume());
  }
}
