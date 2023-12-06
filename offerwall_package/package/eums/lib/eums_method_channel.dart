import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// import 'package:sdk_eums_c/sdk_eums_c_platform_interface.dart';

import 'eums_platform_interface.dart';

/// An implementation of [EumsPlatformInterface] that uses method channels.
class EumsMethodChannel extends EumsPlatformInterface {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('eums');

 
  @override
  Future<String> getAppNameByPackage(String packageName) async {
    final appName = await methodChannel.invokeMethod<String>('getAppNameByPackageName', packageName);
    return appName ?? '';
  }
}
