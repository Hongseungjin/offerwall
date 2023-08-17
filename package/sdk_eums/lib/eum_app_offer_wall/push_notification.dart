// // ignore: depend_on_referenced_packages
// import 'package:flutter_apns/flutter_apns.dart';

// Future<void> onLaunch(message) async {
//   print('onLaunch $message');
//   return Future.value(true);
// }

// Future<void> onResume(ApnsRemoteMessage message) async {
//   print('onResume ${message.payload}');
//   onPush('name', RemoteMessage.fromMap(message.payload));
//   return Future.value(true);
// }

// Future<void> onMessage(message) async {
//   print('onMessage $message');
//   return Future.value(true);
// }

// Future<void> onBackgroundMessage(message) async {
//   print('onBackgroundMessage $message');
//   return Future.value(true);
// }

// Future<dynamic> onPush(String name, RemoteMessage payload) {
//   print('onPushonPush $payload');
//   final action = UNNotificationAction.getIdentifier(payload.data);

//   if (action == 'MEETING_INVITATION') {
//     // do something
//   }

//   return Future.value(true);
// }

// class PushNotificationIos {
//   initApns() {
//     final ApnsPushConnectorOnly connector = ApnsPushConnectorOnly();

//     connector.configureApns(
//       onLaunch: onLaunch,
//       onResume: onResume,
//       onMessage: onMessage,
//       onBackgroundMessage: onBackgroundMessage,
//     );

//     connector.requestNotificationPermissions();

//     connector.token.addListener(() {
//       if (connector.token.value != null) {
//         print('connector.token.value ${connector.token.value}');
//       }
//     });
//     connector.shouldPresent = (x) => Future.value(true);
//     connector.setNotificationCategories([
//       UNNotificationCategory(
//         identifier: 'MEETING_INVITATION',
//         actions: [
//           UNNotificationAction(
//             identifier: 'ACCEPT_ACTION',
//             title: 'Accept',
//             options: UNNotificationActionOptions.values,
//           ),
//           UNNotificationAction(
//             identifier: 'DECLINE_ACTION',
//             title: 'Decline',
//             options: [],
//           ),
//         ],
//         intentIdentifiers: [],
//         options: UNNotificationCategoryOptions.values,
//       ),
//     ]);
//   }
// }
