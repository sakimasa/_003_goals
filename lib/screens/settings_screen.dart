import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/app_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: Colors.lightBlue.shade50,
      ),
      backgroundColor: Colors.lightBlue.shade50,
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          if (settingsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final settings = settingsProvider.settings;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildNotificationSection(settings, settingsProvider),
              const SizedBox(height: 24),
              _buildPremiumSection(settings),
              const SizedBox(height: 24),
              _buildAboutSection(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationSection(
    AppSettings settings,
    SettingsProvider settingsProvider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications, color: Colors.lightBlue.shade600),
                const SizedBox(width: 12),
                const Text(
                  '通知設定',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('通知を有効にする'),
              subtitle: const Text('進捗入力のリマインド通知'),
              value: settings.notificationsEnabled,
              onChanged: (value) {
                final newSettings = settings.copyWith(
                  notificationsEnabled: value,
                );
                settingsProvider.updateSettings(newSettings);
              },
            ),
            if (settings.notificationsEnabled) ...[
              const Divider(),
              ListTile(
                title: const Text('通知頻度'),
                subtitle: Text(settings.frequencyDisplayName),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showFrequencyDialog(settings, settingsProvider),
              ),
              ListTile(
                title: const Text('通知時刻'),
                subtitle: Text(
                  '${settings.notificationHour.toString().padLeft(2, '0')}:'
                  '${settings.notificationMinute.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showTimePickerDialog(settings, settingsProvider),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumSection(AppSettings settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  settings.isPremium ? Icons.star : Icons.star_outline,
                  color:
                      settings.isPremium
                          ? Colors.amber.shade600
                          : Colors.grey.shade600,
                ),
                const SizedBox(width: 12),
                Text(
                  settings.isPremium ? 'プレミアム会員' : 'アカウント',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (settings.isPremium) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.amber.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'プレミアム機能をご利用いただけます',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.lightBlue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.lightBlue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.lightBlue.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '無料版をご利用中です（目標作成上限：3個）',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    DefaultTabController.of(context)?.animateTo(3);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade400,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('プレミアムにアップグレード'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.lightBlue.shade600),
                const SizedBox(width: 12),
                const Text(
                  'アプリについて',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('バージョン'),
              subtitle: const Text('1.0.0'),
              leading: const Icon(Icons.info_outline),
            ),
            ListTile(
              title: const Text('フィードバック'),
              subtitle: const Text('ご意見・ご要望をお聞かせください'),
              leading: const Icon(Icons.feedback),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('フィードバック機能は準備中です')),
                );
              },
            ),
            ListTile(
              title: const Text('利用規約'),
              leading: const Icon(Icons.description),
              onTap: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('利用規約画面は準備中です')));
              },
            ),
            ListTile(
              title: const Text('プライバシーポリシー'),
              leading: const Icon(Icons.privacy_tip),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('プライバシーポリシー画面は準備中です')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFrequencyDialog(
    AppSettings settings,
    SettingsProvider settingsProvider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('通知頻度'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  NotificationFrequency.values.map((frequency) {
                    return RadioListTile<NotificationFrequency>(
                      title: Text(
                        frequency.name == 'daily'
                            ? '毎日'
                            : frequency.name == 'weekly'
                            ? '毎週'
                            : frequency.name == 'monthly'
                            ? '毎月'
                            : 'なし',
                      ),
                      value: frequency,
                      groupValue: settings.frequency,
                      onChanged: (value) {
                        if (value != null) {
                          final newSettings = settings.copyWith(
                            frequency: value,
                          );
                          settingsProvider.updateSettings(newSettings);
                          Navigator.pop(context);
                        }
                      },
                    );
                  }).toList(),
            ),
          ),
    );
  }

  void _showTimePickerDialog(
    AppSettings settings,
    SettingsProvider settingsProvider,
  ) async {
    final timeOfDay = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.notificationHour,
        minute: settings.notificationMinute,
      ),
    );

    if (timeOfDay != null) {
      final newSettings = settings.copyWith(
        notificationHour: timeOfDay.hour,
        notificationMinute: timeOfDay.minute,
      );
      settingsProvider.updateSettings(newSettings);
    }
  }
}
