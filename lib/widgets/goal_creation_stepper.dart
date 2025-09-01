import 'package:flutter/material.dart';
import '../models/goal.dart';

class StepsCreationWidget extends StatefulWidget {
  final Goal goal;
  final Function(List<GoalStep>) onStepsCreated;
  final VoidCallback onBack;

  const StepsCreationWidget({
    super.key,
    required this.goal,
    required this.onStepsCreated,
    required this.onBack,
  });

  @override
  State<StepsCreationWidget> createState() => _StepsCreationWidgetState();
}

class _StepsCreationWidgetState extends State<StepsCreationWidget> {
  final PageController _pageController = PageController();
  final List<GoalStep> _steps = [];
  int _currentStepIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: _currentStepIndex < 4
              ? _buildStepCreation()
              : _buildConfirmation(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _currentStepIndex == 0 ? widget.onBack : _goBack,
                icon: const Icon(Icons.arrow_back),
              ),
              Expanded(
                child: Text(
                  _currentStepIndex < 4
                      ? 'ステップ${_currentStepIndex + 1}を設定'
                      : '設定内容を確認',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.goal.title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.lightBlue.shade700,
            ),
          ),
          if (_currentStepIndex < 4) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (_steps.length + 1) / 4,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue.shade400),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepCreation() {
    return StepCreationForm(
      key: ValueKey('step_${_currentStepIndex + 1}'),
      stepNumber: _currentStepIndex + 1,
      onStepCreated: (step) {
        setState(() {
          _steps.add(step);
          _currentStepIndex++;
        });
      },
      onSkip: _steps.isEmpty ? null : () => setState(() => _currentStepIndex = 4),
    );
  }

  Widget _buildConfirmation() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '設定完了！',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '以下の内容で目標を作成します',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGoalSummary(),
                  const SizedBox(height: 24),
                  _buildStepsSummary(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _goBack,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('戻る'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => widget.onStepsCreated(_steps),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    '目標を作成',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '目標',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.goal.title,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '期日：${widget.goal.deadline.year}年${widget.goal.deadline.month}月${widget.goal.deadline.day}日',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsSummary() {
    if (_steps.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'ステップは設定されていません',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ステップ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ..._steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ステップ${index + 1}：${step.title}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.description,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${step.deadline.year}年${step.deadline.month}月${step.deadline.day}日まで',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  void _goBack() {
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
        if (_currentStepIndex < _steps.length) {
          _steps.removeAt(_currentStepIndex);
        }
      });
    }
  }
}

class StepCreationForm extends StatefulWidget {
  final int stepNumber;
  final Function(GoalStep) onStepCreated;
  final VoidCallback? onSkip;

  const StepCreationForm({
    super.key,
    required this.stepNumber,
    required this.onStepCreated,
    this.onSkip,
  });

  @override
  State<StepCreationForm> createState() => _StepCreationFormState();
}

class _StepCreationFormState extends State<StepCreationForm> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _whatToDoController = TextEditingController();
  DateTime? _selectedDeadline;

  @override
  void dispose() {
    _descriptionController.dispose();
    _whatToDoController.dispose();
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ステップの内容',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: '例：基本的な英文法をマスターする',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'ステップの内容を入力してください';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'なにをする？',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _whatToDoController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: '例：英文法の教材を1日1章ずつ進める、練習問題を解く',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '具体的な行動を入力してください';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'いつまでに？',
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (widget.onSkip != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onSkip,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('ここで設定終了'),
                    ),
                  ),
                if (widget.onSkip != null) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _createStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      widget.stepNumber < 4
                          ? '次のステップを設定'
                          : 'ステップを追加',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
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

  void _createStep() {
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

    final step = GoalStep(
      goalId: 0,
      title: _descriptionController.text.trim(),
      description: _descriptionController.text.trim(),
      whatToDo: _whatToDoController.text.trim(),
      deadline: _selectedDeadline!,
      order: widget.stepNumber,
      createdAt: DateTime.now(),
    );

    widget.onStepCreated(step);
  }
}