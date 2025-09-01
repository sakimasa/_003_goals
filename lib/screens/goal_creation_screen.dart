import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/goal_provider.dart';
import '../providers/settings_provider.dart';
import '../models/goal.dart';
import '../widgets/goal_creation_stepper.dart';
import 'main_navigation.dart';

class GoalCreationScreen extends StatefulWidget {
  const GoalCreationScreen({super.key});

  @override
  State<GoalCreationScreen> createState() => _GoalCreationScreenState();
}

class _GoalCreationScreenState extends State<GoalCreationScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  Goal? _currentGoal;
  List<GoalStep> _steps = [];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('目標作成'),
        backgroundColor: Colors.lightBlue.shade50,
      ),
      backgroundColor: Colors.lightBlue.shade50,
      body: Consumer2<GoalProvider, SettingsProvider>(
        builder: (context, goalProvider, settingsProvider, child) {
          return Column(
            children: [
              _buildProgressIndicator(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) {
                    setState(() => _currentStep = page);
                  },
                  children: [
                    _buildGoalCreationStep(goalProvider, settingsProvider),
                    _buildStepsCreationStep(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStepIndicator(0, '目標設定', _currentStep >= 0),
          Expanded(child: _buildConnectorLine(_currentStep > 0)),
          _buildStepIndicator(1, 'ステップ設定', _currentStep >= 1),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? Colors.lightBlue.shade400 : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.lightBlue.shade700 : Colors.grey.shade600,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildConnectorLine(bool isActive) {
    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      color: isActive ? Colors.lightBlue.shade400 : Colors.grey.shade300,
    );
  }

  Widget _buildGoalCreationStep(GoalProvider goalProvider, SettingsProvider settingsProvider) {
    return GoalCreationStepOne(
      onGoalCreated: (goal) async {
        if (!settingsProvider.canCreateMoreGoals(await goalProvider.getGoalCount())) {
          if (context.mounted) {
            _showGoalLimitDialog();
          }
          return;
        }

        setState(() => _currentGoal = goal);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  Widget _buildStepsCreationStep() {
    if (_currentGoal == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return StepsCreationWidget(
      goal: _currentGoal!,
      onStepsCreated: (steps) async {
        setState(() => _steps = steps);
        await _saveGoalAndSteps();
      },
      onBack: () {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  Future<void> _saveGoalAndSteps() async {
    final goalProvider = context.read<GoalProvider>();
    
    final success = await goalProvider.addGoal(_currentGoal!);
    if (success) {
      final goals = goalProvider.goals;
      final savedGoal = goals.first;
      
      // Add steps to the saved goal
      for (int i = 0; i < _steps.length; i++) {
        final step = _steps[i].copyWith(goalId: savedGoal.id, order: i + 1);
        await goalProvider.addStep(step);
      }

      // Reload all goals and steps to ensure data consistency
      await goalProvider.loadGoals();

      if (context.mounted) {
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        final mainNavigation = MainNavigationInherited.of(context);
        
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('目標が作成されました！'),
            backgroundColor: Colors.green,
          ),
        );
        
        _resetForm();
        mainNavigation?.navigateToIndex(0);
      }
    }
  }

  void _resetForm() {
    setState(() {
      _currentStep = 0;
      _currentGoal = null;
      _steps = [];
    });
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showGoalLimitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('目標数の上限に達しました'),
        content: const Text(
          '無料版では最大3つまでの目標しか作成できません。\n'
          'プレミアムに升級するか、既存の目標を削除してから新しい目標を作成してください。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              MainNavigationInherited.of(context)?.navigateToIndex(3);
            },
            child: const Text('プレミアムを見る'),
          ),
        ],
      ),
    );
  }
}

class GoalCreationStepOne extends StatefulWidget {
  final Function(Goal) onGoalCreated;

  const GoalCreationStepOne({
    super.key,
    required this.onGoalCreated,
  });

  @override
  State<GoalCreationStepOne> createState() => _GoalCreationStepOneState();
}

class _GoalCreationStepOneState extends State<GoalCreationStepOne> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDeadline;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'いつまでに何を達成したいですか？',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '目標タイトル',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: '例：英語でプレゼンテーションができるようになる',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '目標タイトルを入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              '達成したい具体的な状態',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '例：英語で自信を持って10分間のプレゼンテーションを行い、質疑応答にも答えられる状態',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '達成したい状態を入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'いつまでに？（期日）',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectDeadline,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDeadline != null
                          ? '${_selectedDeadline!.year}年${_selectedDeadline!.month}月${_selectedDeadline!.day}日'
                          : '期日を選択してください',
                      style: TextStyle(
                        color: _selectedDeadline != null
                            ? Colors.black
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createGoal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  '次へ：ステップを設定',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (date != null) {
      setState(() => _selectedDeadline = date);
    }
  }

  void _createGoal() {
    if (!_formKey.currentState!.validate() || _selectedDeadline == null) {
      if (_selectedDeadline == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('期日を選択してください'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final goal = Goal(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      deadline: _selectedDeadline!,
      createdAt: DateTime.now(),
    );

    widget.onGoalCreated(goal);
  }
}