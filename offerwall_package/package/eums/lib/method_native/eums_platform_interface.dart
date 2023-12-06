import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'eums_method_channel.dart';

abstract class EumsPlatform extends PlatformInterface {
  /// Constructs a EumsPlatform.
  EumsPlatform() : super(token: _token);

  static final Object _token = Object();

  static EumsPlatform _instance = MethodChannelEums();

  /// The default instance of [EumsPlatform] to use.
  ///
  /// Defaults to [MethodChannelEums].
  static EumsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [EumsPlatform] when
  /// they register themselves.
  static set instance(EumsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
  Future<bool?> openOverlay(dynamic data) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
