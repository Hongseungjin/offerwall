// import 'package:flutter_test/flutter_test.dart';
// import 'package:sdk_eums_c/sdk_eums_c.dart';
// import 'package:sdk_eums_c/sdk_eums_c_platform_interface.dart';
// import 'package:sdk_eums_c/sdk_eums_c_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// class MockSdkEums_cPlatform
//     with MockPlatformInterfaceMixin
//     implements SdkEums_cPlatform {

//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

// void main() {
//   final SdkEums_cPlatform initialPlatform = SdkEums_cPlatform.instance;

//   test('$MethodChannelSdkEums_c is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelSdkEums_c>());
//   });

//   test('getPlatformVersion', () async {
//     SdkEums_c sdkEums_cPlugin = SdkEums_c();
//     MockSdkEums_cPlatform fakePlatform = MockSdkEums_cPlatform();
//     SdkEums_cPlatform.instance = fakePlatform;

//     expect(await sdkEums_cPlugin.getPlatformVersion(), '42');
//   });
// }
