import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sdk_eums_c/sdk_eums_c_platform_interface.dart';

// import 'package:sdk_eums_c/sdk_eums_c_platform_interface.dart';

import 'sdk_eums_platform_interface.dart';

/// An implementation of [SdkEumsPlatform] that uses method channels.
class MethodChannelSdkEums extends SdkEumsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('sdk_eums');

  @override
  Future methodAdpopcorn({data}) async {
    if (Platform.isAndroid) {
      await methodChannel.invokeMethod<dynamic>('Adpopcorn', data);
    } else {
      try {
        await SdkEums_cPlatform.instance.methodAdpopcorn(data: data);
      } catch (ex) {}
    }
  }

  @override
  Future methodAdsync({data}) async {
    if (Platform.isAndroid) {
      await methodChannel.invokeMethod<dynamic>('adsync', data);
    } else {
      await SdkEums_cPlatform.instance.methodAdsync(data: data);
    }
  }

  @override
  Future methodAppall({data}) async {
    await methodChannel.invokeMethod<dynamic>('appall', data);
  }

  @override
  Future methodMafin({data}) async {
    if (Platform.isAndroid) {
      await methodChannel.invokeMethod<dynamic>('mafin', data);
    } else {
      await SdkEums_cPlatform.instance.methodMafin(data: data);
    }
  }

  @override
  Future methodIvekorea({data}) async {
    await methodChannel.invokeMethod<dynamic>('iveKorea', data);
  }

  @override
  Future methodTnk({data}) async {
    await methodChannel.invokeMethod<dynamic>('tkn', data);
  }

  @override
  Future methodOHC({data}) async {
    await methodChannel.invokeMethod<dynamic>('ohc', data);
  }

  @override
  Future methodUser({data}) async {
    await methodChannel.invokeMethod<dynamic>('dataUser', data);
  }
}
