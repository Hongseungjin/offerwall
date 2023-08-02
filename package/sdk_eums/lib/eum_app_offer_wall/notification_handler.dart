import 'dart:async';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sdk_eums/common/local_store/local_store_service.dart';
import 'package:sdk_eums/common/routing.dart';
import 'package:sdk_eums/sdk_eums_library.dart';

import '../common/const/values.dart';
import 'screen/watch_adver_module/watch_adver_screen.dart';

const String navigationActionId = 'id_3';

const String darwinNotificationCategoryPlain = 'plainCategory';

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

  final List<DarwinNotificationCategory> darwinNotificationCategories =
      <DarwinNotificationCategory>[
    DarwinNotificationCategory(
      darwinNotificationCategoryPlain,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain('id_1', 'Action 1'),
        DarwinNotificationAction.plain(
          'id_2',
          'Action 2 (destructive)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.destructive,
          },
        ),
        DarwinNotificationAction.plain(
          navigationActionId,
          'Action 3 (foreground)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.foreground,
          },
        ),
        DarwinNotificationAction.plain(
          'id_4',
          'Action 4 (auth required)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.authenticationRequired,
          },
        ),
      ],
      options: <DarwinNotificationCategoryOption>{
        DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
      },
    )
  ];

  initializeFcmNotification() async {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
            onDidReceiveLocalNotification: (id, title, body, payload) {},
            notificationCategories: darwinNotificationCategories);

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (details) {
      switch (details.notificationResponseType) {
        case NotificationResponseType.selectedNotification:
          
          break;
        case NotificationResponseType.selectedNotificationAction:
          if (details.actionId == navigationActionId) {
          
          }
          break;
      }
    }, onDidReceiveBackgroundNotificationResponse: notificationTapBackground);
    try {
      await _fcm.requestPermission();
    } catch (e) {}

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);
    _fcm.getInitialMessage().then((value) {
      if (value != null) {
        onNavigateToMyEvent(data: value.data);
      }
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: $message");
      FlutterBackgroundService().invoke("showOverlay", {'data': message.data});
    });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print("onMessageOpenedApp: $message");
      onNavigateToMyEvent(data: message.data);
    });
  }

  onNavigateToMyEvent({dynamic data}) async {
    Routing().navigate(
        globalKeyMain.currentContext!,
        WatchAdverScreen(
          data: data['data'],
        ));
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
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  FlutterBackgroundService().invoke("showOverlay", {'data': message.data});
}
