import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdManager {
  static int _adCount = 0;
  static InterstitialAd? _interstitialAd;

  void load({VoidCallback? onAdLoad}) {
   

    InterstitialAd.load(
      adUnitId:'',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          log('$ad loaded.');
          onAdLoad?.call();
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          log('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  Future<void> show() async {
  
    if (_interstitialAd != null) {
      _adCount++;
      if (_adCount == 4) {
        await _interstitialAd!.show();

        _adCount = 0; // Reset the count after showing the ad
      }
    }
  }
}
