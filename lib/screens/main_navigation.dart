import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/goal_provider.dart';
import '../providers/settings_provider.dart';
import 'home_screen.dart';
import 'goal_creation_screen.dart';
import 'goals_list_screen.dart';
import 'premium_screen.dart';
import 'settings_screen.dart';

class MainNavigationInherited extends InheritedWidget {
  final Function(int) navigateToIndex;
  
  const MainNavigationInherited({
    super.key,
    required this.navigateToIndex,
    required super.child,
  });

  static MainNavigationInherited? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainNavigationInherited>();
  }

  @override
  bool updateShouldNotify(MainNavigationInherited oldWidget) {
    return false;
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const GoalCreationScreen(),
      const GoalsListScreen(),
      const PremiumScreen(),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().loadSettings();
      context.read<GoalProvider>().loadGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return MainNavigationInherited(
          navigateToIndex: (index) => setState(() => _currentIndex = index),
          child: Scaffold(
            key: _scaffoldKey,
            drawer: _buildDrawer(context, settingsProvider),
            body: _screens[_currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() => _currentIndex = index);
                // Refresh data when switching to home tab
                if (index == 0) {
                  context.read<GoalProvider>().loadGoals();
                }
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.lightBlue.shade700,
              unselectedItemColor: Colors.grey,
              backgroundColor: Colors.white,
              elevation: 8,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'ホーム',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_circle_outline),
                  label: '目標作成',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.list),
                  label: '目標一覧',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.star),
                  label: 'プレミアム',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context, SettingsProvider settingsProvider) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.lightBlue.shade400,
                  Colors.lightBlue.shade600,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.flag,
                  color: Colors.white,
                  size: 40,
                ),
                SizedBox(height: 8),
                Text(
                  '目標達成アプリ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '着実に前進しよう',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('設定'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          if (settingsProvider.settings.isPremium)
            ListTile(
              leading: Icon(Icons.star, color: Colors.amber.shade600),
              title: const Text('プレミアム会員'),
              subtitle: const Text('ご利用ありがとうございます'),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('アプリについて'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: '目標達成アプリ',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 Goal Achievement App',
      children: const [
        Text('目標に向けて着実に前進するためのアプリです。'),
      ],
    );
  }
}