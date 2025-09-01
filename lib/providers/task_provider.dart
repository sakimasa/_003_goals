import 'package:flutter/material.dart';
import '../models/task.dart';
import '../database/database_helper.dart';

class TaskProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  Map<int, List<Task>> _tasksByStep = {};
  Map<int, List<TaskHistory>> _historyByStep = {};
  bool _isLoading = false;

  Map<int, List<Task>> get tasksByStep => _tasksByStep;
  Map<int, List<TaskHistory>> get historyByStep => _historyByStep;
  bool get isLoading => _isLoading;

  Future<void> loadTasksForStep(int stepId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasksByStep[stepId] = await _db.getTasksByStepId(stepId);
      _historyByStep[stepId] = await _db.getTaskHistoryByStepId(stepId);
    } catch (e) {
      print('Error loading tasks for step $stepId: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTaskProgress(int stepId, String progressDescription, String? nextAction) async {
    try {
      final history = TaskHistory(
        stepId: stepId,
        progressDescription: progressDescription,
        nextAction: nextAction,
        recordedAt: DateTime.now(),
      );

      await _db.insertTaskHistory(history);

      final existingTask = await _db.getLatestTaskByStepId(stepId);
      
      if (existingTask != null) {
        final updatedTask = existingTask.copyWith(
          currentProgress: progressDescription,
          nextAction: nextAction,
        );
        await _db.updateTask(updatedTask);
      } else {
        final newTask = Task(
          stepId: stepId,
          currentProgress: progressDescription,
          nextAction: nextAction,
          createdAt: DateTime.now(),
        );
        await _db.insertTask(newTask);
      }

      await loadTasksForStep(stepId);
      return true;
    } catch (e) {
      print('Error adding task progress: $e');
      return false;
    }
  }

  Task? getLatestTaskForStep(int stepId) {
    final tasks = _tasksByStep[stepId];
    if (tasks != null && tasks.isNotEmpty) {
      return tasks.first;
    }
    return null;
  }

  List<TaskHistory> getHistoryForStep(int stepId) {
    return _historyByStep[stepId] ?? [];
  }

  String? getNextActionForStep(int stepId) {
    final latestTask = getLatestTaskForStep(stepId);
    return latestTask?.nextAction;
  }
}