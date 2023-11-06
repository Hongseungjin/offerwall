import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_apps/device_apps.dart';
import 'package:eums/common/const/values.dart';
import 'package:eums/common/routing.dart';
import 'package:eums/eum_app_offer_wall/screen/keep_adverbox_module/keep_adverbox_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:eums/common/local_store/local_store_service.dart';
import 'package:eums/eums_library.dart';

const String keepID = 'id_1';

const String navigationScreenId = 'id_2';

const String notificationChannelId = 'eums_background';
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
  NotificationHandler._();
  NotificationHandler();

  int notificationId = 999;

  static NotificationHandler instant = NotificationHandler._();

  final StreamController<ReceivedNotification> didReceiveLocalNotificationStream = StreamController<ReceivedNotification>.broadcast();

  final StreamController<String?> selectNotificationStream = StreamController<String?>.broadcast();

  // final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    darwinNotificationCategoryPlain,
    darwinNotificationCategoryPlain,
  );

  final List<DarwinNotificationCategory> darwinNotificationCategories = <DarwinNotificationCategory>[
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

  Future initializeFcmNotification() async {
    var initializationSettingsAndroid = const AndroidInitializationSettings('mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {
        // print("payloadpayloadpayloadpayloadpayload$payload");
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

    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsDarwin);

    // if (Platform.isIOS) {
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
    // }

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        await eventOpenNotification(notificationResponse);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // try {
    //   await _fcm.requestPermission(alert: false);
    // } catch (e) {}
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);

    const DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(
      categoryIdentifier: darwinNotificationCategoryPlain,
    );
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      darwinNotificationCategoryPlain,
      darwinNotificationCategoryPlain,
      importance: Importance.max,
      priority: Priority.high,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(keepID, 'KEEP 하기'),
        AndroidNotificationAction(
          navigationScreenId,
          '광고 시청하기',
        ),
      ],
    );
    NotificationDetails notificationDetails = const NotificationDetails(iOS: iosNotificationDetails, android: androidNotificationDetails);
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) async {
        if (message.from == "/topics/eums") {
          FlutterBackgroundService().invoke('locationCurrent');
        } else {
          try {
            final dataTemp = jsonDecode(message.data['data']);
            bool isRunning = true;

            if (Platform.isAndroid) {
              isRunning = await FlutterBackgroundService().isRunning();
            }

            if (isRunning == false &&
                LocalStoreService.instant.getAccessToken().isNotEmpty == true &&
                LocalStoreService.instant.getSaveAdver() == true) {
              await FlutterBackgroundService().startService();
              isRunning = await checkBackgroundService();
            }

            if ((dataTemp['ad_type'] == "bee" || dataTemp['ad_type'] == "region") && isRunning == true) {
              // await NotificationHandler.instant.flutterLocalNotificationsPlugin.cancelAll();
              await NotificationHandler.instant.flutterLocalNotificationsPlugin.cancel(NotificationHandler.instant.notificationId);

              if (Platform.isAndroid) {
                // CountAdver().initCount();
                FlutterBackgroundService().invoke("showOverlay", {'data': message.data});
              }
              Future.delayed(
                const Duration(seconds: 1),
                () {
                  flutterLocalNotificationsPlugin.show(
                      NotificationHandler.instant.notificationId, '${message.data['title']}', '${message.data['body']}', notificationDetails,
                      payload: jsonEncode(message.data));
                },
              );
            }
            // ignore: empty_catches
          } catch (e) {}
        }
      },
    );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) async {
        // final data = message.data;
        // data['isWebView'] = true;
        // FlutterBackgroundService().invoke("showOverlay", {'data': data});
      },
    );
  }

  Future<void> eventOpenNotification(NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      final dataMessage = jsonDecode(payload ?? '');
      switch (notificationResponse.actionId) {
        // case navigationScreenId:
        //   // onNavigateToMyEvent(data: jsonDecode(payload ?? ''));
        //   Routings().navigate(
        //       globalKeyMain.currentContext!,
        //       WatchAdverScreen(
        //         data: dataMessage['data'],
        //       ));
        //   break;
        case keepID:
          try {
            NotificationHandler.instant.flutterLocalNotificationsPlugin.cancel(notificationId);
            final data = jsonDecode(dataMessage['data']);
            await EumsOfferWallServiceApi().saveKeep(advertiseIdx: data['idx'], adType: data['ad_type']);

            if (Platform.isAndroid) {
              // bool isActive = await FlutterOverlayWindow.isActive();
              // if (isActive == true) {
              //   await FlutterOverlayWindow.closeOverlay();

              // }
              dynamic dataToast = {};
              dataToast['isToast'] = true;
              dataToast['isWebView'] = null;
              // dataToast['messageToast'] = "광고 보관 완료 후 3일 이내에 받아주세요";
              dataToast['messageToast'] = "광고가 KEEP 추가";
              FlutterBackgroundService().invoke("showOverlay", {'data': dataToast});
            } else {
              const DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(
                categoryIdentifier: darwinNotificationCategoryPlain,
              );
              NotificationDetails notificationDetails = const NotificationDetails(
                iOS: iosNotificationDetails,
              );
              flutterLocalNotificationsPlugin.show(
                NotificationHandler.instant.notificationId + 1,
                'Eums success',
                '광고가 KEEP 되었습니다',
                notificationDetails,
              );

              Future.delayed(
                const Duration(seconds: 2),
                () {
                  NotificationHandler.instant.flutterLocalNotificationsPlugin.cancel(NotificationHandler.instant.notificationId + 1);
                },
              );
            }
          } catch (ex) {
            dynamic dataToast = {};
            dataToast['isToast'] = true;
            dataToast['isWebView'] = null;
            dataToast['messageToast'] = "일일 저장량을 초과했습니다.";
            if (Platform.isAndroid) {
              FlutterBackgroundService().invoke("showOverlay", {'data': dataToast});
            } else {
              const DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(
                categoryIdentifier: darwinNotificationCategoryPlain,
              );
              NotificationDetails notificationDetails = const NotificationDetails(
                iOS: iosNotificationDetails,
              );
              flutterLocalNotificationsPlugin.show(
                NotificationHandler.instant.notificationId + 1,
                'Eums failure',
                '일일 저장량을 초과했습니다.',
                notificationDetails,
              );

              Future.delayed(
                const Duration(seconds: 2),
                () {
                  NotificationHandler.instant.flutterLocalNotificationsPlugin.cancel(NotificationHandler.instant.notificationId + 1);
                },
              );
            }
          }
          break;
        case navigationScreenId:
        default:
          NotificationHandler.instant.flutterLocalNotificationsPlugin.cancel(notificationId);
          if (dataMessage != null) {
            dataMessage['isWebView'] = true;
          }
          if (Platform.isAndroid) {
            if (dataMessage != null) {
              FlutterBackgroundService().invoke("showOverlay", {'data': dataMessage});
            } else {
              FlutterBackgroundService().invoke("closeOverlay");
            }
          }
          if (Platform.isIOS) {
            if (navigatorKeyMain.currentContext == null) {
              await DeviceApps.openApp('com.app.abeeofferwal');
            }
            final data = jsonDecode(dataMessage['data']);
            data['advertiseIdx'] = data['idx'];
            Routings().navigate(
                navigatorKeyMain.currentContext!,
                DetailKeepScreen(
                  data: data,
                ));
            // Routings().navigate(
            //     globalKeyMain.currentContext!,
            //     WatchAdverScreen(
            //       data: dataMessage['data'],
            //     ));
          }

          break;
      }
    }
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

  // onNavigateToMyEvent({dynamic data}) async {
  //   Routings().navigate(
  //       globalKeyMain.currentContext!,
  //       WatchAdverScreen(
  //         data: data['data'],
  //       ));
  // }

  getToken() async {
    String? token;
    // if (Platform.isIOS) {
    //   token = await _fcm.getAPNSToken();
    // } else {
    token = await FirebaseMessaging.instance.getToken();
    // }
    await LocalStoreService.instant.setDeviceToken(token);
    debugPrint('device-token: $token');
    return token;
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {
  await Firebase.initializeApp();
  await LocalStoreService.instant.init();
  NotificationHandler.instant.eventOpenNotification(notificationResponse);
  // final String? payload = notificationResponse.payload;
  // if (notificationResponse.payload != null) {
  //   // debugPrint('notification payload: ${jsonDecode(payload ?? '')}');
  //   final dataMessage = jsonDecode(payload ?? '');
  //   switch (notificationResponse.actionId) {
  //     case keepID:
  //       try {
  //         EumsOfferWallServiceApi().saveKeep(advertiseIdx: jsonDecode(dataMessage['data'])['idx']);
  //         if (Platform.isAndroid) {
  //           bool isActive = await FlutterOverlayWindow.isActive();
  //           if (isActive == true) {
  //             await FlutterOverlayWindow.closeOverlay();
  //           }
  //         }
  //         // ignore: empty_catches
  //       } catch (ex) {}
  //       break;
  //     case navigationScreenId:
  //     default:
  //       if (dataMessage != null) {
  //         dataMessage['isWebView'] = true;
  //         FlutterBackgroundService().invoke("showOverlay", {'data': dataMessage});
  //       } else {
  //         FlutterBackgroundService().invoke("closeOverlay");
  //       }
  //       break;
  //   }
  //   // if (notificationResponse.actionId == keepID) {
  //   //   try {
  //   //     EumsOfferWallServiceApi().saveKeep(advertiseIdx: jsonDecode(jsonDecode(payload ?? '')['data'])['idx']);
  //   //     if (Platform.isAndroid) {
  //   //       bool isActive = await FlutterOverlayWindow.isActive();
  //   //       if (isActive == true) {
  //   //         await FlutterOverlayWindow.closeOverlay();
  //   //       }
  //   //     }
  //   //   } catch (ex) {
  //   //     print('exexex$ex');
  //   //   }
  //   // }
  // }
  // // print('notification(${notificationResponse.id}) action tapped: '
  // //     '${notificationResponse.actionId} with'
  // //     ' payload: ${notificationResponse.payload}');
  // // if (notificationResponse.input?.isNotEmpty ?? false) {
  // //   // ignore: avoid_print
  // //   print(
  // //       'notification action tapped with input: ${notificationResponse.input}');
  // // }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await LocalStoreService.instant.init();
  if (message.from == "/topics/eums") {
    FlutterBackgroundService().invoke('locationCurrent');
  } else {
// NotificationHandler.instant.initializeFcmNotification();
    try {
      final dataTemp = jsonDecode(message.data['data']);
      bool isRunning = true;

      if (Platform.isAndroid) {
        isRunning = await FlutterBackgroundService().isRunning();
      }
      if (isRunning == false && LocalStoreService.instant.getAccessToken().isNotEmpty == true && LocalStoreService.instant.getSaveAdver() == true) {
        await FlutterBackgroundService().startService();
        isRunning = await checkBackgroundService();
      }
      if ((dataTemp['ad_type'] == "bee" || dataTemp['ad_type'] == "region") && isRunning == true) {
        await NotificationHandler.instant.flutterLocalNotificationsPlugin.cancel(NotificationHandler.instant.notificationId);

        const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
          darwinNotificationCategoryPlain,
          darwinNotificationCategoryPlain,
          importance: Importance.max,
          priority: Priority.high,
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction(keepID, 'KEEP 하기'),
            AndroidNotificationAction(
              navigationScreenId,
              '광고 시청하기',
            ),
          ],
        );

        const DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(
          categoryIdentifier: darwinNotificationCategoryPlain,
        );
        const NotificationDetails notificationDetails = NotificationDetails(iOS: iosNotificationDetails, android: androidNotificationDetails);

        // CronCustom().initCron();
        if (Platform.isAndroid) {
          // await NotificationHandler.instant.flutterLocalNotificationsPlugin.cancelAll();
          // CountAdver().initCount();
          FlutterBackgroundService().invoke("showOverlay", {'data': message.data});
        }
        Future.delayed(
          const Duration(seconds: 1),
          () {
            NotificationHandler.instant.flutterLocalNotificationsPlugin.show(
                NotificationHandler.instant.notificationId, '${message.data['title']}', '${message.data['body']}', notificationDetails,
                payload: jsonEncode(message.data));
          },
        );
      }
      // ignore: empty_catches
    } catch (e) {}
  }
}

