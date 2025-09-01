// import 'package:google_mobile_ads/google_mobile_ads.dart'; // Temporarily disabled for iOS testing

// AdService temporarily disabled for iOS testing
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // Mock properties for iOS testing
  bool get isBannerAdReady => false;
  bool get isInterstitialAdReady => false;
  dynamic get bannerAd => null;

  Future<void> initialize() async {
    // Mock implementation
  }

  void loadBannerAd() {
    // Mock implementation
  }

  void loadInterstitialAd() {
    // Mock implementation  
  }

  void showInterstitialAd() {
    // Mock implementation
  }

  void dispose() {
    // Mock implementation
  }
}