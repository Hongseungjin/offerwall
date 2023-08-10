import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:awesome_notifications_fcm/awesome_notifications_fcm.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:sdk_eums/common/const/values.dart';
import 'package:sdk_eums/common/routing.dart';

import 'screen/watch_adver_module/watch_adver_screen.dart';

class PushNotificationCustom extends ChangeNotifier {
  ReceivedAction? initialAction;
  initializeFcmNotification() async {
    AwesomeNotifications().initialize(
        // set the icon to null if you want to use the default app icon
        'resource://drawable/res_app_icon',
        [
          NotificationChannel(
              channelGroupKey: 'basic_channel_group',
              channelKey: 'basic_channel',
              channelName: 'Basic notifications',
              channelDescription: 'Notification channel for basic tests',
              defaultColor: Color(0xFF9D50DD),
              ledColor: Colors.white)
        ],
        // Channel groups are only visual and are not required
        channelGroups: [
          NotificationChannelGroup(
            channelGroupKey: 'basic_channel_group',
            channelGroupName: 'Basic group',
          )
        ],
        debug: true);
    initialAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: false);
  }

  static Future<void> scheduleNewNotification({dynamic remoteMessage}) async {
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: remoteMessage.hashCode,
            body: remoteMessage?.notification?.body ?? "",
            title: remoteMessage?.notification?.title ?? "",
            channelKey: 'basic_channel',
            bigPicture: 'asset://assets/images/android-bg-worker.jpg',
            notificationLayout: NotificationLayout.BigPicture,
            payload: {"data": remoteMessage?.data['data']},
            category: NotificationCategory.Service),
        schedule: NotificationCalendar.fromDate(
            date: DateTime.now().add(const Duration(milliseconds: 500))),
        actionButtons: [
          NotificationActionButton(key: 'KEPP_ADVER', label: 'KEEP 하기'),
          NotificationActionButton(key: 'SHOW_ADVER', label: '광고 시청하기')
        ]);
  }

  static Future<void> getInitialNotificationAction() async {
    ReceivedAction? receivedAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: true);
    if (receivedAction == null) return;
    print('Notification action launched app: $receivedAction');
  }

  static Future<void> initializeNotificationListeners() async {
    await AwesomeNotifications().setListeners(
        onActionReceivedMethod: PushNotificationCustom.onActionReceivedMethod,
        onNotificationCreatedMethod:
            PushNotificationCustom.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:
            PushNotificationCustom.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:
            PushNotificationCustom.onDismissActionReceivedMethod);
  }

  static Future<void> initializeRemoteNotifications(
      {required bool debug}) async {
    await Firebase.initializeApp();
    await AwesomeNotificationsFcm().initialize(
        onFcmSilentDataHandle: PushNotificationCustom.mySilentDataHandle,
        onFcmTokenHandle: PushNotificationCustom.myFcmTokenHandle,
        onNativeTokenHandle: PushNotificationCustom.myNativeTokenHandle,
        licenseKeys: null,
        // licenseKeys: [
        //   // me.carda.awesomeNotificationsFcmExample
        //   'B3J3yxQbzzyz0KmkQR6rDlWB5N68sTWTEMV7k9HcPBroUh4RZ/Og2Fv6Wc/lE'
        //       '2YaKuVY4FUERlDaSN4WJ0lMiiVoYIRtrwJBX6/fpPCbGNkSGuhrx0Rekk'
        //       '+yUTQU3C3WCVf2D534rNF3OnYKUjshNgQN8do0KAihTK7n83eUD60=',

        //   // me.carda.awesome_notifications_fcm_example
        //   'UzRlt+SJ7XyVgmD1WV+7dDMaRitmKCKOivKaVsNkfAQfQfechRveuKblFnCp4'
        //       'zifTPgRUGdFmJDiw1R/rfEtTIlZCBgK3Wa8MzUV4dypZZc5wQIIVsiqi0Zhaq'
        //       'YtTevjLl3/wKvK8fWaEmUxdOJfFihY8FnlrSA48FW94XWIcFY=',
        // ],
        debug: debug);
  }

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    WidgetsFlutterBinding.ensureInitialized();
    dynamic data =
        jsonDecode(jsonDecode(jsonEncode(receivedAction.payload))['data']);

    if (receivedAction.buttonKeyPressed == "KEPP_ADVER") {
      EumsOfferWallServiceApi().saveKeep(advertiseIdx: data['idx']);
    } else if (receivedAction.buttonKeyPressed == "SHOW_ADVER") {
      Routing().navigate(
          globalKeyMain.currentContext!,
          WatchAdverScreen(
            data: data,
          ));
    }
  }

  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    // debugPrint("vao day 112312312308012-23123 $receivedNotification");
  }

  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    // debugPrint("vao day 123121231233$receivedNotification");
  }

  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // debugPrint("vao day 123123$receivedAction");
  }

  @pragma("vm:entry-point")
  static Future<void> mySilentDataHandle(FcmSilentData silentData) async {
    print('"SilentData": ${silentData.toString()}');

    if (silentData.createdLifeCycle != NotificationLifeCycle.Foreground) {
      print("bg");
    } else {
      print("FOREGROUND");
    }

    print('mySilentDataHandle received a FcmSilentData execution');
    await executeLongTaskInBackground();
  }

  /// Use this method to detect when a new fcm token is received
  @pragma("vm:entry-point")
  static Future<void> myFcmTokenHandle(String token) async {
    debugPrint('Firebase Token:"$token"');
  }

  /// Use this method to detect when a new native token is received
  @pragma("vm:entry-point")
  static Future<void> myNativeTokenHandle(String token) async {}

  static Future<void> executeLongTaskInBackground() async {
    print("starting long task");
    print("long task done");
  }
}
