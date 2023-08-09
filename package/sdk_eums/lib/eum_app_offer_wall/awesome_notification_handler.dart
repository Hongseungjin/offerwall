import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:awesome_notifications_fcm/awesome_notifications_fcm.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:sdk_eums/common/const/values.dart';
import 'package:sdk_eums/common/routing.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/watch_adver_module/watch_adver_screen.dart';

class NotificationController with ChangeNotifier {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static ReceivedAction? initialAction;
  static final NotificationController _instance =
      NotificationController._internal();
  String _firebaseToken = '';
  String get firebaseToken => _firebaseToken;

  String _nativeToken = '';
  String get nativeToken => _nativeToken;

  factory NotificationController() {
    return _instance;
  }

  NotificationController._internal();

  static Future<void> initializeLocalNotifications() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    requestFirebaseToken();

    await AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(
              channelKey: 'alerts',
              channelName: 'Alerts',
              channelDescription: 'Notification tests as alerts',
              playSound: true,
              // onlyAlertOnce: true,
              // channelShowBadge: true,
              importance: NotificationImportance.High,
              defaultPrivacy: NotificationPrivacy.Private,
              defaultColor: Colors.deepPurple,
              ledColor: Colors.deepPurple)
        ],
        debug: true);
    initialAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: true);
  }

  static Future<void> initializeRemoteNotifications(
      {required bool debug}) async {
    try {
      await Firebase.initializeApp();
      await AwesomeNotificationsFcm().initialize(
          onFcmSilentDataHandle: NotificationController.mySilentDataHandle,
          onFcmTokenHandle: NotificationController.myFcmTokenHandle,
          onNativeTokenHandle: NotificationController.myNativeTokenHandle,
          licenseKeys:
              // On this example app, the app ID / Bundle Id are different
              // for each platform, so was used the main Bundle ID + 1 variation
              [
            'AAAArCrKtcY:APA91bHDmRlnGIMV9TUWHBgdx_cW59irrr6GssIkX45DUSHiTXcfHV3b0MynCOxwUdm6VTTxhp7lz3dIqAbi0SnoUFnkXlK-0ncZMX-3a3oWV8ywqaEm9A9aGnX-k50SI19hzqOgprRp'
          ],
          debug: debug);
    } catch (ex) {
      print("exexex$ex");
    }
  }

  static Future<String> requestFirebaseToken() async {
    if (await AwesomeNotificationsFcm().isFirebaseAvailable) {
      try {
        final token = await AwesomeNotificationsFcm().requestFirebaseAppToken();
        print('==================FCM Token==================');
        print(token);
        print('======================================');
        return token;
      } catch (exception) {
        debugPrint('$exception');
      }
    } else {
      debugPrint('Firebase is not available on this project');
    }
    return '';
  }

  static Future<void> initializeNotificationListeners() async {
    // Only after at least the action method is set, the notification events are delivered
    await AwesomeNotifications().setListeners(
        onActionReceivedMethod: onActionReceivedMethod,
        onNotificationCreatedMethod:
            NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:
            NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:
            NotificationController.onDismissActionReceivedMethod);
  }

  static Future<void> onNavigateToMyEvent({dynamic data}) async {
    Routing().navigate(
        globalKeyMain.currentContext!,
        WatchAdverScreen(
          data: data['data'],
        ));
  }

  static Future<void> getInitialNotificationAction() async {
    ReceivedAction? receivedAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: true);
    print('Notification action launched app: $receivedAction');
    if (receivedAction == null) return;

    // Fluttertoast.showToast(
    //     msg: 'Notification action launched app: $receivedAction',
    //   backgroundColor: Colors.deepPurple
    // );
  }

  static Future<void> scheduleNewNotification() async {
    // bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    // if (!isAllowed) return;

    await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 1, // -1 is replaced by a random number
          channelKey: 'alerts',
          title: "Huston! The eagle has landed!",
          body:
              "A small step for a man, but a giant leap to Flutter's community!",
          bigPicture:
              'https://storage.googleapis.com/cms-storage-bucket/d406c736e7c4c57f5f61.png',
          largeIcon:
              'https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png',
          //'asset://assets/images/balloons-in-sky.jpg',
          notificationLayout: NotificationLayout.BigPicture,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'DISMISS',
            label: 'Dismiss',
            actionType: ActionType.SilentAction,
            requireInputText: true,
          ),
          NotificationActionButton(
            key: 'DISMISS',
            label: 'Dismiss',
            autoDismissible: true,
          ),
        ],
        schedule: NotificationCalendar.fromDate(
            date: DateTime.now().add(const Duration(seconds: 1))));
  }

  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here

    print("vao day 112312312308012-23123");
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
    print("vao day 123121231233");
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    print("vao day 123123");
    // Your code goes here
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    scheduleNewNotification();
    print("vao day");
    // Your code goes here

    // Navigate into pages, avoiding to open the notification details page over another details page already opened
  }

  @pragma("vm:entry-point")
  static Future<void> mySilentDataHandle(FcmSilentData silentData) async {
    print('"SilentData": ${silentData.toString()}');

    if (silentData.createdLifeCycle != NotificationLifeCycle.Foreground) {
      print("bg");
    } else {
      print("FOREGROUND");
    }

    print("starting long task");
    await Future.delayed(Duration(seconds: 4));

    print("long task done");
  }

  /// Use this method to detect when a new fcm token is received
  @pragma("vm:entry-point")
  static Future<void> myFcmTokenHandle(String token) async {
    debugPrint('FCM Token:"$token"');
  }

  /// Use this method to detect when a new native token is received
  @pragma("vm:entry-point")
  static Future<void> myNativeTokenHandle(String token) async {
    debugPrint('Native Token:"$token"');
  }
}
