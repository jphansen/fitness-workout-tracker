import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../models/workout_template.dart';
import '../services/api_service.dart';

class WorkoutProvider with ChangeNotifier {
  final ApiService _apiService;
  
  List<Workout> _workouts = [];
  List<WorkoutTemplate> _templates = [];
  bool _isLoading = false;
  String? _error;

  WorkoutProvider({required ApiService apiService}) : _apiService = apiService;

  List<Workout> get workouts => _workouts;
  List<WorkoutTemplate> get templates => _templates;
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

  Future<void> loadTemplates() async {
    _setLoading(true);
    _error = null;
    
    try {
      _templates = await _apiService.getTemplates();
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

  Future<List<WorkoutTemplate>> getTemplatesByType(String workoutType) async {
    _setLoading(true);
    _error = null;
    
    try {
      final templates = await _apiService.getTemplatesByType(workoutType);
      return templates;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<WorkoutTemplate> createTemplate(WorkoutTemplate template) async {
    _setLoading(true);
    _error = null;
    
    try {
      final createdTemplate = await _apiService.createTemplate(template);
      _templates.add(createdTemplate);
      notifyListeners();
      return createdTemplate;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<WorkoutTemplate> updateTemplate(String id, WorkoutTemplate template) async {
    _setLoading(true);
    _error = null;
    
    try {
      final updatedTemplate = await _apiService.updateTemplate(id, template);
      final index = _templates.indexWhere((t) => t.id == id);
      if (index != -1) {
        _templates[index] = updatedTemplate;
      }
      notifyListeners();
      return updatedTemplate;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteTemplate(String id) async {
    _setLoading(true);
    _error = null;
    
    try {
      await _apiService.deleteTemplate(id);
      _templates.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> seedTemplates() async {
    _setLoading(true);
    _error = null;
    
    try {
      _templates = await _apiService.seedTemplates();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
