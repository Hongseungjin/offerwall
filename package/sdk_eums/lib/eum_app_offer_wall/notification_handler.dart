import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:sdk_eums/common/constants.dart';
import 'package:sdk_eums/common/local_store/local_store.dart';
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
            requestAlertPermission: false,
            defaultPresentAlert: false,
            onDidReceiveLocalNotification: (id, title, body, payload) {
              print("object");
            },
            notificationCategories: darwinNotificationCategories);

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin);
    if (Platform.isAndroid) {
      _flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onDidReceiveNotificationResponse: (details) {
        switch (details.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            break;
          case NotificationResponseType.selectedNotificationAction:
            if (details.actionId == navigationActionId) {}
            break;
        }
      }, onDidReceiveBackgroundNotificationResponse: notificationTapBackground);
    }

    try {
      await _fcm.requestPermission(alert: false);
    } catch (e) {}

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: Platform.isAndroid ? true : false, badge: true, sound: true);
    _fcm.getInitialMessage().then((value) {
      if (value != null) {
        onNavigateToMyEvent(data: value.data);
      }
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: $message");
      CountAdver().initCount();
      FlutterBackgroundService().invoke("showOverlay", {'data': message.data});
   
      String? title = message.notification?.title ?? '';
      String? body = message.notification?.body ?? '';
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
  print("vao nhe ennnnn ");
  CountAdver().initCount();
  // CronCustom().initCron();
  if (Platform.isAndroid) {
    FlutterBackgroundService().invoke("showOverlay", {'data': message.data});
  } else {
    print("vao day khong");
  
  }
}

class CountAdver {
  final LocalStore _localStore = LocalStoreService();
  var countAdvertisement = 0;
  dynamic dataCount;
  String dateCount = '';
  String dateNow = '';
  bool isActive = false;
  initCount() async {
    await Firebase.initializeApp();
    dataCount = await _localStore.getCountAdvertisement();
    countAdvertisement = dataCount['count'] ?? 0;
    isActive = await _localStore.getSaveAdver();
    print("countAdvertisement${countAdvertisement} ${isActive}");

    // 50
    if (countAdvertisement == 5) {
      print("remove tokem");

      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        FlutterBackgroundService().invoke("stopService");
        await EumsOfferWallServiceApi().unRegisterTokenNotifi(token: token);
        _localStore.setSaveAdver(true);
      }
    }

    if (dataCount == '{}') {
      dynamic data = <String, dynamic>{
        'count': 1,
        'date': Constants.formatTime(DateTime.now().toIso8601String()),
      };
      _localStore.setCountAdvertisement(data);
    } else {
      if (!isActive) {
        countAdvertisement++;
        dynamic data = <String, dynamic>{
          'count': countAdvertisement,
          'date': Constants.formatTime(DateTime.now().toIso8601String()),
        };
        print("datadata${data}");
        _localStore.setCountAdvertisement(data);
      }
    }
  }

  checkDate() async {
    await Firebase.initializeApp();
    try {
      dataCount = await _localStore.getCountAdvertisement();
      dateCount = dataCount['date'] ?? '';
      countAdvertisement = dataCount['count'] ?? 0;
      dateNow = Constants.formatTime(DateTime.now().toIso8601String());
      // print("countAdvertisement${countAdvertisement}");
    } catch (ex) {
      print("exexexex${ex}");
    }

    if (dateCount == dateNow) {
      /// ngày hiện tại
      if (countAdvertisement < 50) {}
    } else {
      // ngày tiếp theo
      dynamic data = <String, dynamic>{
        'count': 0,
        'date': Constants.formatTime(DateTime.now().toIso8601String()),
      };
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await EumsOfferWallServiceApi().createTokenNotifi(token: token);
        _localStore.setSaveAdver(false);
      }
      _localStore.setCountAdvertisement(data);
    }
  }
}
