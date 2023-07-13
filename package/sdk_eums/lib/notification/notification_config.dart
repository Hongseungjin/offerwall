import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:sdk_eums/common/local_store/local_store_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  final isActive = await FlutterOverlayWindow.isActive();
  if (isActive == true) {
    await FlutterOverlayWindow.closeOverlay();
  }
  LocalStoreService().setDataShare(dataShare: message.data);

  Future.delayed(const Duration(milliseconds: 500), () async {
    await FlutterOverlayWindow.showOverlay(
        enableDrag: true,
        height: 300,
        width: 300,
        alignment: OverlayAlignment.center);
    await FlutterOverlayWindow.shareData(message.data);
  });

  print('message2 remote ${message.notification?.body}');
  print('message remote ${message.notification?.title}');
}

class NotificationConfig {
  NotificationConfig._();
  static final NotificationConfig instant = NotificationConfig._();

// #region Properties

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high,
      playSound: true);

// #endregion

  Future init() async {
    if (Platform.operatingSystem == 'android') {
      _androidRegisterNotifications();
    } else if (Platform.operatingSystem == 'ios') {
      _iOSRegisterNotifications();
    }

    await getToken();
  }

  // #region Android initial setup

  _androidRegisterNotifications() async {
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
    final isActive = await FlutterOverlayWindow.isActive();
    if (isActive == true) {
      await FlutterOverlayWindow.closeOverlay();
    }
    await FlutterOverlayWindow.showOverlay(
        enableDrag: true,
        height: 300,
        width: 300,
        alignment: OverlayAlignment.center);
    await FlutterOverlayWindow.shareData(message.data);
    // add(PushNotificationHandleRemoteMessage(
    //     message: message, isForeground: true));

    // show custom dialog notification and sound
    if (Platform.operatingSystem == 'android') {
      String? titleMessage = message.notification?.title;
      String? bodyMessage = message.notification?.body;
      RemoteNotification? notification = message.notification;

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
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    _flutterLocalNotificationsPlugin.cancelAll();
    if (notification != null && android != null) {
      // show custom dialog notification and sound
      if (Platform.operatingSystem == 'android') {
        String? titleMessage = notification.title ?? '';
        String? bodyMessage = notification.body;
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
  }

  // #endregion

  // #region IOS initial setup
  _iOSRegisterNotifications() async {
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

  Future<void> _iosOnMessageForeground(RemoteMessage message) async {
    // add(PushNotificationHandleRemoteMessage(
    //     message: message, isForeground: true));
  }
  // #endregion

  // #region Method
  Future getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    // if (token != null) {
    //   // await _advertisementService.getTokenNotifi(token: token);
    // }
    debugPrint("firebase-token: $token");
    return token;
  }
  // #endregion
}
