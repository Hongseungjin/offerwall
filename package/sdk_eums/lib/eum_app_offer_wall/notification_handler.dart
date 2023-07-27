import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sdk_eums/common/local_store/local_store_service.dart';
import 'package:sdk_eums/sdk_eums_library.dart';

class NotificationHandler {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  FlutterLocalNotificationsPlugin get flutterLocalNotificationsPlugin =>
      _flutterLocalNotificationsPlugin;
  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
  );

  initializeFcmNotification() async {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('mipmap/ic_launcher');

    // var initializationSettingsIOS = const DarwinInitializationSettings();

    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    try {
      await _fcm.requestPermission();
    } catch (e) {}
    // await getToken();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: $message");
      FlutterBackgroundService().invoke("showOverlay", {'data': message.data});
    });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  getToken() async {
    String? token;
    if (Platform.isIOS) {
      token = await _fcm.getAPNSToken();
    } else {
      token = await _fcm.getToken();
    }
    LocalStoreService().setDeviceToken(token);
    print('deviceTokenInit $token');
    return token;
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  FlutterBackgroundService().invoke("showOverlay", {'data': message.data});
}