class CountAdver {
  // final LocalStore _localStore = LocalStoreService();
  // var countAdvertisement = 0;
  // dynamic dataCount;
  String dateCount = '';
  String dateNow = '';
  bool isActive = false;
  initCount() async {
    await Firebase.initializeApp();
    await LocalStoreService.instant.init();
    // dataCount = await _localStore.getCountAdvertisement();
    // countAdvertisement = dataCount['count'] ?? 0;
    // isActive = await _localStore.getSaveAdver();
    // print("countAdvertisement$countAdvertisement $isActive");

    // 50
    // if (countAdvertisement == 5) {
    //   print("remove tokem");

    //   String? token = await FirebaseMessaging.instance.getToken();
    //   if (token != null && token.isNotEmpty) {
    //     FlutterBackgroundService().invoke("stopService");
    //     await EumsOfferWallServiceApi().unRegisterTokenNotifi(token: token);
    //     _localStore.setSaveAdver(true);
    //   }
    // }

    // if (dataCount == '{}') {
    //   dynamic data = <String, dynamic>{
    //     'count': 1,
    //     'date': Constants.formatTime(DateTime.now().toIso8601String()),
    //   };
    //   _localStore.setCountAdvertisement(data);
    // } else {
    //   if (!isActive) {
    //     countAdvertisement++;
    //     dynamic data = <String, dynamic>{
    //       'count': countAdvertisement,
    //       'date': Constants.formatTime(DateTime.now().toIso8601String()),
    //     };
    //     print("datadata$data");
    //     _localStore.setCountAdvertisement(data);
    //   }
    // }
  }

