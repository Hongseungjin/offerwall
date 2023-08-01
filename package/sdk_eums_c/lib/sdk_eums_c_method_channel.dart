import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'sdk_eums_c_platform_interface.dart';

/// An implementation of [SdkEums_cPlatform] that uses method channels.
class MethodChannelSdkEums_c extends SdkEums_cPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('sdk_eums_c');

  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future methodAdpopcorn({data}) async {
    try {
      await methodChannel.invokeMethod<dynamic>('AdpopcornIos', data);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future methodAdsync({data}) async {
    try {
      await methodChannel.invokeMethod<dynamic>('Adsync', data);
      return true;
    } catch (e) {
      rethrow;
    }
  }
  @override
  Future methodMafin({data}) async {
    try {
      await methodChannel.invokeMethod<dynamic>('mafin', data);
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
