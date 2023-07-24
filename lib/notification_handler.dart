import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sdk_eums/sdk_eums_library.dart';

class NotificationHandler {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
  );

  initializeFcmNotification() async {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('mipmap/ic_launcher');

    var initializationSettingsIOS = const IOSInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      // if (state.remoteMessage != null) {
      //   _iosOnMessage(state.remoteMessage!);
      // }
    });
    await _fcm.requestPermission();
    // getToken();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: $message");
      FlutterBackgroundService().invoke("showOverlay", {'data': message.data});
    });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});
  }

  getToken() async {
    String? token;
    if (Platform.isIOS) {
      token = await _fcm.getAPNSToken();
    } else {
      token = await _fcm.getToken();
    }
    return token;
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('message.data ${message.data}');
  FlutterBackgroundService().invoke("showOverlay", {'data': message.data});
}
