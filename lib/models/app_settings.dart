enum NotificationFrequency {
  daily,
  weekly,
  monthly,
  none,
}

class AppSettings {
  final bool notificationsEnabled;
  final NotificationFrequency frequency;
  final int notificationHour;
  final int notificationMinute;
  final bool isPremium;

  AppSettings({
    this.notificationsEnabled = true,
    this.frequency = NotificationFrequency.daily,
    this.notificationHour = 9,
    this.notificationMinute = 0,
    this.isPremium = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'notifications_enabled': notificationsEnabled,
      'frequency': frequency.index,
      'notification_hour': notificationHour,
      'notification_minute': notificationMinute,
      'is_premium': isPremium,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      notificationsEnabled: json['notifications_enabled'] ?? true,
      frequency: NotificationFrequency.values[json['frequency'] ?? 0],
      notificationHour: json['notification_hour'] ?? 9,
      notificationMinute: json['notification_minute'] ?? 0,
      isPremium: json['is_premium'] ?? false,
    );
  }

  AppSettings copyWith({
    bool? notificationsEnabled,
    NotificationFrequency? frequency,
    int? notificationHour,
    int? notificationMinute,
    bool? isPremium,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      frequency: frequency ?? this.frequency,
      notificationHour: notificationHour ?? this.notificationHour,
      notificationMinute: notificationMinute ?? this.notificationMinute,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  String get frequencyDisplayName {
    switch (frequency) {
      case NotificationFrequency.daily:
        return '毎日';
      case NotificationFrequency.weekly:
        return '毎週';
      case NotificationFrequency.monthly:
        return '毎月';
      case NotificationFrequency.none:
        return 'なし';
    }
  }
}