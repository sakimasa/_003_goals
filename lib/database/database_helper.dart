import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/goal.dart';
import '../models/task.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      // For web, return a mock database or throw an informative error
      throw UnsupportedError(
        'Database operations are not supported on web platform. '
        'Please use a mobile device or desktop app for full functionality.'
      );
    }
    
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'goals_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        deadline TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE steps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        goal_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        what_to_do TEXT NOT NULL,
        deadline TEXT NOT NULL,
        order_index INTEGER NOT NULL,
        is_completed INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (goal_id) REFERENCES goals (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        step_id INTEGER NOT NULL,
        current_progress TEXT,
        next_action TEXT,
        completed_at TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (step_id) REFERENCES steps (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE task_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        step_id INTEGER NOT NULL,
        progress_description TEXT NOT NULL,
        next_action TEXT,
        recorded_at TEXT NOT NULL,
        FOREIGN KEY (step_id) REFERENCES steps (id) ON DELETE CASCADE
      )
    ''');
  }

  // Goals CRUD operations
  Future<int> insertGoal(Goal goal) async {
    final db = await database;
    return await db.insert('goals', goal.toJson());
  }

  Future<List<Goal>> getAllGoals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('goals', orderBy: 'created_at DESC');
    
    List<Goal> goals = [];
    for (var map in maps) {
      final goal = Goal.fromJson(map);
      final steps = await getStepsByGoalId(goal.id!);
      goals.add(goal.copyWith(steps: steps));
    }
    return goals;
  }

  Future<Goal?> getGoal(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final goal = Goal.fromJson(maps.first);
      final steps = await getStepsByGoalId(id);
      return goal.copyWith(steps: steps);
    }
    return null;
  }

  Future<int> updateGoal(Goal goal) async {
    final db = await database;
    return await db.update(
      'goals',
      goal.toJson(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> deleteGoal(int id) async {
    final db = await database;
    return await db.delete(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Steps CRUD operations
  Future<int> insertStep(GoalStep step) async {
    final db = await database;
    return await db.insert('steps', step.toJson());
  }

  Future<List<GoalStep>> getStepsByGoalId(int goalId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'steps',
      where: 'goal_id = ?',
      whereArgs: [goalId],
      orderBy: 'order_index ASC',
    );

    return List.generate(maps.length, (i) {
      return GoalStep.fromJson(maps[i]);
    });
  }

  Future<int> updateStep(GoalStep step) async {
    final db = await database;
    return await db.update(
      'steps',
      step.toJson(),
      where: 'id = ?',
      whereArgs: [step.id],
    );
  }

  Future<int> deleteStep(int id) async {
    final db = await database;
    return await db.delete(
      'steps',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Tasks CRUD operations
  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toJson());
  }

  Future<List<Task>> getTasksByStepId(int stepId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'step_id = ?',
      whereArgs: [stepId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Task.fromJson(maps[i]);
    });
  }

  Future<Task?> getLatestTaskByStepId(int stepId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'step_id = ?',
      whereArgs: [stepId],
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Task.fromJson(maps.first);
    }
    return null;
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toJson(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Task History CRUD operations
  Future<int> insertTaskHistory(TaskHistory history) async {
    final db = await database;
    return await db.insert('task_history', history.toJson());
  }

  Future<List<TaskHistory>> getTaskHistoryByStepId(int stepId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'task_history',
      where: 'step_id = ?',
      whereArgs: [stepId],
      orderBy: 'recorded_at DESC',
    );

    return List.generate(maps.length, (i) {
      return TaskHistory.fromJson(maps[i]);
    });
  }

  Future<int> getGoalCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM goals');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> updateStepCompletion(int stepId, bool isCompleted) async {
    final db = await database;
    return await db.update(
      'steps',
      {'is_completed': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [stepId],
    );
  }
}