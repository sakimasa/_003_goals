import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'providers/goal_provider.dart';
import 'providers/task_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/main_navigation.dart';
import 'screens/tutorial_screen.dart';
import 'services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize AdMob (only on mobile platforms)
  if (!kIsWeb) {
    try {
      await AdService().initialize();
    } catch (e) {
      if (kDebugMode) {
        print('AdMob initialization failed: $e');
      }
    }
  }
  
  // Initialize database for web
  if (kIsWeb) {
    // For web, we'll use a mock database or implement web-specific storage
    // This prevents the sqflite initialization error on web
  }
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GoalProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          // Show loading while settings are being initialized
          if (!settingsProvider.isInitialized || settingsProvider.isLoading) {
            return MaterialApp(
              title: '目標達成アプリ',
              theme: _buildTheme(),
              home: const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              debugShowCheckedModeBanner: false,
            );
          }

          if (kDebugMode) {
            print('App startup - isFirstLaunch: ${settingsProvider.settings.isFirstLaunch}');
          }
          
          return MaterialApp(
            title: '目標達成アプリ',
            theme: _buildTheme(),
            home: settingsProvider.settings.isFirstLaunch 
                ? const TutorialScreen() 
                : const MainNavigation(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.lightBlue.shade300,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.lightBlue.shade400,
        foregroundColor: Colors.white,
      ),
    );
  }
}
