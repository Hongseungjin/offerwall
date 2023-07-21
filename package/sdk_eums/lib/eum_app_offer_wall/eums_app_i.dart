import 'package:flutter/material.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'eums_app.dart';

abstract class EumsAppOfferWallService extends PlatformInterface {
  EumsAppOfferWallService() : super(token: _token);

  static final Object _token = Object();

  static EumsAppOfferWallService _instance = EumsAppOfferWall();

  /// The default instance of [EumsSdkI] to use.
  ///
  /// Defaults to [EumsSdkI].
  static EumsAppOfferWallService get instance => _instance;

  static set instance(EumsAppOfferWallService instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<dynamic> openSdk(BuildContext context,
      {String? memId, String? memGen, String? memRegion, String? memBirth});

  openAppSkd(BuildContext context,
      {String? memId, String? memGen, String? memRegion, String? memBirth});
}
