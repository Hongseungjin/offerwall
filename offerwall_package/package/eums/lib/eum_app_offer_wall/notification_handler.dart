import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:device_apps/device_apps.dart';
import 'package:eums/common/const/values.dart';
import 'package:eums/common/routing.dart';
import 'package:eums/eum_app_offer_wall/eums_app.dart';
import 'package:eums/eum_app_offer_wall/screen/keep_adverbox_module/keep_adverbox_module.dart';
import 'package:eums/method_native/eums_method_channel.dart';
import 'package:eums/notification/true_overlay_bloc/true_overlay_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:eums/common/local_store/local_store_service.dart';
import 'package:eums/eums_library.dart';
import 'package:package_info_plus/package_info_plus.dart';

const String keepID = 'keep';

const String navigationScreenId = 'open';

const String notificationChannelId = 'EUMS_OFFERWALL';

bool checkOnClick = false;

bool showDetailOfferwall = false;

int notificationId = 999;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

final StreamController<ReceivedNotification> didReceiveLocalNotificationStream = StreamController<ReceivedNotification>.broadcast();

// final StreamController<String?> selectNotificationStream = StreamController<String?>.broadcast();

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

  bool isCallKeep = false;

  NotificationDetails? notificationDetails;

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
      requestAlertPermission: false,
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

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

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
        debugPrint("====> flutterLocalNotificationsPlugin.initialize");

        await eventOpenNotification(notificationResponse);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    notificationDetails = getDetailNotification();

    // try {
    //   await _fcm.requestPermission(alert: false);
    // } catch (e) {}

    debugPrint("=====Firebase permission=====");
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: false,
    );
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: false,
      sound: false,
    );
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) async {
        if (message.data['updateLocation'] == "true") {
          FlutterBackgroundService().invoke('locationCurrent');
          // debugPrint("xxxx FirebaseMessaging.onMessage.listen =>>> ");
          // EumsApp.instant.locationCurrent();
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

            // debugPrint("${message.toMap()}");
            if (message.data['payload'] == null) return;
            final dataTemp = jsonDecode(message.data['payload']);

            if ((dataTemp['ad_type'] == "bee" || dataTemp['ad_type'] == "region") && isRunning == true) {
              await flutterLocalNotificationsPlugin.cancel(notificationId);
              // notificationDetails = getDetailNotification();

              if (Platform.isAndroid && showDetailOfferwall == false) {
                try {
                  // showOverlay(message.data['data']);
                  final checkPermission = await FlutterOverlayWindow.isPermissionGranted();
                  if (checkPermission == true) {
                    debugPrint("xxxxx - checkPermission ===> $checkPermission");
                    FlutterBackgroundService().invoke("showOverlay", {'data': dataTemp});
                  }
                } catch (e) {
                  rethrow;
                }
                // await EumsApp.instant.jobQueue({'data': message.data});
              }

              flutterLocalNotificationsPlugin.show(notificationId, '${message.data['title']}', '${message.data['body']}', notificationDetails,
                  payload: jsonEncode(dataTemp));
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
        // debugPrint("FirebaseMessaging.onMessageOpenedApp====> ${message.data}");
        debugPrint("======FirebaseMessaging.onMessageOpenedApp====");
        // final data = message.data;
        // data['isWebView'] = true;
        // FlutterBackgroundService().invoke("showOverlay", {'data': data});
      },
    );

    // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  static Future<String?> getToken() async {
    String? token;
    if (Platform.isIOS) {
      final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      debugPrint("====apnsToken====> $apnsToken");
      token = await FirebaseMessaging.instance.getToken();
    } else {
      token = await FirebaseMessaging.instance.getToken();
    }
    await LocalStoreService.instant.setDeviceToken(token);
    debugPrint('device-token: $token');
    return token;
  }

  NotificationDetails getDetailNotification() {
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
      presentAlert: true,
      interruptionLevel: InterruptionLevel.active,
    );
    const NotificationDetails notificationDetails = NotificationDetails(iOS: iosNotificationDetails, android: androidNotificationDetails);
    return notificationDetails;
  }

  Future<void> eventOpenNotification(NotificationResponse notificationResponse) async {
    try {
      final String? payload = notificationResponse.payload;
      // flutterLocalNotificationsPlugin.cancel(notificationId);
      await flutterLocalNotificationsPlugin.cancelAll();

      if (notificationResponse.payload != null) {
        final dataMessage = jsonDecode(payload ?? '');
        switch (notificationResponse.actionId) {
          case keepID:
            try {
              if (isCallKeep == true) return;
              isCallKeep = true;
              final data = dataMessage;

              ///ANDROID
              if (Platform.isAndroid) {
                final result = await EumsOfferWallServiceApi().saveKeep(
                  advertiseIdx: data['idx'],
                  adType: data['ad_type'],
                );
                if (result == true) {
                  debugPrint("eventOpenNotification====KEEP=====>SUCCESS");

                  dynamic dataToast = {};
                  dataToast['isToast'] = true;
                  dataToast['isWebView'] = false;
                  // dataToast['messageToast'] = "광고 보관 완료 후 3일 이내에 받아주세요";
                  dataToast['messageToast'] = "광고가 KEEP 추가";
                  FlutterBackgroundService().invoke("showOverlay", {'data': dataToast});
                  // await EumsApp.instant.jobQueue({'data': dataToast});
                } else {
                  debugPrint("eventOpenNotification====KEEP=====>FAIL");

                  dynamic dataToast = {};
                  dataToast['isToast'] = true;
                  dataToast['isWebView'] = false;
                  dataToast['messageToast'] = "일일저장량 초과 했습니다.";
                  FlutterBackgroundService().invoke("showOverlay", {'data': dataToast});
                }
              }

              ///IOS
              else {
                //  await TrueOverlayService().saveKeep(
                //     advertiseIdx: data['idx'],
                //     adType: data['ad_type'],
                //   );
                await EumsOfferWallServiceApi().saveKeep(
                  advertiseIdx: data['idx'],
                  adType: data['ad_type'],
                );
              }

              isCallKeep = false;

              // if (result == true) {
              //   debugPrint("eventOpenNotification====KEEP=====>SUCCESS");

              //   if (Platform.isAndroid) {
              //     dynamic dataToast = {};
              //     dataToast['isToast'] = true;
              //     dataToast['isWebView'] = false;
              //     // dataToast['messageToast'] = "광고 보관 완료 후 3일 이내에 받아주세요";
              //     dataToast['messageToast'] = "광고가 KEEP 추가";
              //     FlutterBackgroundService().invoke("showOverlay", {'data': dataToast});
              //     // await EumsApp.instant.jobQueue({'data': dataToast});
              //   } else {
              //     NotificationHandler.instant.methodToastIOS(title: "Eums success", body: "광고가 KEEP 되었습니다");
              //   }
              // } else {
              //   debugPrint("eventOpenNotification====KEEP=====>FAIL");

              //   if (Platform.isAndroid) {
              //     dynamic dataToast = {};
              //     dataToast['isToast'] = true;
              //     dataToast['isWebView'] = false;
              //     dataToast['messageToast'] = "일일저장량 초과 했습니다.";
              //     FlutterBackgroundService().invoke("showOverlay", {'data': dataToast});
              //   } else {
              //     NotificationHandler.instant.methodToastIOS(title: "Eums failure", body: "일일저장량 초과 했습니다");
              //   }
              // }
            } catch (ex) {
              if (Platform.isAndroid) {
                dynamic dataToast = {};
                dataToast['isToast'] = true;
                dataToast['isWebView'] = false;
                // dataToast['messageToast'] = "일일 저장량을 초과했습니다.";
                dataToast['messageToast'] = "$ex";
                FlutterBackgroundService().invoke("showOverlay", {'data': dataToast});
                // await EumsApp.instant.jobQueue({'data': dataToast});
              } else {
                // 'Eums failure',
                // '일일 저장량을 초과했습니다.',
                // _methodToastIOS(title: "Eums failure", body: "일일 저장량을 초과했습니다.");
                methodToastIOS(title: "Eums failure", body: "$ex");
              }
            }
            break;
          case navigationScreenId:
          default:
            if (dataMessage != null) {
              dataMessage['isWebView'] = true;
              if (Platform.isAndroid) {
                if (dataMessage != null) {
                  // FlutterBackgroundService().invoke("showOverlay", {'data': dataMessage});
                  // await EumsApp.instant.jobQueue({'data': dataMessage});
                  // final data = jsonDecode(dataMessage);
                  FlutterBackgroundService().invoke("closeOverlay");
                  dataMessage['advertiseIdx'] = dataMessage['idx'];
                  await LocalStoreService.instant.setDataShare(dataShare: dataMessage);

                  Future.delayed(
                    const Duration(seconds: 1),
                    () async {
                      await DeviceApps.openApp('com.app.abeeofferwal');
                    },
                  );
                  MethodChannelEums().openOverlay(dataMessage);
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
                dataMessage['advertiseIdx'] = dataMessage['idx'];
                Routings().navigate(
                    navigatorKeyMain.currentContext!,
                    DetailKeepScreen(
                      data: dataMessage,
                    ));
                // Routings().navigate(
                //     globalKeyMain.currentContext!,
                //     WatchAdverScreen(
                //       data: dataMessage['data'],
                //     ));
              }
            }

            break;
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await LocalStoreService.instant.init(); // await NotificationHandler.instant.initializeFcmNotification();
  debugPrint("====> notificationTapBackground");
  NotificationHandler.instant.eventOpenNotification(notificationResponse);
}

@pragma('vm:entry-point')
Future<bool> iosBackground(ServiceInstance serviceInstance) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  debugPrint("xxxx-iosBackground =====>");

  await LocalStoreService.instant.init();
  LocalStoreService.instant.preferences.reload();

  // service.on('showOverlay').listen((event) async {
  //   if (Platform.isAndroid) {
  //     queue.add(() async => await jobQueue(event));
  //     // NotificationHandler.instant.flutterLocalNotificationsPlugin.cancelAll();
  //   } else {}
  // });
  return true;
}

methodToastIOS({required String title, required String body}) async {
  debugPrint("methodToastIOS====> $title");
  const DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(
    categoryIdentifier: "EUMS_TOAST",
    presentAlert: true,
    interruptionLevel: InterruptionLevel.active,
  );
  NotificationDetails notificationDetails = const NotificationDetails(
    iOS: iosNotificationDetails,
  );
  await flutterLocalNotificationsPlugin.show(
    notificationId + 1,
    // 'Eums failure',
    // '일일 저장량을 초과했습니다.',
    title, body,
    notificationDetails,
  );
  // NotificationHandler.instant.timer = Timer(const Duration(seconds: 2), () async {
  //   await flutterLocalNotificationsPlugin.cancel(notificationId + 1);
  // });
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
