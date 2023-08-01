import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'sdk_eums_c_method_channel.dart';

abstract class SdkEums_cPlatform extends PlatformInterface {
  /// Constructs a SdkEums_cPlatform.
  SdkEums_cPlatform() : super(token: _token);

  static final Object _token = Object();

  static SdkEums_cPlatform _instance = MethodChannelSdkEums_c();

  /// The default instance of [SdkEums_cPlatform] to use.
  ///
  /// Defaults to [MethodChannelSdkEums_c].
  static SdkEums_cPlatform get instance => _instance;

  // /// Platform-specific implementations should set this with their own
  // /// platform-specific class that extends [SdkEums_cPlatform] when
  // /// they register themselves.
  // static set instance(SdkEums_cPlatform instance) {
  //   PlatformInterface.verifyToken(instance, _token);
  //   _instance = instance;
  // }

  // // Future<String?> getPlatformVersion() {
  // //   throw UnimplementedError('platformVersion() has not been implemented.');
  // // }

  Future methodAdpopcorn({dynamic data});
  Future methodAdsync({dynamic data});
  Future methodMafin({dynamic data});
}
