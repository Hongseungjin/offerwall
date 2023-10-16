import 'dart:io';

import 'package:flutter_overlay_window/flutter_overlay_window.dart';


class EumsPermission {
  EumsPermission._();

  static final EumsPermission instant = EumsPermission._();
  checkPermission() async {
    if (Platform.isAndroid) {
      final bool status = await FlutterOverlayWindow.isPermissionGranted();
      if (!status) {
        await FlutterOverlayWindow.requestPermission();
      } else {}
    }
  }
}
