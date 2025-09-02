import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../services/ad_service.dart';
import '../providers/settings_provider.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  final AdService _adService = AdService();
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    // Only load ads on mobile platforms
    if (!kIsWeb) {
      _loadAd();
    }
  }

  void _loadAd() async {
    try {
      _adService.loadBannerAd();
      
      // Poll for ad load completion with a timeout
      int attempts = 0;
      const maxAttempts = 10; // 10 seconds max wait
      
      while (attempts < maxAttempts && mounted) {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted && _adService.isBannerAdReady) {
          setState(() {
            _isAdLoaded = true;
          });
          break;
        }
        attempts++;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading ad: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        // Hide ads for premium users
        if (settingsProvider.settings.isPremium) {
          return const SizedBox.shrink();
        }

        // Hide ads on web platform
        if (kIsWeb) {
          return const SizedBox.shrink();
        }

        // Show banner ad if loaded, otherwise show placeholder
        if (_isAdLoaded && _adService.bannerAd != null) {
          return Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: _adService.bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _adService.bannerAd!),
          );
        } else {
          return Container(
            height: 60,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: const Center(
              child: Text(
                '広告読み込み中...',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}