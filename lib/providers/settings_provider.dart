import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

class SettingsProvider with ChangeNotifier {
  AppSettings _settings = AppSettings();
  bool _isLoading = true;
  bool _isInitialized = false;

  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  SettingsProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    _isLoading = true;
    if (_isInitialized) {
      notifyListeners();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      
      final isFirstLaunch = prefs.getBool('is_first_launch') ?? true;
      if (kDebugMode) {
        print('Loading settings - is_first_launch from SharedPreferences: $isFirstLaunch');
      }
      
      _settings = AppSettings(
        notificationsEnabled: prefs.getBool('notifications_enabled') ?? true,
        frequency: NotificationFrequency.values[prefs.getInt('frequency') ?? 0],
        notificationHour: prefs.getInt('notification_hour') ?? 9,
        notificationMinute: prefs.getInt('notification_minute') ?? 0,
        isPremium: prefs.getBool('is_premium') ?? false,
        isFirstLaunch: isFirstLaunch,
      );
    } catch (e) {
      print('Error loading settings: $e');
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<bool> updateSettings(AppSettings newSettings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool('notifications_enabled', newSettings.notificationsEnabled);
      await prefs.setInt('frequency', newSettings.frequency.index);
      await prefs.setInt('notification_hour', newSettings.notificationHour);
      await prefs.setInt('notification_minute', newSettings.notificationMinute);
      await prefs.setBool('is_premium', newSettings.isPremium);
      await prefs.setBool('is_first_launch', newSettings.isFirstLaunch);
      
      if (kDebugMode) {
        print('Updated is_first_launch in SharedPreferences to: ${newSettings.isFirstLaunch}');
      }

      _settings = newSettings;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error updating settings: $e');
      return false;
    }
  }

  Future<bool> upgradeToPremium() async {
    try {
      final updatedSettings = _settings.copyWith(isPremium: true);
      return await updateSettings(updatedSettings);
    } catch (e) {
      print('Error upgrading to premium: $e');
      return false;
    }
  }

  bool canCreateMoreGoals(int currentGoalCount) {
    if (_settings.isPremium) return true;
    return currentGoalCount < 3;
  }

  Future<bool> resetFirstLaunchFlag() async {
    try {
      final updatedSettings = _settings.copyWith(isFirstLaunch: true);
      return await updateSettings(updatedSettings);
    } catch (e) {
      print('Error resetting first launch flag: $e');
      return false;
    }
  }
}