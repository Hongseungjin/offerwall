import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:sdk_eums/common/local_store/local_store.dart';
import 'package:sdk_eums/common/local_store/local_store_service.dart';

part 'push_notification_service_event.dart';
part 'push_notification_service_state.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  LocalStore localStore = LocalStoreService();
  print('message remote 123123 ${message.data}');
  localStore.setDataShare(dataShare: message.data);
  final isActive = await FlutterOverlayWindow.isActive();

  if (isActive == true) {
    await FlutterOverlayWindow.closeOverlay();
  }



  Future.delayed(const Duration(milliseconds: 750), () async {
    await FlutterOverlayWindow.showOverlay(
        enableDrag: true,
        height: 300,
        width: 300,
        alignment: OverlayAlignment.center);
    await FlutterOverlayWindow.shareData(message.data);
  });
  await FlutterOverlayWindow.shareData(message.data);
  print('message remote ${message.notification?.body}');
  print('message remote ${message.notification?.title}');
}

final receivePort = ReceivePort();

class PushNotificationServiceBloc
    extends Bloc<PushNotificationServiceEvent, PushNotificationServiceState> {
  PushNotificationServiceBloc()
      : _eumsOfferWallService = EumsOfferWallServiceApi(),
        super(PushNotificationServiceState()) {
    on<PushNotificationServiceEvent>(mapEventToState);
  }

  final EumsOfferWallService _eumsOfferWallService;
  LocalStore localStore = LocalStoreService();

  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
      'This channel is used for important notifications.', // description
      importance: Importance.high,
      // sound: RawResourceAndroidNotificationSound('alarm'),
      playSound: true);

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  AndroidNotificationChannel get channel => _channel;

  FlutterLocalNotificationsPlugin get flutterLocalNotificationsPlugin =>
      _flutterLocalNotificationsPlugin;

  FutureOr<void> mapEventToState(
      PushNotificationServiceEvent event, emit) async {
    if (event is PushNotificationSetup) {
      await _mapPushNotificationSetupToState(event, emit);
    } else if (event is PushNotificationHandleRemoteMessage) {
      emit(state.copyWith(
        remoteMessage: event.message,
        isForeground: event.isForeground,
      ));
      // yield state.copyWith(
      //   remoteMessage: event.message,
      //   isForeground: event.isForeground,
      // );
    } else if (event is RemoveToken) {
      await _mapRemoveTokenToState(event, emit);
    }
  }

  _mapRemoveTokenToState(RemoveToken event, emit) async {
    await Firebase.initializeApp();
    await FirebaseMessaging.instance.deleteToken();
  }

  _mapPushNotificationSetupToState(PushNotificationSetup event, emit) async {
    emit(state.copyWith(
      isForeground: false,
    ));

    if (Platform.operatingSystem == 'android') {
      _androidRegisterNotifications();
    } else if (Platform.operatingSystem == 'ios') {
      _iOSRegisterNotifications();
    }
  }

  // Android initial setup
  _androidRegisterNotifications() async {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: 'AIzaSyBkj46lMsOL6WABO5FzeTXTlppVognezoM',
            appId: '1:739452302790:android:9fe699ead424427640aec7',
            messagingSenderId: '739452302790',
            projectId: 'e-ums-24291'));
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

    String? token = await FirebaseMessaging.instance.getToken();
    print("tokentokentokennotifile ${token}");

    if (token != null) {
      await _eumsOfferWallService.createTokenNotifi(token: token);
    }

    //onLaunch
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      flutterLocalNotificationsPlugin.cancelAll();
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
    print('Got a message whilst in the foreground!');
    print('message.datamessage.data${message.data}');
    localStore.setDataShare(dataShare: message.data);

    Future.delayed(Duration(milliseconds: 750), ()async{
      await FlutterOverlayWindow.showOverlay(
          enableDrag: true,
          height: 300,
          width: 300,
          alignment: OverlayAlignment.center);
      await FlutterOverlayWindow.shareData(message.data);
    });


    flutterLocalNotificationsPlugin.cancelAll();
    add(PushNotificationHandleRemoteMessage(
        message: message, isForeground: true));
  }

  Future<void> _androidOnMessage(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    _flutterLocalNotificationsPlugin.cancelAll();
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.cancelAll();
      add(PushNotificationHandleRemoteMessage(
          message: message, isForeground: false));
    }
  }

  ///Ios setup
  _iOSRegisterNotifications() async {
    await Firebase.initializeApp();
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    String? token = await FirebaseMessaging.instance.getToken();
    print("tokendevice$token");

    if (token != null) {
      await _eumsOfferWallService.createTokenNotifi(token: token);
    }

    var initializationSettingsIOS = const IOSInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    var initializationSettings =
    InitializationSettings(iOS: initializationSettingsIOS);

    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
          if (state.remoteMessage != null) {
            _iosOnMessage(state.remoteMessage!);
          }
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
      add(PushNotificationHandleRemoteMessage(
          message: message, isForeground: false));
    }
  }

  Future<void> _iosOnMessageForeground(RemoteMessage message) async {
    add(PushNotificationHandleRemoteMessage(
        message: message, isForeground: true));
  }
}
