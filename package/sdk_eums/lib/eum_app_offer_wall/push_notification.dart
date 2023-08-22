// import 'dart:io';

// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';

// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print("Handling a background message: ${message.messageId}");
//   //firebase push notification
//   // AwesomeNotifications().createNotificationFromJsonData(message.data);
//   await AwesomeNotifications().createNotification(
//     content: NotificationContent(
//       id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
//       channelKey: 'basic_channel',
//       title: '${Emojis.wheater_droplet} Add some water to your plant!',
//       body: 'Water your plant regularly to keep it healthy.',
//       notificationLayout: NotificationLayout.Default,
//     ),
//     actionButtons: [
//       NotificationActionButton(
//         key: 'MARK_DONE',
//         label: 'Mark Done',
//       ),
//     ],
//   );
// }

// class NotificationController {
//   static ReceivedAction? initialAction;

//   static Future<void> initializeLocalNotifications() async {
//     await AwesomeNotifications().initialize(
//         null, //'resource://drawable/res_app_icon',//
//         [
//           NotificationChannel(
//             channelKey: 'basic_channel',
//             channelName: 'Basic Notifications',
//             defaultColor: Colors.teal,
//             importance: NotificationImportance.High,
//             channelShowBadge: true,
//             channelDescription: '',
//           ),
//           NotificationChannel(
//             channelKey: 'scheduled_channel',
//             channelName: 'Scheduled Notifications',
//             defaultColor: Colors.teal,
//             locked: true,
//             importance: NotificationImportance.High,
//             soundSource: 'resource://raw/res_custom_notification',
//             channelDescription: '',
//           ),
//         ],
//         debug: true);
//    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
//   if (!isAllowed) {
//     // Insert here your friendly dialog box before call the request method
//     // This is very important to not harm the user experience
//     AwesomeNotifications().requestPermissionToSendNotifications();
//   }
// });
//     await FirebaseMessaging.instance.requestPermission(
//       alert: false,
//       announcement: false,
//       badge: false,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: false,
//     );

//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//     FirebaseMessaging.onMessage.listen((event) async {
//       await AwesomeNotifications().createNotification(
//         content: NotificationContent(
//           id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
//           channelKey: 'basic_channel',
//           title: '${Emojis.wheater_droplet} Add some water to your plant!',
//           body: 'Water your plant regularly to keep it healthy.',
//           notificationLayout: NotificationLayout.Default,
//         ),
//         actionButtons: [
//           NotificationActionButton(
//             key: 'MARK_DONE',
//             label: 'Mark Done',
//           ),
//         ],
//       );
//     });

//     AwesomeNotifications().actionStream.listen((notification) {
//       if (notification.channelKey == 'basic_channel' && Platform.isIOS) {
  
//         print("vafo day");
//         // AwesomeNotifications().getGlobalBadgeCounter().then(
//         //       (value) =>
//         //           AwesomeNotifications().setGlobalBadgeCounter(value - 1),
//         //     );
//       }
//     });
//   }
// }
