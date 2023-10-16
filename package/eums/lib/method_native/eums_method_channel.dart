import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'eums_platform_interface.dart';

/// An implementation of [EumsPlatform] that uses method channels.
class MethodChannelEums extends EumsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('eums');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
