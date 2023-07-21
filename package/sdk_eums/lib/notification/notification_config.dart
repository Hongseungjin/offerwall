import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("messageDataBackgroud${message.data}");
  FlutterBackgroundService().invoke("showOverlay", {'data': message.data});
}

class NotificationConfig {
  NotificationConfig._();
  static final NotificationConfig instant = NotificationConfig._();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high,
      playSound: true);

  Future init() async {
    if (Platform.operatingSystem == 'android') {
      _androidRegisterNotifications();
    } else if (Platform.operatingSystem == 'ios') {
      _iOSRegisterNotifications();
    }
  }

  // #region Android initial setup

  _androidRegisterNotifications() async {
    await Firebase.initializeApp();
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
    await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true);
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    //onLaunch
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        _androidOnMessage(message);
      }
    });

    //onMessage foreground
    FirebaseMessaging.onMessage.listen(_androidOnMessageForeground);

    //onResume
    FirebaseMessaging.onMessageOpenedApp.listen(_androidOnMessage);

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  Future<void> _androidOnMessageForeground(RemoteMessage message) async {
    print("_androidOnMessageForeground $message");

    // show custom dialog notification and sound
    if (Platform.operatingSystem == 'android') {
      String? titleMessage = message.notification?.title;
      String? bodyMessage = message.notification?.body;
      RemoteNotification? notification = message.notification;
      FlutterBackgroundService().invoke("showOverlay", {'data': message.data});
      _flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          titleMessage,
          bodyMessage,
          NotificationDetails(
            android: AndroidNotificationDetails(_channel.id, _channel.name,
                channelDescription: _channel.description,
                playSound: true,
                importance: Importance.max,
                icon: '@mipmap/ic_launcher',
                onlyAlertOnce: true),
          ));
    } else {}
  }

  Future<void> _androidOnMessage(RemoteMessage message) async {
    print("_androidOnMessage_androidOnMessage");
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    _flutterLocalNotificationsPlugin.cancelAll();
  }

  _iOSRegisterNotifications() async {
    await Firebase.initializeApp();
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    var initializationSettingsIOS = const IOSInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    var initializationSettings =
        InitializationSettings(iOS: initializationSettingsIOS);

    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      debugPrint("_flutterLocalNotificationsPlugin.initialize: $payload");
      // if (state.remoteMessage != null) {
      //   _iosOnMessage(state.remoteMessage!);
      // }
    });

    // onLaunch
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        _iosOnMessage(message);
      }
    });
    // onMessage foreground
    FirebaseMessaging.onMessage.listen(_iosOnMessageForeground);

    // onResume
    FirebaseMessaging.onMessageOpenedApp.listen(_iosOnMessage);

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  Future<void> _iosOnMessage(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AppleNotification? ios = message.notification?.apple;
    if (notification != null && ios != null) {
      // add(PushNotificationHandleRemoteMessage(
      //     message: message, isForeground: false));
    }
  }

  Future<void> _iosOnMessageForeground(RemoteMessage message) async {}

  Future getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    debugPrint("firebase-token: $token");
    return token;
  }
}
