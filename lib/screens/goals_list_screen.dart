import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/goal_provider.dart';
import '../providers/settings_provider.dart';
import '../models/goal.dart';
import '../widgets/goal_card.dart';
import '../widgets/goal_detail_dialog.dart';
import 'main_navigation.dart';
import 'goal_edit_screen.dart';
import 'goal_detail_screen.dart';
import 'settings_screen.dart';

class GoalsListScreen extends StatefulWidget {
  const GoalsListScreen({super.key});

  @override
  State<GoalsListScreen> createState() => _GoalsListScreenState();
}

class _GoalsListScreenState extends State<GoalsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoalProvider>().loadGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('目標一覧'),
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
      body: Consumer2<GoalProvider, SettingsProvider>(
        builder: (context, goalProvider, settingsProvider, child) {
          if (goalProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final goals = goalProvider.goals;

          if (goals.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              if (!settingsProvider.settings.isPremium) _buildAdBanner(),
              _buildHeader(goals.length, settingsProvider.settings.isPremium),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await goalProvider.loadGoals();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: goals.length,
                    itemBuilder: (context, index) {
                      final goal = goals[index];
                      return GoalCard(
                        goal: goal,
                        onTap: () => _showGoalDetailScreen(context, goal),
                        onEdit: () => _editGoal(context, goal),
                        onDelete: () => _showDeleteConfirmation(context, goal),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
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
    );
  }

  Widget _buildAdBanner() {
    return Container(
      height: 60,
      width: double.infinity,
      color: Colors.grey.shade200,
      child: const Center(
        child: Text(
          '広告スペース\nプレミアムで非表示',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int goalCount, bool isPremium) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '設定中の目標',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '$goalCount',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlue.shade700,
                      ),
                    ),
                    if (!isPremium) ...[
                      Text(
                        ' / 3',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '無料版',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'プレミアム',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.amber.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.flag,
            color: Colors.lightBlue.shade300,
            size: 32,
          ),
        ],
      ),
    );
  }


  void _showGoalDetailScreen(BuildContext context, Goal goal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoalDetailScreen(goal: goal),
      ),
    );
  }

  void _editGoal(BuildContext context, Goal goal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoalEditScreen(goal: goal),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Goal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('目標を削除'),
        content: Text('「${goal.title}」を削除しますか？\nこの操作は元に戻せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<GoalProvider>().deleteGoal(goal.id!);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? '目標を削除しました' : '削除に失敗しました'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              '削除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}