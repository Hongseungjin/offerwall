import 'dart:async';
import 'dart:convert';
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

bool checkOnClick = false;

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

class NotificationHandler {
  final StreamController<ReceivedNotification>
      didReceiveLocalNotificationStream =
      StreamController<ReceivedNotification>.broadcast();

  final StreamController<String?> selectNotificationStream =
      StreamController<String?>.broadcast();

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
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.destructive,
          },
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

  initializeFcmNotification() async {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        print("payloadpayloadpayloadpayloadpayload$payload");
        didReceiveLocalNotificationStream.add(
          ReceivedNotification(
            id: id,
            title: title,
            body: body,
            payload: payload,
          ),
        );
      },
      notificationCategories: darwinNotificationCategories,
    );

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin);

    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        final String? payload = notificationResponse.payload;
        if (notificationResponse.payload != null) {
          print(notificationResponse.actionId);
          debugPrint('notification payload: ${jsonDecode(payload ?? '')}');
          if (notificationResponse.actionId == navigationScreenId) {
            onNavigateToMyEvent(data: jsonDecode(payload ?? ''));
          }
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    try {
      await _fcm.requestPermission(alert: false);
    } catch (e) {}
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      categoryIdentifier: darwinNotificationCategoryPlain,
    );
    const NotificationDetails notificationDetails = NotificationDetails(
      iOS: iosNotificationDetails,
    );

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        print("co vao day khong123123 ${message.data}");
        if (Platform.isAndroid) {
          CountAdver().initCount();
          FlutterBackgroundService()
              .invoke("showOverlay", {'data': message.data});
        }
        flutterLocalNotificationsPlugin.show(0, '${message.data['title']}',
            '${message.data['body']}', notificationDetails,
            payload: jsonEncode(message.data));
      },
    );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) async {},
    );
  }

  // onSelectNotification(NotificationResponse notificationResponse) async {
  //   print('payload ${notificationResponse.payload}');
  //   if (notificationResponse.payload != null &&
  //       notificationResponse.payload!.isNotEmpty) {
  //     print('payloadssss $notificationResponse');
  //   }
  //   switch (notificationResponse.notificationResponseType) {
  //     case NotificationResponseType.selectedNotification:
  //       selectNotificationStream.add(notificationResponse.payload);
  //       break;
  //     case NotificationResponseType.selectedNotificationAction:
  //       print("cos vao day khong");
  //       if (notificationResponse.actionId == navigationScreenId) {
  //         selectNotificationStream.add(notificationResponse.payload);
  //         print("cos vao day khonsadasdasdg");
  //       } else {
  //         print("cos vao day khongasaaaaa ${notificationResponse.payload}");
  //       }
  //       break;
  //   }
  // }

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
  if (notificationResponse.actionId == keepID) {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: ${jsonDecode(payload ?? '')}');
      if (notificationResponse.actionId == keepID) {
        try {
          EumsOfferWallServiceApi().saveKeep(
              advertiseIdx:
                  jsonDecode(jsonDecode(payload ?? '')['data'])['idx']);
        } catch (ex) {
          print('exexex$ex');
        }
      }
    }
  }
  // print('notification(${notificationResponse.id}) action tapped: '
  //     '${notificationResponse.actionId} with'
  //     ' payload: ${notificationResponse.payload}');
  // if (notificationResponse.input?.isNotEmpty ?? false) {
  //   // ignore: avoid_print
  //   print(
  //       'notification action tapped with input: ${notificationResponse.input}');
  // }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("vao nhe ennnnn ");
  const DarwinNotificationDetails iosNotificationDetails =
      DarwinNotificationDetails(
    categoryIdentifier: darwinNotificationCategoryPlain,
  );
  const NotificationDetails notificationDetails = NotificationDetails(
    iOS: iosNotificationDetails,
  );

  // CronCustom().initCron();
  if (Platform.isAndroid) {
    CountAdver().initCount();
    FlutterBackgroundService().invoke("showOverlay", {'data': message.data});
  } else {
    NotificationHandler().flutterLocalNotificationsPlugin.show(
        0,
        '${message.data['title']}',
        '${message.data['body']}',
        notificationDetails,
        payload: jsonEncode(message.data));
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
