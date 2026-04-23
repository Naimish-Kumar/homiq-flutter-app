import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Service to manage Google Mobile Ads for the Homiq AI app.
/// Shows banner ads to free-tier users; premium users see no ads.
class AdService {
  static BannerAd? _bannerAd;
  static bool _isInitialized = false;

  // Test Ad Unit IDs (replace with real ones for production)
  static String get _bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test ID
    }
    return '';
  }

  /// Initialize Google Mobile Ads SDK. Call once in main.dart.
  static Future<void> initialize() async {
    if (_isInitialized) return;
    await MobileAds.instance.initialize();
    _isInitialized = true;
  }

  /// Load a banner ad.
  static Future<BannerAd?> loadBannerAd({
    Function? onLoaded,
    Function? onFailed,
  }) async {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) => onLoaded?.call(),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
          onFailed?.call();
        },
      ),
    );
    await _bannerAd?.load();
    return _bannerAd;
  }

  /// Dispose current banner ad.
  static void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
  }
}

/// Widget that displays a banner ad if loaded.
/// Hides itself for premium users.
class HomiqBannerAd extends StatefulWidget {
  final bool isPremium;
  const HomiqBannerAd({super.key, this.isPremium = false});

  @override
  State<HomiqBannerAd> createState() => _HomiqBannerAdState();
}

class _HomiqBannerAdState extends State<HomiqBannerAd> {
  BannerAd? _ad;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isPremium) {
      _loadAd();
    }
  }

  Future<void> _loadAd() async {
    _ad = await AdService.loadBannerAd(
      onLoaded: () {
        if (mounted) setState(() => _isLoaded = true);
      },
      onFailed: () {
        if (mounted) setState(() => _isLoaded = false);
      },
    );
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isPremium || !_isLoaded || _ad == null) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: _ad!.size.width.toDouble(),
      height: _ad!.size.height.toDouble(),
      child: AdWidget(ad: _ad!),
    );
  }
}
