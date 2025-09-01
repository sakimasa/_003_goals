import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart'; // Temporarily disabled for iOS testing
import '../services/ad_service.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  final AdService _adService = AdService();

  @override
  void initState() {
    super.initState();
    _adService.loadBannerAd();
  }

  @override
  Widget build(BuildContext context) {
    // Temporarily disabled AdWidget for iOS testing
    return Container(
      height: 60,
      width: double.infinity,
      color: Colors.grey.shade200,
      child: const Center(
        child: Text(
          '広告スペース（iOS テスト中）',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}