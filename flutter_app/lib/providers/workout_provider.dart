import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../services/api_service.dart';

class WorkoutProvider with ChangeNotifier {
  final ApiService _apiService;
  
  List<Workout> _workouts = [];
  bool _isLoading = false;
  String? _error;

  WorkoutProvider({required ApiService apiService}) : _apiService = apiService;

  List<Workout> get workouts => _workouts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadWorkouts() async {
    _setLoading(true);
    _error = null;
    
    try {
      _workouts = await _apiService.getWorkouts();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<Workout> createWorkout(Workout workout) async {
    _setLoading(true);
    _error = null;
    
    try {
      final createdWorkout = await _apiService.createWorkout(workout);
      _workouts.add(createdWorkout);
      notifyListeners();
      return createdWorkout;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<Workout> updateWorkout(String id, Workout workout) async {
    _setLoading(true);
    _error = null;
    
    try {
      final updatedWorkout = await _apiService.updateWorkout(id, workout);
      final index = _workouts.indexWhere((w) => w.id == id);
      if (index != -1) {
        _workouts[index] = updatedWorkout;
      }
      notifyListeners();
      return updatedWorkout;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteWorkout(String id) async {
    _setLoading(true);
    _error = null;
    
    try {
      await _apiService.deleteWorkout(id);
      _workouts.removeWhere((w) => w.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Template methods removed - using Exercise library instead
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
