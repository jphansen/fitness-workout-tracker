import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise.dart';
import '../services/api_service.dart';
import '../services/auth_exception.dart';

class ExerciseProvider with ChangeNotifier {
  final ApiService _apiService;
  SharedPreferences? _prefs;
  
  List<Exercise> _exercises = [];
  bool _isLoading = false;
  String? _error;
  bool _backendAvailable = true; // Assume backend is available until proven otherwise

  ExerciseProvider({required ApiService apiService}) : _apiService = apiService {
    _initLocalStorage();
  }

  List<Exercise> get exercises => _exercises;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filter exercises by type
  List<Exercise> getWeightExercises() {
    return _exercises.where((exercise) => exercise.type == 'weight').toList();
  }

  List<Exercise> getCardioExercises() {
    return _exercises.where((exercise) => exercise.type == 'cardio').toList();
  }

  Future<void> loadExercises({
    String? typeFilter,
    String? search,
  }) async {
    _setLoading(true);
    _error = null;
    
    try {
      _exercises = await _apiService.getExercises(
        typeFilter: typeFilter,
        search: search,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      
      // Don't rethrow authentication errors - they're handled by AuthService
      if (e is! AuthenticationException) {
        rethrow;
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<Exercise> createExercise(Exercise exercise) async {
    _setLoading(true);
    _error = null;
    
    try {
      final createdExercise = await _apiService.createExercise(exercise);
      _exercises.add(createdExercise);
      notifyListeners();
      return createdExercise;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      
      // Don't rethrow authentication errors - they're handled by AuthService
      if (e is! AuthenticationException) {
        rethrow;
      }
      return exercise; // Return the original exercise if auth fails
    } finally {
      _setLoading(false);
    }
  }

  Future<Exercise> updateExercise(String id, Exercise exercise) async {
    _setLoading(true);
    _error = null;
    
    try {
      final updatedExercise = await _apiService.updateExercise(id, exercise);
      final index = _exercises.indexWhere((e) => e.id == id);
      if (index != -1) {
        _exercises[index] = updatedExercise;
      }
      notifyListeners();
      return updatedExercise;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      
      // Don't rethrow authentication errors - they're handled by AuthService
      if (e is! AuthenticationException) {
        rethrow;
      }
      return exercise; // Return the original exercise if auth fails
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteExercise(String id) async {
    _setLoading(true);
    _error = null;
    
    try {
      await _apiService.deleteExercise(id);
      _exercises.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      
      // Don't rethrow authentication errors - they're handled by AuthService
      if (e is! AuthenticationException) {
        rethrow;
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<List<Exercise>> seedExercises() async {
    _setLoading(true);
    _error = null;
    
    try {
      final seededExercises = await _apiService.seedExercises();
      _exercises.addAll(seededExercises);
      notifyListeners();
      return seededExercises;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      
      // Don't rethrow authentication errors - they're handled by AuthService
      if (e is! AuthenticationException) {
        rethrow;
      }
      return []; // Return empty list if auth fails
    } finally {
      _setLoading(false);
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
    try {
      await _apiService.logExerciseUsage(
        exerciseId: exerciseId,
        weight: weight,
        reps: reps,
        sets: sets,
        time: time,
        speed: speed,
        distance: distance,
        calories: calories,
        rpe: rpe,
      );
      
      // Update the exercise in our local list with last used values
      final index = _exercises.indexWhere((e) => e.id == exerciseId);
      if (index != -1) {
        final exercise = _exercises[index];
        final now = DateTime.now().toUtc();
        
        // Create updated exercise with new last used values
        final updatedExercise = exercise.copyWith(
          lastUsed: now,
          lastWeight: exercise.type == 'weight' ? weight : exercise.lastWeight,
          lastReps: exercise.type == 'weight' ? reps : exercise.lastReps,
          lastSets: exercise.type == 'weight' ? sets : exercise.lastSets,
          lastTime: exercise.type == 'cardio' ? time : exercise.lastTime,
          lastSpeed: exercise.type == 'cardio' ? speed : exercise.lastSpeed,
          lastDistance: exercise.type == 'cardio' ? distance : exercise.lastDistance,
          lastCalories: exercise.type == 'cardio' ? calories : exercise.lastCalories,
          lastRpe: rpe ?? exercise.lastRpe,
        );
        
        _exercises[index] = updatedExercise;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      
      // Don't rethrow authentication errors - they're handled by AuthService
      if (e is! AuthenticationException) {
        rethrow;
      }
    }
  }

  // Get exercise by ID
  Exercise? getExerciseById(String id) {
    return _exercises.firstWhere((e) => e.id == id, orElse: () => Exercise.empty());
  }

  // Get smart defaults for an exercise
  Map<String, dynamic> getSmartDefaults(String exerciseId) {
    final exercise = getExerciseById(exerciseId);
    if (exercise == null || exercise.id.isEmpty) {
      return {};
    }
    
    final defaults = <String, dynamic>{};
    
    if (exercise.type == 'weight') {
      // Use last used values if available, otherwise use defaults
      defaults['weight'] = exercise.lastWeight ?? exercise.defaultWeight ?? 0.0;
      defaults['reps'] = exercise.lastReps ?? exercise.defaultReps ?? 0;
      defaults['sets'] = exercise.lastSets ?? exercise.defaultSets ?? 0;
      defaults['rpe'] = exercise.lastRpe ?? exercise.defaultRpe ?? 5;
    } else {
      defaults['time'] = exercise.lastTime ?? exercise.defaultTime ?? 0.0;
      defaults['speed'] = exercise.lastSpeed ?? exercise.defaultSpeed ?? 0.0;
      defaults['distance'] = exercise.lastDistance ?? exercise.defaultDistance ?? 0.0;
      defaults['calories'] = exercise.lastCalories ?? exercise.defaultCalories ?? 0;
      defaults['rpe'] = exercise.lastRpe ?? exercise.defaultRpe ?? 5;
    }
    
    return defaults;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearExercises() {
    _exercises.clear();
    notifyListeners();
  }

  // Local storage methods
  Future<void> _initLocalStorage() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadExercisesFromStorage();
    } catch (e) {
      print('Error initializing local storage: $e');
    }
  }

  Future<void> _saveExercisesToStorage() async {
    if (_prefs == null) return;
    
    try {
      final exercisesJson = _exercises.map((e) => e.toJson()).toList();
      final jsonString = jsonEncode(exercisesJson);
      await _prefs!.setString('local_exercises', jsonString);
    } catch (e) {
      print('Error saving exercises to storage: $e');
    }
  }

  Future<void> _loadExercisesFromStorage() async {
    if (_prefs == null) return;
    
    try {
      final jsonString = _prefs!.getString('local_exercises');
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> exercisesJson = jsonDecode(jsonString);
        _exercises = exercisesJson.map((json) => Exercise.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading exercises from storage: $e');
    }
  }

  String _generateLocalId() {
    return 'local_${DateTime.now().millisecondsSinceEpoch}_${_exercises.length}';
  }

  // Enhanced methods with local storage fallback
  Future<void> loadExercisesWithFallback({
    String? typeFilter,
    String? search,
  }) async {
    _setLoading(true);
    _error = null;
    
    try {
      // Try to load from backend first
      final backendExercises = await _apiService.getExercises(
        typeFilter: typeFilter,
        search: search,
      );
      
      // If backend returns exercises, use them and update local storage
      if (backendExercises.isNotEmpty) {
        _backendAvailable = true;
        _exercises = backendExercises;
        await _saveExercisesToStorage();
      } else {
        // If backend returns empty but no error, backend is available but no data
        _backendAvailable = true;
        // Keep local exercises if any
        if (_exercises.isEmpty) {
          await _loadExercisesFromStorage();
        }
      }
      
      notifyListeners();
    } catch (e) {
      // If we get an error (like 404), backend is not available
      _backendAvailable = false;
      
      // Load from local storage
      await _loadExercisesFromStorage();
      
      // Only show error if we have no local data
      if (_exercises.isEmpty) {
        _error = 'Backend unavailable. No local exercises found.';
      } else {
        _error = 'Backend unavailable. Showing local exercises.';
      }
      
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<Exercise> createExerciseWithFallback(Exercise exercise) async {
    _setLoading(true);
    _error = null;
    
    try {
      // Try to create on backend
      final createdExercise = await _apiService.createExercise(exercise);
      _exercises.add(createdExercise);
      await _saveExercisesToStorage();
      notifyListeners();
      return createdExercise;
    } catch (e) {
      // If backend fails, create locally
      _backendAvailable = false;
      
      // Generate local ID and add timestamps
      final localExercise = exercise.copyWith(
        id: _generateLocalId(),
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );
      
      _exercises.add(localExercise);
      await _saveExercisesToStorage();
      notifyListeners();
      
      _error = 'Backend unavailable. Exercise saved locally.';
      return localExercise;
    } finally {
      _setLoading(false);
    }
  }

  Future<Exercise> updateExerciseWithFallback(String id, Exercise exercise) async {
    _setLoading(true);
    _error = null;
    
    try {
      // Try to update on backend
      final updatedExercise = await _apiService.updateExercise(id, exercise);
      final index = _exercises.indexWhere((e) => e.id == id);
      if (index != -1) {
        _exercises[index] = updatedExercise;
        await _saveExercisesToStorage();
      }
      notifyListeners();
      return updatedExercise;
    } catch (e) {
      // If backend fails, update locally
      _backendAvailable = false;
      
      final index = _exercises.indexWhere((e) => e.id == id);
      if (index != -1) {
        final updatedExercise = exercise.copyWith(
          id: id,
          updatedAt: DateTime.now().toUtc(),
        );
        _exercises[index] = updatedExercise;
        await _saveExercisesToStorage();
        notifyListeners();
        
        _error = 'Backend unavailable. Exercise updated locally.';
        return updatedExercise;
      } else {
        throw Exception('Exercise not found');
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteExerciseWithFallback(String id) async {
    _setLoading(true);
    _error = null;
    
    try {
      // Try to delete from backend
      await _apiService.deleteExercise(id);
      _exercises.removeWhere((e) => e.id == id);
      await _saveExercisesToStorage();
      notifyListeners();
    } catch (e) {
      // If backend fails, delete locally
      _backendAvailable = false;
      
      _exercises.removeWhere((e) => e.id == id);
      await _saveExercisesToStorage();
      notifyListeners();
      
      _error = 'Backend unavailable. Exercise deleted locally.';
    } finally {
      _setLoading(false);
    }
  }

  Future<List<Exercise>> seedExercisesWithFallback() async {
    _setLoading(true);
    _error = null;
    
    try {
      // Try to seed on backend
      final seededExercises = await _apiService.seedExercises();
      _exercises.addAll(seededExercises);
      await _saveExercisesToStorage();
      notifyListeners();
      return seededExercises;
    } catch (e) {
      // If backend fails, seed locally with default exercises
      _backendAvailable = false;
      
      final defaultExercises = [
        Exercise(
          id: _generateLocalId(),
          name: 'Bench Press',
          type: 'weight',
          defaultWeight: 60.0,
          defaultReps: 10,
          defaultSets: 3,
          defaultRpe: 7,
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        ),
        Exercise(
          id: _generateLocalId(),
          name: 'Squat',
          type: 'weight',
          defaultWeight: 80.0,
          defaultReps: 8,
          defaultSets: 3,
          defaultRpe: 8,
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        ),
        Exercise(
          id: _generateLocalId(),
          name: 'Deadlift',
          type: 'weight',
          defaultWeight: 100.0,
          defaultReps: 5,
          defaultSets: 3,
          defaultRpe: 9,
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        ),
        Exercise(
          id: _generateLocalId(),
          name: 'Running',
          type: 'cardio',
          defaultTime: 30.0,
          defaultSpeed: 10.0,
          defaultDistance: 5.0,
          defaultCalories: 300,
          defaultRpe: 6,
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        ),
        Exercise(
          id: _generateLocalId(),
          name: 'Cycling',
          type: 'cardio',
          defaultTime: 45.0,
          defaultSpeed: 20.0,
          defaultDistance: 15.0,
          defaultCalories: 400,
          defaultRpe: 5,
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        ),
      ];
      
      _exercises.addAll(defaultExercises);
      await _saveExercisesToStorage();
      notifyListeners();
      
      _error = 'Backend unavailable. Default exercises created locally.';
      return defaultExercises;
    } finally {
      _setLoading(false);
    }
  }

  bool get isBackendAvailable => _backendAvailable;
}