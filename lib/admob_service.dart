import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'main.dart';

class AdMobService {
  static String get bannerAdUnitId => Platform.isAndroid
      ? banner_Ad_Id
      : banner_Ad_Id;

  static initialize() {
    if (MobileAds.instance == null) {
      MobileAds.instance.initialize();
    }
  }

  static BannerAd createBannerAd() {
    BannerAd ad = new BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.largeBanner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) => print('Ad loaded'),
        onAdFailedToLoad: (Ad ad,LoadAdError error){
          ad.dispose();
        },
        onAdOpened: (Ad ad)=>print('Ad opened'),
        onAdClosed: (Ad ad)=>print('Ad closed'),
      ),
    );

    return ad;
  }


}
