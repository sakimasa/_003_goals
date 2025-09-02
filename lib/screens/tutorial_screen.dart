import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'main_navigation.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeTutorial();
    }
  }

  void _skipTutorial() {
    _completeTutorial();
  }

  void _completeTutorial() async {
    final settingsProvider = context.read<SettingsProvider>();
    final newSettings = settingsProvider.settings.copyWith(isFirstLaunch: false);
    final success = await settingsProvider.updateSettings(newSettings);
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.lightBlue.shade300,
                  Colors.lightBlue.shade100,
                  Colors.white,
                ],
              ),
            ),
          ),
          // Tutorial content
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              _buildWelcomePage(),
              _buildGoalManagementPage(),
              _buildProgressTrackingPage(),
            ],
          ),
          // Skip button (top right)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 20,
            child: TextButton(
              onPressed: _skipTutorial,
              child: Text(
                'スキップ',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // Bottom navigation
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: _buildBottomNavigation(),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App icon/illustration
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.lightBlue.shade400,
              borderRadius: BorderRadius.circular(60),
              boxShadow: [
                BoxShadow(
                  color: Colors.lightBlue.shade200,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.flag_rounded,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 50),
          // Welcome title
          Text(
            '目標達成アプリへようこそ！',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          // Welcome description
          Text(
            'このアプリは、あなたの夢や目標を\n実現するための最強のパートナーです。\n\n一歩ずつ着実に目標に向かって\n進んでいきましょう！',
            style: TextStyle(
              fontSize: 18,
              height: 1.6,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalManagementPage() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.green.shade400,
              borderRadius: BorderRadius.circular(60),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.shade200,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.track_changes,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 50),
          // Title
          Text(
            'ステップで目標を管理',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          // Description
          Text(
            '大きな目標も小さなステップに分解することで\n達成しやすくなります。\n\n各ステップに期限を設定して、\n毎日の進捗を記録していきましょう。',
            style: TextStyle(
              fontSize: 18,
              height: 1.6,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          // Feature highlights
          _buildFeatureItem(
            Icons.add_task,
            '目標とステップを設定',
            '目標を細かいステップに分けて管理',
          ),
          const SizedBox(height: 20),
          _buildFeatureItem(
            Icons.schedule,
            '期限を設定',
            '各ステップに期限を設けて計画的に',
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTrackingPage() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.orange.shade400,
              borderRadius: BorderRadius.circular(60),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.shade200,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.trending_up,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 50),
          // Title
          Text(
            '進捗を可視化して継続',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          // Description
          Text(
            '毎日の進捗を記録することで、\n自分の成長を実感できます。\n\nタスクを完了させて、\n目標達成への道のりを楽しみましょう！',
            style: TextStyle(
              fontSize: 18,
              height: 1.6,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          // Feature highlights
          _buildFeatureItem(
            Icons.analytics,
            '進捗の可視化',
            '進捗状況をグラフやチャートで確認',
          ),
          const SizedBox(height: 20),
          _buildFeatureItem(
            Icons.celebration,
            '達成感を味わう',
            'タスク完了時の達成感で継続をサポート',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.lightBlue.shade100,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            icon,
            color: Colors.lightBlue.shade600,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Page indicator
        Row(
          children: List.generate(
            _totalPages,
            (index) => Container(
              margin: const EdgeInsets.only(right: 8),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: index == _currentPage
                    ? Colors.lightBlue.shade400
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        // Next/Start button
        ElevatedButton(
          onPressed: _nextPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue.shade400,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 3,
          ),
          child: Text(
            _currentPage == _totalPages - 1 ? '始める！' : '次へ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}