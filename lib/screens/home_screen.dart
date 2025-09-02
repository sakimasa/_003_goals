import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/goal_provider.dart';
import '../providers/task_provider.dart';
import '../providers/settings_provider.dart';
import '../models/goal.dart';
import '../widgets/task_card.dart';
import '../widgets/task_progress_dialog.dart';
import '../widgets/ad_banner_widget.dart';
import 'main_navigation.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload data when returning to this screen, but not during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final goalProvider = context.read<GoalProvider>();
    final taskProvider = context.read<TaskProvider>();
    
    goalProvider.loadGoals().then((_) {
      final allSteps = goalProvider.getAllCurrentSteps();
      for (var step in allSteps) {
        if (step.id != null) {
          taskProvider.loadTasksForStep(step.id!);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('今日のタスク'),
        backgroundColor: Colors.lightBlue.shade50,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.settings),
            tooltip: '設定',
          ),
        ],
      ),
      backgroundColor: Colors.lightBlue.shade50,
      body: Consumer3<GoalProvider, TaskProvider, SettingsProvider>(
        builder: (context, goalProvider, taskProvider, settingsProvider, child) {
          if (goalProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final allSteps = goalProvider.getAllCurrentSteps();
          
          if (allSteps.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () async {
              _loadData();
            },
            child: Column(
              children: [
                if (!settingsProvider.settings.isPremium) _buildAdBanner(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: allSteps.length,
                    itemBuilder: (context, index) {
                      final step = allSteps[index];
                      final goal = goalProvider.getGoalById(step.goalId);
                      final nextAction = taskProvider.getNextActionForStep(step.id!);
                      
                      return TaskCard(
                        step: step,
                        goal: goal,
                        nextAction: nextAction,
                        onTap: () => _showTaskProgressDialog(context, step, goal),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Column(
          children: [
            if (!settingsProvider.settings.isPremium) _buildAdBanner(),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      size: 80,
                      color: Colors.lightBlue.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'まだ目標が設定されていません',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '目標作成画面から新しい目標を設定しましょう',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to goal creation screen using InheritedWidget
                        MainNavigationInherited.of(context)?.navigateToIndex(1);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('目標を作成する'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAdBanner() {
    return const AdBannerWidget();
  }

  void _showTaskProgressDialog(BuildContext context, GoalStep step, Goal? goal) {
    if (goal == null) return;

    showDialog(
      context: context,
      builder: (context) => TaskProgressDialog(
        step: step,
        goal: goal,
        onProgressSubmitted: (progressDescription, nextAction) async {
          final taskProvider = context.read<TaskProvider>();
          final success = await taskProvider.addTaskProgress(
            step.id!,
            progressDescription,
            nextAction,
          );

          if (success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('進捗を記録しました'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        onStepCompleted: () async {
          final goalProvider = context.read<GoalProvider>();
          final success = await goalProvider.completeStep(step.id!);

          if (success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('ステップを完了しました'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }
}