import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:queue/queue.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:sdk_eums/common/local_store/local_store.dart';
import 'package:sdk_eums/common/routing.dart';
import 'package:sdk_eums/sdk_eums_library.dart';

import '../common/local_store/local_store_service.dart';
import 'notification_handler.dart';

// showOverlay(event) async {
//   print('event overlay ${event}');
//   if (event?['data'] != null && event?['data']['isWebView'] != null) {
//     await FlutterOverlayWindow.showOverlay();
//     event?['data']['tokenSdk'] = await LocalStoreService().getAccessToken();
//     event?['data']['deviceWidth'] =
//         double.parse(await LocalStoreService().getDeviceWidth());
//     await Future.delayed(const Duration(milliseconds: 1000));
//     await FlutterOverlayWindow.shareData(event?['data']);
//   } else {
//     if (event?['data']['isToast'] != null) {
//       await FlutterOverlayWindow.showOverlay(
//           height: 300,
//           width: WindowSize.matchParent,
//           alignment: OverlayAlignment.bottomCenter);
//       Future.delayed(const Duration(seconds: 2), () async {
//         await FlutterOverlayWindow.closeOverlay();
//       });
//     } else {
//       LocalStoreService().setDataShare(dataShare: event);
//       await FlutterOverlayWindow.showOverlay(
//           enableDrag: true,
//           height: 300,
//           width: 300,
//           alignment: OverlayAlignment.center);
//     }
//     event?['data']['tokenSdk'] = await LocalStoreService().getAccessToken();
//     await Future.delayed(const Duration(milliseconds: 1000));

//     await FlutterOverlayWindow.shareData(event?['data']);
//   }
// }

// jobQueue(event) async {
//   bool isActive = await FlutterOverlayWindow.isActive();
//   if (isActive == true) {
//     await FlutterOverlayWindow.closeOverlay();
//     await Future.delayed(const Duration(milliseconds: 1000));
//     await showOverlay(event);
//   } else {
//     await Future.delayed(const Duration(milliseconds: 1000));
//     await showOverlay(event);
//   }
// }

// closeOverlay() async {
//   bool isActive = await FlutterOverlayWindow.isActive();
//   print('closeOverlaycloseOverlay $isActive');

//   if (isActive == true) {
//     await FlutterOverlayWindow.closeOverlay();
//   }
// }

// registerDeviceToken() async {
//   try {
//     String? _token = await FirebaseMessaging.instance.getToken();
//     print('deviceToken $_token');
//     if (_token != null && _token.isNotEmpty) {
//       await EumsOfferWallServiceApi().createTokenNotifi(token: _token);
//     }
//   } catch (e) {
//     print('e $e');
//   }
// }

// @pragma('vm:entry-point')
// Future<void> onStart(ServiceInstance service) async {
//   print('onStart');
//   DartPluginRegistrant.ensureInitialized();
//   // await Firebase.initializeApp();
//   // await Firebase.initializeApp(
//   //     options: const FirebaseOptions(
//   //         apiKey: 'AIzaSyBkj46lMsOL6WABO5FzeTXTlppVognezoM',
//   //         appId: '1:739452302790:android:9fe699ead424427640aec7',
//   //         messagingSenderId: '739452302790',
//   //         projectId: 'e-ums-24291'));
//   // NotificationHandler().initializeFcmNotificationBackground();
//   Queue queue = Queue();
//   // registerDeviceToken();
//   try {
//     service.on('showOverlay').listen((event) async {
//       queue.add(() async => await jobQueue(event));
//       // NotificationHandler().flutterLocalNotificationsPlugin.cancelAll();
//     });

//     service.on('closeOverlay').listen((event) async {
//       queue.add(() async => await closeOverlay());
//     });

//     service.on('registerDeviceToken').listen((event) async {
//       registerDeviceToken();
//       // queueDeviceToken.add(() async {
//       //   String? token = await FirebaseMessaging.instance.getToken();
//       //   print('deviceToken $token');
//       //   await EumsOfferWallServiceApi().createTokenNotifi(token: token);
//       // });
//     });
//     // service.on('deleteDeviceToken').listen((event) async {
//     //   queueDeviceToken.add(() async {
//     //     await FirebaseMessaging.instance.deleteToken();
//     //   });
//     // });
//     service.on('stopService').listen((event) async {
//       print("eventStop");
//       // NotificationHandler().flutterLocalNotificationsPlugin.cancelAll();
//       queue.add(() async => await closeOverlay());
//       // String? token = await FirebaseMessaging.instance.getToken();
//       // print('deviceToken $token');
//       // if (token != null && token.isNotEmpty) {
//       //   await EumsOfferWallServiceApi().unRegisterTokenNotifi(token: token);
//       // }
//       service.stopSelf();
//     });
//   } catch (e) {
//     print(e);
//   }
// }

class EumsAppOfferWall extends EumsAppOfferWallService {
  LocalStore localStore = LocalStoreService();
  @override
  Future openSdk(BuildContext context,
      {String? memId,
      String? memGen,
      String? memRegion,
      String? memBirth}) async {
    dynamic data = await EumsOfferWallService.instance.authConnect(
        memBirth: memBirth, memGen: memGen, memRegion: memRegion, memId: memId);
    localStore.setAccessToken(data['token']);
    if (await localStore.getAccessToken() != null) {
      openAppSkd(context);
    }
  }

  @override
  openAppSkd(BuildContext context,
      {String? memId,
      String? memGen,
      String? memRegion,
      String? memBirth}) async {
    // await FlutterBackgroundService().configure(
    //     iosConfiguration: IosConfiguration(),
    //     androidConfiguration: AndroidConfiguration(
    //         onStart: onStart,
    //         autoStart: false,
    //         isForegroundMode: true,
    //         initialNotificationTitle: "인천e음",
    //         initialNotificationContent: "eum 캐시 혜택 서비스가 실행중입니다"));
    Routing().navigate(context, MyHomeScreen());
  }
}
