import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static String? get bannerAdUnitId {
    return 'ca-app-pub-3940256099942544/6300978111';
  }

  static String? get interstitialAdUnitId {
    return 'ca-app-pub-3940256099942544/1033173712';
  }

  static final bannerListener = BannerAdListener(
    onAdLoaded: (ad) => debugPrint('Ad loaded'),
    onAdFailedToLoad: (ad, error) {
      ad.dispose();
      debugPrint('Ad failed to load: $error');
    },
    onAdOpened: (ad) => debugPrint('add opened'),
    onAdClosed: (ad) => debugPrint('add closed'),
  );
}
