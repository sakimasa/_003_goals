class Task {
  final int? id;
  final int stepId;
  final String? currentProgress;
  final String? nextAction;
  final DateTime? completedAt;
  final DateTime createdAt;

  Task({
    this.id,
    required this.stepId,
    this.currentProgress,
    this.nextAction,
    this.completedAt,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'step_id': stepId,
      'current_progress': currentProgress,
      'next_action': nextAction,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      stepId: json['step_id'],
      currentProgress: json['current_progress'],
      nextAction: json['next_action'],
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Task copyWith({
    int? id,
    int? stepId,
    String? currentProgress,
    String? nextAction,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      stepId: stepId ?? this.stepId,
      currentProgress: currentProgress ?? this.currentProgress,
      nextAction: nextAction ?? this.nextAction,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class TaskHistory {
  final int? id;
  final int stepId;
  final String progressDescription;
  final String? nextAction;
  final DateTime recordedAt;

  TaskHistory({
    this.id,
    required this.stepId,
    required this.progressDescription,
    this.nextAction,
    required this.recordedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'step_id': stepId,
      'progress_description': progressDescription,
      'next_action': nextAction,
      'recorded_at': recordedAt.toIso8601String(),
    };
  }

  factory TaskHistory.fromJson(Map<String, dynamic> json) {
    return TaskHistory(
      id: json['id'],
      stepId: json['step_id'],
      progressDescription: json['progress_description'],
      nextAction: json['next_action'],
      recordedAt: DateTime.parse(json['recorded_at']),
    );
  }
}