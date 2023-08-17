import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:sdk_eums/common/const/values.dart';
import 'package:sdk_eums/common/constants.dart';
import 'package:sdk_eums/common/local_store/local_store.dart';
import 'package:sdk_eums/common/local_store/local_store_service.dart';
import 'package:sdk_eums/sdk_eums_library.dart';

import '../common/routing.dart';
import 'screen/watch_adver_module/watch_adver_screen.dart';

const String keepID = 'id_1';

const String navigationScreenId = 'id_2';

const String darwinNotificationCategoryPlain = 'EUMS_OFFERWALL';

class NotificationHandler {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
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
        DarwinNotificationAction.plain(
          keepID,
          'KEEP 하기',
        ),
        DarwinNotificationAction.plain(
          navigationScreenId,
          '광고 시청하기',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.foreground,
          },
        ),
      ],
      options: <DarwinNotificationCategoryOption>{
        DarwinNotificationCategoryOption.customDismissAction,
      },
    )
  ];

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    print("vao day");
  }

  initializeFcmNotification() async {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      notificationCategories: darwinNotificationCategories,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin);

    flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails()
        .then((value) {
      print("valuevalue${value}");
    });

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    try {
      debugPrint("s12312312");
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) {
          debugPrint("12312312312313zsczxczx");
          switch (notificationResponse.notificationResponseType) {
            case NotificationResponseType.selectedNotification:
              debugPrint("s12312312123123");
              break;
            case NotificationResponseType.selectedNotificationAction:
              debugPrint("s1231asdasdasd2312");
              if (notificationResponse.actionId == navigationScreenId) {
                debugPrint("s123134sfczczsc2312");
              }
              break;
          }
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );
    } catch (ex) {
      print("exexex$ex");
    }

    try {
      await _fcm.requestPermission(alert: false);
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
      
      CountAdver().initCount();
      FlutterBackgroundService().invoke("showOverlay", {'data': message.data});

      String? title = message.notification?.title ?? '';
      String? body = message.notification?.body ?? '';
    });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print("concac${await message.data}");
         print("concac${await message.notification?.body}");
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
  print("vao day khong");
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("vao nhe ennnnn ");

  // CronCustom().initCron();
  if (Platform.isAndroid) {
    CountAdver().initCount();
    FlutterBackgroundService().invoke("showOverlay", {'data': message.data});
  } else {}
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
