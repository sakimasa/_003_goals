class Goal {
  final int? id;
  final String title;
  final String description;
  final DateTime deadline;
  final DateTime createdAt;
  final List<GoalStep> steps;

  Goal({
    this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.createdAt,
    this.steps = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      deadline: DateTime.parse(json['deadline']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Goal copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? deadline,
    DateTime? createdAt,
    List<GoalStep>? steps,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      steps: steps ?? this.steps,
    );
  }
}

class GoalStep {
  final int? id;
  final int goalId;
  final String title;
  final String description;
  final String whatToDo;
  final DateTime deadline;
  final int order;
  final bool isCompleted;
  final DateTime createdAt;

  GoalStep({
    this.id,
    required this.goalId,
    required this.title,
    required this.description,
    required this.whatToDo,
    required this.deadline,
    required this.order,
    this.isCompleted = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goal_id': goalId,
      'title': title,
      'description': description,
      'what_to_do': whatToDo,
      'deadline': deadline.toIso8601String(),
      'order_index': order,
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory GoalStep.fromJson(Map<String, dynamic> json) {
    return GoalStep(
      id: json['id'],
      goalId: json['goal_id'],
      title: json['title'],
      description: json['description'],
      whatToDo: json['what_to_do'],
      deadline: DateTime.parse(json['deadline']),
      order: json['order_index'],
      isCompleted: (json['is_completed'] ?? 0) == 1,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  GoalStep copyWith({
    int? id,
    int? goalId,
    String? title,
    String? description,
    String? whatToDo,
    DateTime? deadline,
    int? order,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return GoalStep(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      description: description ?? this.description,
      whatToDo: whatToDo ?? this.whatToDo,
      deadline: deadline ?? this.deadline,
      order: order ?? this.order,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}