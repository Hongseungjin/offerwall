import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'eums_method_channel.dart';

abstract class EumsPlatformInterface extends PlatformInterface {
  /// Constructs a SdkEumsPlatform.
  EumsPlatformInterface() : super(token: _token);

  static final Object _token = Object();

  static EumsPlatformInterface _instance = EumsMethodChannel();

  /// The default instance of [EumsPlatformInterface] to use.
  ///
  /// Defaults to [EumsMethodChannel].
  static EumsPlatformInterface get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [EumsPlatformInterface] when
  /// they register themselves.
  static set instance(EumsPlatformInterface instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String> getAppNameByPackage(String packageName);

}
