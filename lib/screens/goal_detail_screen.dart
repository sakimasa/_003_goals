import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/goal.dart';
import '../providers/goal_provider.dart';
import '../providers/task_provider.dart';
import 'goal_edit_screen.dart';
import 'step_edit_screen.dart';
import '../widgets/task_progress_dialog.dart';

class GoalDetailScreen extends StatefulWidget {
  final Goal goal;

  const GoalDetailScreen({super.key, required this.goal});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Goal _currentGoal;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentGoal = widget.goal;
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    final goalProvider = context.read<GoalProvider>();
    final taskProvider = context.read<TaskProvider>();

    // Load updated goal data
    goalProvider.loadGoals().then((_) {
      final updatedGoal = goalProvider.getGoalById(_currentGoal.id!);
      if (updatedGoal != null && mounted) {
        setState(() {
          _currentGoal = updatedGoal;
        });
      }
    });

    // Load task data for all steps
    for (var step in _currentGoal.steps) {
      if (step.id != null) {
        taskProvider.loadTasksForStep(step.id!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentGoal.title),
        backgroundColor: Colors.lightBlue.shade50,
        actions: [
          IconButton(
            onPressed: () => _editGoal(),
            icon: const Icon(Icons.edit),
            tooltip: '目標を編集',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteConfirmation();
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text('削除'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.lightBlue.shade700,
          unselectedLabelColor: Colors.grey,
          tabs: const [Tab(text: '概要'), Tab(text: 'ステップ')],
        ),
      ),
      backgroundColor: Colors.lightBlue.shade50,
      body: TabBarView(
        controller: _tabController,
        children: [_buildOverviewTab(), _buildStepsTab()],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final completedSteps =
        _currentGoal.steps.where((step) => step.isCompleted).length;
    final totalSteps = _currentGoal.steps.length;
    final progress = totalSteps > 0 ? completedSteps / totalSteps : 0.0;
    final isOverdue = _currentGoal.deadline.isBefore(DateTime.now());
    final daysRemaining =
        _currentGoal.deadline.difference(DateTime.now()).inDays;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: Colors.lightBlue.shade600,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '進捗状況',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${(progress * 100).toInt()}% 完了',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.lightBlue.shade700,
                              ),
                            ),
                            Text(
                              '$completedSteps / $totalSteps ステップ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 6,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.lightBlue.shade400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.lightBlue.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Goal Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.flag,
                        color: Colors.lightBlue.shade600,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '目標詳細',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentGoal.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.calendar_today,
                    '期日',
                    DateFormat('yyyy年MM月dd日').format(_currentGoal.deadline),
                    isOverdue ? Colors.red : Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.timer,
                    '残り日数',
                    daysRemaining >= 0 ? '$daysRemaining日' : '期限切れ',
                    daysRemaining < 0
                        ? Colors.red
                        : (daysRemaining < 7 ? Colors.orange : Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.create,
                    '作成日',
                    DateFormat('yyyy年MM月dd日').format(_currentGoal.createdAt),
                    Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsTab() {
    return Consumer2<GoalProvider, TaskProvider>(
      builder: (context, goalProvider, taskProvider, child) {
        final updatedGoal =
            goalProvider.getGoalById(_currentGoal.id!) ?? _currentGoal;

        if (updatedGoal.steps.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.list_alt, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'ステップがありません',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: updatedGoal.steps.length,
          itemBuilder: (context, index) {
            final step = updatedGoal.steps[index];
            final taskHistory = taskProvider.getHistoryForStep(step.id ?? 0);
            return _buildStepCard(step, index + 1, taskHistory.length);
          },
        );
      },
    );
  }

  Widget _buildStepCard(GoalStep step, int stepNumber, int historyCount) {
    final isOverdue = step.deadline.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color:
                        step.isCompleted
                            ? Colors.green.shade400
                            : Colors.lightBlue.shade400,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child:
                        step.isCompleted
                            ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            )
                            : Text(
                              '$stepNumber',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration:
                              step.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                          color: step.isCompleted ? Colors.grey : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isOverdue && !step.isCompleted
                                      ? Colors.red.shade100
                                      : step.isCompleted
                                      ? Colors.green.shade100
                                      : Colors.lightBlue.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              DateFormat('MM/dd').format(step.deadline),
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    isOverdue && !step.isCompleted
                                        ? Colors.red.shade700
                                        : step.isCompleted
                                        ? Colors.green.shade700
                                        : Colors.lightBlue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (historyCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.history,
                                    size: 12,
                                    color: Colors.amber.shade700,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '$historyCount',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.amber.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleStepAction(value, step),
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'view_progress',
                          child: Row(
                            children: [
                              Icon(Icons.timeline, size: 20),
                              SizedBox(width: 8),
                              Text('進捗確認'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('編集'),
                            ],
                          ),
                        ),
                        if (!step.isCompleted)
                          const PopupMenuItem(
                            value: 'complete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text('完了'),
                              ],
                            ),
                          ),
                        if (step.isCompleted)
                          const PopupMenuItem(
                            value: 'reopen',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.refresh,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text('再開'),
                              ],
                            ),
                          ),
                      ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              step.description,
              style: TextStyle(
                fontSize: 14,
                color: step.isCompleted ? Colors.grey.shade600 : null,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.play_arrow,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '行動内容',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(step.whatToDo, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    Color? color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label：',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 14, color: color ?? Colors.grey.shade700),
        ),
      ],
    );
  }

