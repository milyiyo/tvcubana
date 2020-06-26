import 'dart:io';

class AdManager {

  static String get appId {
    if (Platform.isAndroid) {
      // return "ca-app-pub-3940256099942544~4354546703";
      return "ca-app-pub-3010271812686729~1473795479"; // orig
    // } else if (Platform.isIOS) {
    //   return "<YOUR_IOS_ADMOB_APP_ID>";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      // return "ca-app-pub-3940256099942544/8865242552";
      return "ca-app-pub-3010271812686729/8478187520"; // orig
    // } else if (Platform.isIOS) {
    //   return "<YOUR_IOS_BANNER_AD_UNIT_ID>";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  // static String get interstitialAdUnitId {
  //   if (Platform.isAndroid) {
  //     return "<YOUR_ANDROID_INTERSTITIAL_AD_UNIT_ID>";
  //   } else if (Platform.isIOS) {
  //     return "<YOUR_IOS_INTERSTITIAL_AD_UNIT_ID>";
  //   } else {
  //     throw new UnsupportedError("Unsupported platform");
  //   }
  // }

  // static String get rewardedAdUnitId {
  //   if (Platform.isAndroid) {
  //     return "<YOUR_ANDROID_REWARDED_AD_UNIT_ID>";
  //   } else if (Platform.isIOS) {
  //     return "<YOUR_IOS_REWARDED_AD_UNIT_ID>";
  //   } else {
  //     throw new UnsupportedError("Unsupported platform");
  //   }
  // }
}