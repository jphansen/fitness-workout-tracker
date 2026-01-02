import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/workout.dart';
import '../models/workout_template.dart';

class ApiService {
  static const String baseUrl = 'https://fitness.asvig.com';
  
  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  Future<List<Workout>> getWorkouts() async {
    final response = await client.get(Uri.parse('$baseUrl/workouts/'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Workout.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load workouts: ${response.statusCode}');
    }
  }

  Future<Workout> getWorkout(String id) async {
    final response = await client.get(Uri.parse('$baseUrl/workouts/$id'));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Workout.fromJson(data);
    } else {
      throw Exception('Failed to load workout: ${response.statusCode}');
    }
  }

  Future<Workout> createWorkout(Workout workout) async {
    final response = await client.post(
      Uri.parse('$baseUrl/workouts/'),
      headers: {'Content-Type': 'application/json'},
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
    final response = await client.put(
      Uri.parse('$baseUrl/workouts/$id'),
      headers: {'Content-Type': 'application/json'},
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
    final response = await client.delete(Uri.parse('$baseUrl/workouts/$id'));
    
    if (response.statusCode != 204) {
      throw Exception('Failed to delete workout: ${response.statusCode}');
    }
  }

  Future<List<WorkoutTemplate>> getTemplates() async {
    final response = await client.get(Uri.parse('$baseUrl/templates/'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => WorkoutTemplate.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load templates: ${response.statusCode}');
    }
  }

  Future<List<WorkoutTemplate>> getTemplatesByType(String workoutType) async {
    final response = await client.get(
      Uri.parse('$baseUrl/templates/type/${workoutType.toUpperCase()}'),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => WorkoutTemplate.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load templates by type: ${response.statusCode}');
    }
  }

  Future<List<WorkoutTemplate>> seedTemplates() async {
    final response = await client.post(
      Uri.parse('$baseUrl/templates/seed'),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => WorkoutTemplate.fromJson(json)).toList();
    } else {
      throw Exception('Failed to seed templates: ${response.statusCode}');
    }
  }

  void dispose() {
    client.close();
  }
}
