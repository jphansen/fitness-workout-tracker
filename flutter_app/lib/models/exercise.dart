class Exercise {
  final String id;
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
  
  // User and timestamps
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastUsed;
  
  // Default values for quick logging
  final double? defaultWeight;
  final int? defaultReps;
  final int? defaultSets;
  final double? defaultTime;
  final double? defaultSpeed;
  final double? defaultDistance;
  final int? defaultCalories;
  final int? defaultRpe;
  
  // Last used values (for smart defaults)
  final double? lastWeight;
  final int? lastReps;
  final int? lastSets;
  final double? lastTime;
  final double? lastSpeed;
  final double? lastDistance;
  final int? lastCalories;
  final int? lastRpe;

  Exercise({
    required this.name,
    this.id = '',
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
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.lastUsed,
    this.defaultWeight,
    this.defaultReps,
    this.defaultSets,
    this.defaultTime,
    this.defaultSpeed,
    this.defaultDistance,
    this.defaultCalories,
    this.defaultRpe,
    this.lastWeight,
    this.lastReps,
    this.lastSets,
    this.lastTime,
    this.lastSpeed,
    this.lastDistance,
    this.lastCalories,
    this.lastRpe,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    
    // Parse timestamps
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value).toLocal();
        } catch (e) {
          return null;
        }
      }
      return null;
    }
    
    // Parse ID (could be '_id' or 'id')
    String id = '';
    if (json['_id'] != null) {
      id = json['_id'].toString();
    } else if (json['id'] != null) {
      id = json['id'].toString();
    }
    
    return Exercise(
      id: id,
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
      userId: json['user_id']?.toString(),
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
      lastUsed: parseDateTime(json['last_used']),
      defaultWeight: json['default_weight'] != null ? (json['default_weight'] as num).toDouble() : null,
      defaultReps: json['default_reps'] as int?,
      defaultSets: json['default_sets'] as int?,
      defaultTime: json['default_time'] != null ? (json['default_time'] as num).toDouble() : null,
      defaultSpeed: json['default_speed'] != null ? (json['default_speed'] as num).toDouble() : null,
      defaultDistance: json['default_distance'] != null ? (json['default_distance'] as num).toDouble() : null,
      defaultCalories: json['default_calories'] as int?,
      defaultRpe: json['default_rpe'] as int?,
      lastWeight: json['last_weight'] != null ? (json['last_weight'] as num).toDouble() : null,
      lastReps: json['last_reps'] as int?,
      lastSets: json['last_sets'] as int?,
      lastTime: json['last_time'] != null ? (json['last_time'] as num).toDouble() : null,
      lastSpeed: json['last_speed'] != null ? (json['last_speed'] as num).toDouble() : null,
      lastDistance: json['last_distance'] != null ? (json['last_distance'] as num).toDouble() : null,
      lastCalories: json['last_calories'] as int?,
      lastRpe: json['last_rpe'] as int?,
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
    String? id,
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
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastUsed,
    double? defaultWeight,
    int? defaultReps,
    int? defaultSets,
    double? defaultTime,
    double? defaultSpeed,
    double? defaultDistance,
    int? defaultCalories,
    int? defaultRpe,
    double? lastWeight,
    int? lastReps,
    int? lastSets,
    double? lastTime,
    double? lastSpeed,
    double? lastDistance,
    int? lastCalories,
    int? lastRpe,
  }) {
    return Exercise(
      id: id ?? this.id,
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
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastUsed: lastUsed ?? this.lastUsed,
      defaultWeight: defaultWeight ?? this.defaultWeight,
      defaultReps: defaultReps ?? this.defaultReps,
      defaultSets: defaultSets ?? this.defaultSets,
      defaultTime: defaultTime ?? this.defaultTime,
      defaultSpeed: defaultSpeed ?? this.defaultSpeed,
      defaultDistance: defaultDistance ?? this.defaultDistance,
      defaultCalories: defaultCalories ?? this.defaultCalories,
      defaultRpe: defaultRpe ?? this.defaultRpe,
      lastWeight: lastWeight ?? this.lastWeight,
      lastReps: lastReps ?? this.lastReps,
      lastSets: lastSets ?? this.lastSets,
      lastTime: lastTime ?? this.lastTime,
      lastSpeed: lastSpeed ?? this.lastSpeed,
      lastDistance: lastDistance ?? this.lastDistance,
      lastCalories: lastCalories ?? this.lastCalories,
      lastRpe: lastRpe ?? this.lastRpe,
    );
  }

  static Exercise empty() {
    return Exercise(
      name: '',
      id: '',
      type: 'weight',
      rpe: 5,
    );
  }
}
