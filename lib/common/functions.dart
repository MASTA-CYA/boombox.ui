import 'package:boombox/common/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Functions {
  static bool isPlatformWeb() {
    bool isWeb = false;
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      isWeb = false;
    } else {
      isWeb = true;
    }

    return isWeb;
  }

  static double horizontalScreenMargin(BuildContext context) {
    return MediaQuery.of(context).size.width <= DeviceSize.TABLET_SCREEN_WIDTH
        ? 5
        : 100;
  }
}
