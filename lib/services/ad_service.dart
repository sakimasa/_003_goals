import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isBannerAdReady = false;
  bool _isInterstitialAdReady = false;

  bool get isBannerAdReady => _isBannerAdReady;
  bool get isInterstitialAdReady => _isInterstitialAdReady;
  BannerAd? get bannerAd => _bannerAd;

  // Test ad unit IDs - replace with your actual ad unit IDs for production
  static const String _bannerAdUnitId = kDebugMode 
    ? 'ca-app-pub-3940256099942544/6300978111' // Test banner ad unit ID
    : 'ca-app-pub-3940256099942544/6300978111'; // Replace with your real ad unit ID

  static const String _interstitialAdUnitId = kDebugMode
    ? 'ca-app-pub-3940256099942544/1033173712' // Test interstitial ad unit ID  
    : 'ca-app-pub-3940256099942544/1033173712'; // Replace with your real ad unit ID

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  void loadBannerAd() {
    try {
      _bannerAd = BannerAd(
        adUnitId: _bannerAdUnitId,
        request: const AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _isBannerAdReady = true;
            if (kDebugMode) {
              print('Banner ad loaded successfully');
            }
          },
          onAdFailedToLoad: (ad, error) {
            _isBannerAdReady = false;
            ad.dispose();
            _bannerAd = null;
            if (kDebugMode) {
              print('Banner ad failed to load: $error');
            }
          },
          onAdOpened: (ad) {
            if (kDebugMode) {
              print('Banner ad opened');
            }
          },
          onAdClosed: (ad) {
            if (kDebugMode) {
              print('Banner ad closed');
            }
          },
        ),
      );
      _bannerAd!.load();
    } catch (e) {
      if (kDebugMode) {
        print('Error creating banner ad: $e');
      }
      _isBannerAdReady = false;
    }
  }

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          if (kDebugMode) {
            print('Interstitial ad loaded successfully');
          }
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdReady = false;
          if (kDebugMode) {
            print('Interstitial ad failed to load: $error');
          }
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd != null && _isInterstitialAdReady) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadInterstitialAd(); // Load a new ad for next time
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          loadInterstitialAd(); // Load a new ad for next time
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
      _isInterstitialAdReady = false;
    }
  }

  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
  }
}