  void _handleStepAction(String action, GoalStep step) {
    switch (action) {
      case 'view_progress':
        _showStepProgress(step);
        break;
      case 'edit':
        _editStep(step);
        break;
      case 'complete':
        _completeStep(step);
        break;
      case 'reopen':
        _reopenStep(step);
        break;
    }
  }

  void _showStepProgress(GoalStep step) {
    showDialog(
      context: context,
      builder:
          (context) => TaskProgressDialog(
            step: step,
            goal: _currentGoal,
            onProgressSubmitted: (progressDescription, nextAction) async {
              final taskProvider = context.read<TaskProvider>();
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final success = await taskProvider.addTaskProgress(
                step.id!,
                progressDescription,
                nextAction,
              );

              if (success && mounted) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('進捗を記録しました'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            onStepCompleted: () async {
              await _completeStep(step);
            },
          ),
    );
  }

  void _editStep(GoalStep step) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StepEditScreen(goal: _currentGoal, step: step),
      ),
    ).then((_) => _loadData());
  }

  Future<void> _completeStep(GoalStep step) async {
    final goalProvider = context.read<GoalProvider>();
    final success = await goalProvider.completeStep(step.id!);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ステップを完了しました'),
          backgroundColor: Colors.green,
        ),
      );
      _loadData();
    }
  }

  Future<void> _reopenStep(GoalStep step) async {
    // Add method to reopen step in database helper and provider
    final goalProvider = context.read<GoalProvider>();
    await goalProvider.reopenStep(step.id!);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ステップを再開しました'),
          backgroundColor: Colors.blue,
        ),
      );
      _loadData();
    }
  }

  void _editGoal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoalEditScreen(goal: _currentGoal),
      ),
    ).then((_) => _loadData());
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('目標を削除'),
            content: Text('「${_currentGoal.title}」を削除しますか？\nこの操作は元に戻せません。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final goalProvider = context.read<GoalProvider>();
                  final scaffoldMessenger = ScaffoldMessenger.of(context);

                  navigator.pop(); // Close dialog
                  final success = await goalProvider.deleteGoal(
                    _currentGoal.id!,
                  );

                  if (mounted) {
                    if (success) {
                      navigator.pop(); // Close detail screen
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text('目標を削除しました'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text('削除に失敗しました'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('削除', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
