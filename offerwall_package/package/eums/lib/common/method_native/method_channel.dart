// import 'package:flutter/services.dart';

// class MethodOfferwallChannel {

//   MethodOfferwallChannel._();
//   static MethodOfferwallChannel instant= MethodOfferwallChannel._();

//   final methodChannel = const MethodChannel('method_offerwall');
//   Future<Map<String, dynamic>> init() async {
//     final dataInit = await methodChannel.invokeMethod('init');
//     return dataInit;
//   }

//   back() async {
//     // methodChannel.invokeMethod('back');
//     await SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');
//   }
// }
