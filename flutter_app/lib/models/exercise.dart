class Exercise {
  final String name;
  final String type; // 'weight' or 'cardio' - never null
  
  // Weight training fields
  final double? weight;
  final int? reps;
  final int? sets;
  
  // Cardio fields
  final double? time;
  final double? speed;
  final double? distance;
  final int? calories;
  
  // Common fields
  final int rpe;
  final String? notes;

  Exercise({
    required this.name,
    this.type = 'weight',
    this.weight,
    this.reps,
    this.sets,
    this.time,
    this.speed,
    this.distance,
    this.calories,
    this.rpe = 5,
    this.notes,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return Exercise(
      name: json['name'] as String,
      type: (type == null || type.isEmpty) ? 'weight' : type,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      reps: json['reps'] as int?,
      sets: json['sets'] as int?,
      time: json['time'] != null ? (json['time'] as num).toDouble() : null,
      speed: json['speed'] != null ? (json['speed'] as num).toDouble() : null,
      distance: json['distance'] != null ? (json['distance'] as num).toDouble() : null,
      calories: json['calories'] as int?,
      rpe: json['rpe'] as int? ?? 5,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'name': name,
      'type': type,
      'rpe': rpe,
      if (notes != null) 'notes': notes,
    };
    
    if (type == 'weight') {
      if (weight != null) map['weight'] = weight;
      if (reps != null) map['reps'] = reps;
      if (sets != null) map['sets'] = sets;
    } else if (type == 'cardio') {
      if (time != null) map['time'] = time;
      if (speed != null) map['speed'] = speed;
      if (distance != null) map['distance'] = distance;
      if (calories != null) map['calories'] = calories;
    }
    
    return map;
  }

  double get volume {
    if (type == 'weight') {
      return (weight ?? 0) * (reps ?? 0) * (sets ?? 0);
    } else if (type == 'cardio') {
      return (time ?? 0) * (speed ?? 0) * rpe;
    }
    return 0.0;
  }

  Exercise copyWith({
    String? name,
    String? type,
    double? weight,
    int? reps,
    int? sets,
    double? time,
    double? speed,
    double? distance,
    int? calories,
    int? rpe,
    String? notes,
  }) {
    return Exercise(
      name: name ?? this.name,
      type: type ?? this.type,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      sets: sets ?? this.sets,
      time: time ?? this.time,
      speed: speed ?? this.speed,
      distance: distance ?? this.distance,
      calories: calories ?? this.calories,
      rpe: rpe ?? this.rpe,
      notes: notes ?? this.notes,
    );
  }
}