  // checkDate() async {
  //   await Firebase.initializeApp();
  //   // try {
  //   //   dataCount = await _localStore.getCountAdvertisement();
  //   //   dateCount = dataCount['date'] ?? '';
  //   //   countAdvertisement = dataCount['count'] ?? 0;
  //   //   dateNow = Constants.formatTime(DateTime.now().toIso8601String());
  //   //   // print("countAdvertisement${countAdvertisement}");
  //   // } catch (ex) {
  //   //   print("exexexex$ex");
  //   // }

  //   // if (dateCount == dateNow) {
  //   //   /// ngày hiện tại
  //   //   if (countAdvertisement < 50) {}
  //   // } else {
  //   //   // ngày tiếp theo
  //   //   dynamic data = <String, dynamic>{
  //   //     'count': 0,
  //   //     'date': Constants.formatTime(DateTime.now().toIso8601String()),
  //   //   };
  //   //   String? token = await FirebaseMessaging.instance.getToken();
  //   //   if (token != null && token.isNotEmpty) {
  //   //     await EumsOfferWallServiceApi().createTokenNotifi(token: token);
  //   //     _localStore.setSaveAdver(false);
  //   //   }
  //   //   _localStore.setCountAdvertisement(data);
  //   // }
  // }
}

Future<bool> checkBackgroundService() async {
  bool isRunning = await FlutterBackgroundService().isRunning();
  await Future.delayed(const Duration(seconds: 2));
  if (isRunning == false) {
    return checkBackgroundService();
  } else {
    return isRunning;
  }
}
