import 'dart:io';

class AdManager {
  static String get appId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3010271812686729~1473795479";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3010271812686729/8478187520";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
}
