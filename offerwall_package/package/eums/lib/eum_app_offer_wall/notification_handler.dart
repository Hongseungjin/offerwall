import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:device_apps/device_apps.dart';
import 'package:eums/common/const/values.dart';
import 'package:eums/common/routing.dart';
import 'package:eums/eum_app_offer_wall/eums_app.dart';
import 'package:eums/eum_app_offer_wall/screen/keep_adverbox_module/keep_adverbox_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:eums/common/local_store/local_store_service.dart';
import 'package:eums/eums_library.dart';
import 'package:package_info_plus/package_info_plus.dart';

const String keepID = 'id_1';

const String navigationScreenId = 'id_2';

const String notificationChannelId = 'EUMS_OFFERWALL';

bool checkOnClick = false;

bool showDetailOfferwall = false;

int notificationId = 999;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

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
  // NotificationHandler();

  static NotificationHandler instant = NotificationHandler._();

  final StreamController<ReceivedNotification> didReceiveLocalNotificationStream = StreamController<ReceivedNotification>.broadcast();

  final StreamController<String?> selectNotificationStream = StreamController<String?>.broadcast();

  // final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    notificationChannelId,
    notificationChannelId,
    playSound: false,
    enableVibration: false,
    enableLights: false,
  );

  final List<DarwinNotificationCategory> darwinNotificationCategories = <DarwinNotificationCategory>[
    DarwinNotificationCategory(
      notificationChannelId,
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
    // var initializationSettingsAndroid = const AndroidInitializationSettings('mipmap/ic_launcher');
    var initializationSettingsAndroid = const AndroidInitializationSettings('drawable/ic_bg_service_small');

    final DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {
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

    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
          alert: true,
          badge: true,
          sound: false,
        );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

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
    await FirebaseMessaging.instance.requestPermission(
      alert: false,
      announcement: false,
      badge: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: false,
    );
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) async {
        if (message.data['updateLocation'] == "true") {
          // FlutterBackgroundService().invoke('locationCurrent');
          debugPrint("xxxx FirebaseMessaging.onMessage.listen =>>> ");
          EumsApp.instant.locationCurrent();
        } else {
          try {
            bool isRunning = true;

            // if (Platform.isAndroid) {
            //   isRunning = await FlutterBackgroundService().isRunning();
            //   if (isRunning == false &&
            //       LocalStoreService.instant.getAccessToken().isNotEmpty == true &&
            //       LocalStoreService.instant.getSaveAdver() == true) {
            //     await FlutterBackgroundService().startService();
            //     isRunning = await checkBackgroundService();
            //   }
            // }

            if (LocalStoreService.instant.getAccessToken().isNotEmpty == false || LocalStoreService.instant.getSaveAdver() == false) {
              isRunning = false;
            }

            debugPrint("${message.toMap()}");
            final dataTemp = jsonDecode(message.data['data']);

            if ((dataTemp['ad_type'] == "bee" || dataTemp['ad_type'] == "region") && isRunning == true) {
              await flutterLocalNotificationsPlugin.cancel(notificationId);

              if (Platform.isAndroid && showDetailOfferwall == false) {
                try {
                  final checkPermission = await FlutterOverlayWindow.isPermissionGranted();
                  if (checkPermission == true) {
                    debugPrint("xxxxx - checkPermission ===> $checkPermission");
                    FlutterBackgroundService().invoke("showOverlay", {'data': message.data});
                  }
                } catch (e) {
                  rethrow;
                }
                // await EumsApp.instant.jobQueue({'data': message.data});
              }

              flutterLocalNotificationsPlugin.show(notificationId, '${message.data['title']}', '${message.data['body']}', getDetailNotification(),
                  payload: jsonEncode(message.data));
            }
            // ignore: empty_catches
          } catch (e) {
            rethrow;
          }
        }
      },
    );

    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) async {
        debugPrint("xxx");
        // final data = message.data;
        // data['isWebView'] = true;
        // FlutterBackgroundService().invoke("showOverlay", {'data': data});
      },
    );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  Future<void> eventOpenNotification(NotificationResponse notificationResponse) async {
    try {
      final String? payload = notificationResponse.payload;
      flutterLocalNotificationsPlugin.cancel(notificationId);
      if (notificationResponse.payload != null) {
        final dataMessage = jsonDecode(payload ?? '');
        switch (notificationResponse.actionId) {
          case keepID:
            try {
              final data = jsonDecode(dataMessage['data']);
              final result = await EumsOfferWallServiceApi().saveKeep(advertiseIdx: data['idx'], adType: data['ad_type']);
              if (result == true) {
                if (Platform.isAndroid) {
                  dynamic dataToast = {};
                  dataToast['isToast'] = true;
                  dataToast['isWebView'] = false;
                  // dataToast['messageToast'] = "광고 보관 완료 후 3일 이내에 받아주세요";
                  dataToast['messageToast'] = "광고가 KEEP 추가";
                  FlutterBackgroundService().invoke("showOverlay", {'data': dataToast});
                  // await EumsApp.instant.jobQueue({'data': dataToast});
                } else {
                  _methodToastIOS(title: "Eums success", body: "광고가 KEEP 되었습니다");
                }
              } else {
                if (Platform.isAndroid) {
                  dynamic dataToast = {};
                  dataToast['isToast'] = true;
                  dataToast['isWebView'] = false;
                  // dataToast['messageToast'] = "광고 보관 완료 후 3일 이내에 받아주세요";
                  dataToast['messageToast'] = "광고가 KEEP 추가";
                  FlutterBackgroundService().invoke("showOverlay", {'data': dataToast});
                  // await EumsApp.instant.jobQueue({'data': dataToast});
                } else {
                  _methodToastIOS(title: "Eums success", body: "광고가 KEEP 되었습니다");
                }
              }
            } catch (ex) {
              if (Platform.isAndroid) {
                dynamic dataToast = {};
                dataToast['isToast'] = true;
                dataToast['isWebView'] = false;
                // dataToast['messageToast'] = "일일 저장량을 초과했습니다.";
                dataToast['messageToast'] = "일일저장량 초과 했습니다.";
                FlutterBackgroundService().invoke("showOverlay", {'data': dataToast});
                // await EumsApp.instant.jobQueue({'data': dataToast});
              } else {
                // 'Eums failure',
                // '일일 저장량을 초과했습니다.',
                // _methodToastIOS(title: "Eums failure", body: "일일 저장량을 초과했습니다.");
                _methodToastIOS(title: "Eums failure", body: "일일저장량 초과 했습니다.");
              }
            }
            break;
          case navigationScreenId:
          default:
            if (dataMessage != null) {
              dataMessage['isWebView'] = true;
            }
            if (Platform.isAndroid) {
              if (dataMessage != null) {
                FlutterBackgroundService().invoke("showOverlay", {'data': dataMessage});
                // await EumsApp.instant.jobQueue({'data': dataMessage});
              } else {
                FlutterBackgroundService().invoke("closeOverlay");
                // await EumsApp.instant.closeOverlay();
              }
            }
            if (Platform.isIOS) {
              if (navigatorKeyMain.currentContext == null) {
                PackageInfo packageInfo = await PackageInfo.fromPlatform();
                String packageName = packageInfo.packageName;
                await DeviceApps.openApp(packageName);
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
    } catch (e) {}
  }

  void _methodToastIOS({required String title, required String body}) {
    const DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(
      categoryIdentifier: notificationChannelId,
    );
    NotificationDetails notificationDetails = const NotificationDetails(
      iOS: iosNotificationDetails,
    );
    flutterLocalNotificationsPlugin.show(
      notificationId + 1,
      // 'Eums failure',
      // '일일 저장량을 초과했습니다.',
      title, body,
      notificationDetails,
    );

    Future.delayed(
      const Duration(seconds: 2),
      () {
        flutterLocalNotificationsPlugin.cancel(notificationId + 1);
      },
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

  // onNavigateToMyEvent({dynamic data}) async {
  //   Routings().navigate(
  //       globalKeyMain.currentContext!,
  //       WatchAdverScreen(
  //         data: data['data'],
  //       ));
  // }

  static Future<String?> getToken() async {
    String? token;
    if (Platform.isIOS) {
      await FirebaseMessaging.instance.getAPNSToken();
      token = await FirebaseMessaging.instance.getToken();
    } else {
      token = await FirebaseMessaging.instance.getToken();
    }
    await LocalStoreService.instant.setDeviceToken(token);
    debugPrint('device-token: $token');
    return token;
  }

  static NotificationDetails getDetailNotification() {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      notificationChannelId,
      notificationChannelId,
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: false,
      enableLights: false,
      playSound: false,
      // ongoing: true,
      color: Color(0xffFF8E29),
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          keepID,
          'KEEP 하기',
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          navigationScreenId,
          '광고 시청하기',
          cancelNotification: true,
        ),
      ],
    );

    const DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(
      categoryIdentifier: notificationChannelId,
      presentSound: false,
      interruptionLevel: InterruptionLevel.active,
    );
    const NotificationDetails notificationDetails = NotificationDetails(iOS: iosNotificationDetails, android: androidNotificationDetails);
    return notificationDetails;
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await LocalStoreService.instant.init();
  // await NotificationHandler.instant.initializeFcmNotification();
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
Future<bool> iosBackground(ServiceInstance serviceInstance) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  debugPrint("xxxx-iosBackground =====>");
  return true;
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await LocalStoreService.instant.init();
  // await NotificationHandler.instant.flutterLocalNotificationsPlugin.cancelAll();

  // await FlutterBackgroundService().startService();
  // FlutterBackgroundService().invoke("showNotification", message.data);

  if (message.data['updateLocation'] == "true") {
    debugPrint("topics/eums : ${message.toMap()}");
    // EumsApp.instant.locationCurrent();
  } else {
    try {
      debugPrint("xxxx--message: ${message.toMap()}");
      // EumsApp.instant.locationCurrent();

      final dataTemp = jsonDecode(message.data['data']);
      bool isRunning = true;
      // if (Platform.isAndroid) {
      //   isRunning = await FlutterBackgroundService().isRunning();
      //   debugPrint("xxxx--isRunning: $isRunning");
      //   if (isRunning == false && LocalStoreService.instant.getAccessToken().isNotEmpty == true && LocalStoreService.instant.getSaveAdver() == true) {
      //     await FlutterBackgroundService().startService();
      //     // isRunning = await checkBackgroundService();
      //   }
      // }

      if (LocalStoreService.instant.getAccessToken().isNotEmpty == false || LocalStoreService.instant.getSaveAdver() == false) {
        isRunning = false;
      }

      if ((dataTemp['ad_type'] == "bee" || dataTemp['ad_type'] == "region") && isRunning == true) {
        try {
          flutterLocalNotificationsPlugin.cancel(notificationId);
        } catch (error) {
          flutterLocalNotificationsPlugin.cancelAll();
        }

        if (Platform.isAndroid) {
          try {
            final checkPermission = await FlutterOverlayWindow.isPermissionGranted();
            if (checkPermission == true) {
              debugPrint("xxxxx - checkPermission ===> $checkPermission");
              FlutterBackgroundService().invoke("showOverlay", {'data': message.data});
            }
          } catch (e) {
            rethrow;
          }
        }

        try {
          flutterLocalNotificationsPlugin.show(
              notificationId, '${message.data['title']}', '${message.data['body']}', NotificationHandler.getDetailNotification(),
              payload: jsonEncode(message.data));
        } catch (e) {
          rethrow;
        }
      }
      // ignore: empty_catches
    } catch (e) {
      // "reason" will append the word "thrown" in the
      // Crashlytics console.
      print("xxxxx-notification:$e");
      rethrow;
    }
  }
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
