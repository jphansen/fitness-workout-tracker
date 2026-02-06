import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/workout.dart';
import '../models/exercise.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'https://fitness.asvig.com';
  
  final http.Client client;
  final AuthService authService;

  ApiService({
    http.Client? client,
    AuthService? authService,
  }) : 
    client = client ?? http.Client(),
    authService = authService ?? AuthService();

  Future<Map<String, String>> _getHeaders() async {
    return await authService.getAuthHeaders();
  }

  Future<List<Workout>> getWorkouts() async {
    final headers = await _getHeaders();
    final response = await client.get(
      Uri.parse('$baseUrl/workouts/'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Workout.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load workouts: ${response.statusCode}');
    }
  }

  Future<Workout> getWorkout(String id) async {
    final headers = await _getHeaders();
    final response = await client.get(
      Uri.parse('$baseUrl/workouts/$id'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Workout.fromJson(data);
    } else {
      throw Exception('Failed to load workout: ${response.statusCode}');
    }
  }

  Future<Workout> createWorkout(Workout workout) async {
    final headers = await _getHeaders();
    final response = await client.post(
      Uri.parse('$baseUrl/workouts/'),
      headers: headers,
      body: json.encode(workout.toJson()),
    );
    
    if (response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Workout.fromJson(data);
    } else {
      throw Exception('Failed to create workout: ${response.statusCode}');
    }
  }

  Future<Workout> updateWorkout(String id, Workout workout) async {
    final headers = await _getHeaders();
    final response = await client.put(
      Uri.parse('$baseUrl/workouts/$id'),
      headers: headers,
      body: json.encode(workout.toJsonForUpdate()),
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Workout.fromJson(data);
    } else {
      throw Exception('Failed to update workout: ${response.statusCode}. URL: $baseUrl/workouts/$id');
    }
  }

  Future<void> deleteWorkout(String id) async {
    final headers = await _getHeaders();
    final response = await client.delete(
      Uri.parse('$baseUrl/workouts/$id'),
      headers: headers,
    );
    
    if (response.statusCode != 204) {
      throw Exception('Failed to delete workout: ${response.statusCode}');
    }
  }

  // Template methods removed - using Exercise Library instead

  // Exercise endpoints
  Future<List<Exercise>> getExercises({
    String? typeFilter,
    String? search,
    int skip = 0,
    int limit = 100,
  }) async {
    final headers = await _getHeaders();
    final params = <String, String>{};
    
    if (typeFilter != null && typeFilter.isNotEmpty) {
      params['type_filter'] = typeFilter;
    }
    if (search != null && search.isNotEmpty) {
      params['search'] = search;
    }
    params['skip'] = skip.toString();
    params['limit'] = limit.toString();
    
    final uri = Uri.parse('$baseUrl/exercises/').replace(queryParameters: params);
    final response = await client.get(uri, headers: headers);
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Exercise.fromJson(json)).toList();
    } else if (response.statusCode == 404) {
      // Exercise endpoint not available in current backend version
      // Return empty list instead of throwing error
      return [];
    } else {
      throw Exception('Failed to load exercises: ${response.statusCode}');
    }
  }

  Future<Exercise> getExercise(String id) async {
    final headers = await _getHeaders();
    final response = await client.get(
      Uri.parse('$baseUrl/exercises/$id'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Exercise.fromJson(data);
    } else if (response.statusCode == 404) {
      // Exercise endpoint not available, return empty exercise
      return Exercise.empty();
    } else {
      throw Exception('Failed to load exercise: ${response.statusCode}');
    }
  }

  Future<Exercise> createExercise(Exercise exercise) async {
    final headers = await _getHeaders();
    final response = await client.post(
      Uri.parse('$baseUrl/exercises/'),
      headers: headers,
      body: json.encode(exercise.toJson()),
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Exercise.fromJson(data);
    } else if (response.statusCode == 404) {
      // Exercise endpoint not available in current backend version
      // Return the exercise with a local ID to allow UI to continue
      return exercise.copyWith(id: 'local_${DateTime.now().millisecondsSinceEpoch}');
    } else {
      throw Exception('Failed to create exercise: ${response.statusCode}');
    }
  }

  Future<Exercise> updateExercise(String id, Exercise exercise) async {
    final headers = await _getHeaders();
    final response = await client.put(
      Uri.parse('$baseUrl/exercises/$id'),
      headers: headers,
      body: json.encode(exercise.toJson()),
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Exercise.fromJson(data);
    } else if (response.statusCode == 404) {
      // Exercise endpoint not available, return the exercise unchanged
      return exercise;
    } else {
      throw Exception('Failed to update exercise: ${response.statusCode}');
    }
  }

  Future<void> deleteExercise(String id) async {
    final headers = await _getHeaders();
    final response = await client.delete(
      Uri.parse('$baseUrl/exercises/$id'),
      headers: headers,
    );
    
    if (response.statusCode != 200 && response.statusCode != 404) {
      throw Exception('Failed to delete exercise: ${response.statusCode}');
    }
    // If 404, the exercise endpoint doesn't exist, so nothing to delete
  }

  Future<List<Exercise>> seedExercises() async {
    final headers = await _getHeaders();
    final response = await client.post(
      Uri.parse('$baseUrl/exercises/seed'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Exercise.fromJson(json)).toList();
    } else if (response.statusCode == 404) {
      // Exercise endpoint not available, return empty list
      return [];
    } else {
      throw Exception('Failed to seed exercises: ${response.statusCode}');
    }
  }

  Future<void> logExerciseUsage({
    required String exerciseId,
    double? weight,
    int? reps,
    int? sets,
    double? time,
    double? speed,
    double? distance,
    int? calories,
    int? rpe,
  }) async {
    final headers = await _getHeaders();
    final params = <String, String>{};
    
    if (weight != null) params['weight'] = weight.toString();
    if (reps != null) params['reps'] = reps.toString();
    if (sets != null) params['sets'] = sets.toString();
    if (time != null) params['time'] = time.toString();
    if (speed != null) params['speed'] = speed.toString();
    if (distance != null) params['distance'] = distance.toString();
    if (calories != null) params['calories'] = calories.toString();
    if (rpe != null) params['rpe'] = rpe.toString();
    
    final uri = Uri.parse('$baseUrl/exercises/$exerciseId/log').replace(queryParameters: params);
    final response = await client.post(uri, headers: headers);
    
    if (response.statusCode != 200 && response.statusCode != 404) {
      throw Exception('Failed to log exercise usage: ${response.statusCode}');
    }
    // If 404, the logging endpoint doesn't exist, which is OK for now
  }

  void dispose() {
    client.close();
    authService.dispose();
  }
}
