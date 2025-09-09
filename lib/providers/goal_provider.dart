import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/goal.dart';
import '../database/database_helper.dart';

class GoalProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<Goal> _goals = [];
  bool _isLoading = false;

  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;

  Future<void> loadGoals() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (kIsWeb) {
        // For web, goals are already in memory, just update loading state
        // No need to fetch from database
      } else {
        _goals = await _db.getAllGoals();
      }
    } catch (e) {
      print('Error loading goals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addGoal(Goal goal) async {
    try {
      if (kIsWeb) {
        // For web, generate a simple ID and store in memory
        final id = _goals.isEmpty ? 1 : _goals.map((g) => g.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
        final newGoal = goal.copyWith(id: id);
        _goals.insert(0, newGoal);
        notifyListeners();
        return true;
      } else {
        final id = await _db.insertGoal(goal);
        final newGoal = goal.copyWith(id: id);
        _goals.insert(0, newGoal);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error adding goal: $e');
      return false;
    }
  }

  Future<bool> addStep(GoalStep step) async {
    try {
      if (kIsWeb) {
        // For web, generate a simple ID and store in memory
        final allSteps = _goals.expand((g) => g.steps).toList();
        final id = allSteps.isEmpty ? 1 : allSteps.map((s) => s.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
        final newStep = step.copyWith(id: id);

        final goalIndex = _goals.indexWhere((g) => g.id == step.goalId);
        if (goalIndex != -1) {
          final updatedSteps = List<GoalStep>.from(_goals[goalIndex].steps)
            ..add(newStep);
          _goals[goalIndex] = _goals[goalIndex].copyWith(steps: updatedSteps);
          notifyListeners();
        }
        return true;
      } else {
        final id = await _db.insertStep(step);
        final newStep = step.copyWith(id: id);

        final goalIndex = _goals.indexWhere((g) => g.id == step.goalId);
        if (goalIndex != -1) {
          final updatedSteps = List<GoalStep>.from(_goals[goalIndex].steps)
            ..add(newStep);
          _goals[goalIndex] = _goals[goalIndex].copyWith(steps: updatedSteps);
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      print('Error adding step: $e');
      return false;
    }
  }

  List<GoalStep> getAllCurrentSteps() {
    List<GoalStep> allSteps = [];
    for (var goal in _goals) {
      allSteps.addAll(goal.steps.where((step) => !step.isCompleted));
    }
    return allSteps;
  }

  Goal? getGoalById(int goalId) {
    try {
      return _goals.firstWhere((goal) => goal.id == goalId);
    } catch (e) {
      return null;
    }
  }

  Future<int> getGoalCount() async {
    if (kIsWeb) {
      return _goals.length;
    } else {
      return await _db.getGoalCount();
    }
  }

  Future<bool> updateGoal(Goal goal) async {
    try {
      if (kIsWeb) {
        // For web, update in local list
        final index = _goals.indexWhere((g) => g.id == goal.id);
        if (index != -1) {
          _goals[index] = goal;
          notifyListeners();
        }
        return true;
      } else {
        await _db.updateGoal(goal);
        await loadGoals();
        return true;
      }
    } catch (e) {
      print('Error updating goal: $e');
      return false;
    }
  }

  Future<bool> deleteGoal(int goalId) async {
    try {
      if (kIsWeb) {
        // For web, remove from local list
        _goals.removeWhere((goal) => goal.id == goalId);
        notifyListeners();
        return true;
      } else {
        await _db.deleteGoal(goalId);
        _goals.removeWhere((goal) => goal.id == goalId);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error deleting goal: $e');
      return false;
    }
  }

  Future<bool> completeStep(int stepId) async {
    try {
      if (kIsWeb) {
        // For web, update step completion in local list
        _updateStepCompletionInMemory(stepId, true);
        return true;
      } else {
        await _db.updateStepCompletion(stepId, true);
        await loadGoals();
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> reopenStep(int stepId) async {
    try {
      if (kIsWeb) {
        // For web, update step completion in local list
        _updateStepCompletionInMemory(stepId, false);
        return true;
      } else {
        await _db.updateStepCompletion(stepId, false);
        await loadGoals();
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateStep(GoalStep step) async {
    try {
      if (kIsWeb) {
        // For web, update step in local list
        for (int i = 0; i < _goals.length; i++) {
          for (int j = 0; j < _goals[i].steps.length; j++) {
            if (_goals[i].steps[j].id == step.id) {
              final updatedSteps = List<GoalStep>.from(_goals[i].steps);
              updatedSteps[j] = step;
              _goals[i] = _goals[i].copyWith(steps: updatedSteps);
              notifyListeners();
              return true;
            }
          }
        }
        return false;
      } else {
        await _db.updateStep(step);
        await loadGoals();
        return true;
      }
    } catch (e) {
      print('Error updating step: $e');
      return false;
    }
  }

  void _updateStepCompletionInMemory(int stepId, bool isCompleted) {
    for (int i = 0; i < _goals.length; i++) {
      for (int j = 0; j < _goals[i].steps.length; j++) {
        if (_goals[i].steps[j].id == stepId) {
          final updatedSteps = List<GoalStep>.from(_goals[i].steps);
          updatedSteps[j] = updatedSteps[j].copyWith(isCompleted: isCompleted);
          _goals[i] = _goals[i].copyWith(steps: updatedSteps);
          notifyListeners();
          return;
        }
      }
    }
  }
}
