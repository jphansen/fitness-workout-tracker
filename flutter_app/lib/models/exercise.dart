class Exercise {
  final String name;
  final double weight;
  final int reps;
  final int sets;
  final int rpe;
  final String? notes;

  Exercise({
    required this.name,
    this.weight = 10.0,
    this.reps = 15,
    this.sets = 3,
    this.rpe = 5,
    this.notes,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'] as String,
      weight: (json['weight'] as num).toDouble(),
      reps: json['reps'] as int,
      sets: json['sets'] as int,
      rpe: json['rpe'] as int,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'weight': weight,
      'reps': reps,
      'sets': sets,
      'rpe': rpe,
      'notes': notes,
    };
  }

  double get volume => weight * reps * sets;

  Exercise copyWith({
    String? name,
    double? weight,
    int? reps,
    int? sets,
    int? rpe,
    String? notes,
  }) {
    return Exercise(
      name: name ?? this.name,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      sets: sets ?? this.sets,
      rpe: rpe ?? this.rpe,
      notes: notes ?? this.notes,
    );
  }
}
