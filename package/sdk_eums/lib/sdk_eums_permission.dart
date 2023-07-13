import 'dart:io';

import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class SdkEumsPermission {
  SdkEumsPermission._();

  static final SdkEumsPermission instant = SdkEumsPermission._();
  checkPermission() async {
    if (Platform.isAndroid) {
      final bool status = await FlutterOverlayWindow.isPermissionGranted();
      if (!status) {
        await FlutterOverlayWindow.requestPermission();
      } else {}
    }
  }
}
