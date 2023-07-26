import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:queue/queue.dart';
import 'package:sdk_eums/common/local_store/local_store_service.dart';
import 'package:sdk_eums/sdk_eums_library.dart';

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

  initializeFcmNotification() async {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('mipmap/ic_launcher');

    // var initializationSettingsIOS = const DarwinInitializationSettings();

    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    await _fcm.requestPermission();
    await getToken();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: $message");
      // flutterLocalNotificationsPlugin.cancelAll();
      // FlutterBackgroundService().invoke("showOverlay", {'data': message.data});
    });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});
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

Queue queue = Queue();

showOverlay(data) async {
  if (data != null && data['isWebView'] != null) {
    await FlutterOverlayWindow.showOverlay();
    data['tokenSdk'] = await LocalStoreService().getAccessToken();
    data['deviceWidth'] =
        double.parse(await LocalStoreService().getDeviceWidth());
    await FlutterOverlayWindow.shareData(data);
  } else {
    if (data['isToast'] != null) {
      await FlutterOverlayWindow.showOverlay(
          height: 300,
          width: WindowSize.matchParent,
          alignment: OverlayAlignment.bottomCenter);
      Future.delayed(const Duration(seconds: 2), () async {
        await FlutterOverlayWindow.closeOverlay();
      });
    } else {
      await FlutterOverlayWindow.showOverlay(
          enableDrag: true,
          height: 300,
          width: 300,
          alignment: OverlayAlignment.center);
    }
    data['tokenSdk'] = await LocalStoreService().getAccessToken();
    await FlutterOverlayWindow.shareData(data);
  }
}

closeOverlay() async {
  bool isActive = await FlutterOverlayWindow.isActive();
  print('closeOverlaycloseOverlay $isActive');

  if (isActive == true) {
    await FlutterOverlayWindow.closeOverlay();
  }
}

jobQueue(event) async {
  bool isActive = await FlutterOverlayWindow.isActive();
  if (isActive == true) {
    await FlutterOverlayWindow.closeOverlay();
    await Future.delayed(const Duration(milliseconds: 1000));
    await showOverlay(event);
  } else {
    await Future.delayed(const Duration(milliseconds: 1000));
    await showOverlay(event);
  }
}

listenOverlayCallback() {
  print('listenOverlayCallback');
  ReceivePort port = ReceivePort();
  if (IsolateNameServer.lookupPortByName('isolateName') != null) {
    IsolateNameServer.removePortNameMapping('isolateName');
  }
  IsolateNameServer.registerPortWithName(port.sendPort, 'isolateName');
  port.listen((dynamic data) async {
    // do something with data
    print('data port $data');
    queue.add(() async => await jobQueue(data));
  });
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  listenOverlayCallback();
  // NotificationHandler().flutterLocalNotificationsPlugin.cancelAll();
  dynamic data = message.data;
  data['tokenSdk'] = await LocalStoreService().getAccessToken();
  queue.add(() async => await jobQueue(data));
  // FlutterBackgroundService().invoke("showOverlay", {'data': message.data});
}
