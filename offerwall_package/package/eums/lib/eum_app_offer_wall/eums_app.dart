import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:eums/eums_library.dart';

import '../common/local_store/local_store_service.dart';

class EumsApp {
  EumsApp._();
  static EumsApp instant = EumsApp._();

  void printWrapped(String text) {
    final pattern = RegExp('.{1,800}');
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  showOverlay(event) async {
    if (event?['data'] != null && event?['data']['isWebView'] != null) {
      await FlutterOverlayWindow.showOverlay(
        overlayTitle: event?['data']['title'],
        overlayContent: event?['data']['body'],
      );
      event?['data']['tokenSdk'] = LocalStoreService.instant.getAccessToken();
      event?['data']['sizeDevice'] = LocalStoreService.instant.getSizeDevice();
      receivePort.sendPort.send(event?['data']);
      await FlutterOverlayWindow.shareData(event?['data']);
    } else {
      receivePortToast.sendPort.send("close");

      if (event?['data']['isToast'] != null) {
        await FlutterOverlayWindow.showOverlay(
          height: 300,
          width: WindowSize.matchParent,
          alignment: OverlayAlignment.bottomCenter,
        );
      } else {
        await LocalStoreService.instant.setDataShare(dataShare: event);
        await FlutterOverlayWindow.showOverlay(
          enableDrag: true,
          height: 300,
          width: 300,
          alignment: OverlayAlignment.center,
          overlayTitle: event?['data']['title'],
          overlayContent: event?['data']['body'],
        );
      }
      event?['data']['tokenSdk'] = LocalStoreService.instant.getAccessToken();
      event?['data']['sizeDevice'] = LocalStoreService.instant.getSizeDevice();
      receivePort.sendPort.send(event?['data']);
      await FlutterOverlayWindow.shareData(event?['data']);
    }
  }

  jobQueue(event) async {
    // await NotificationHandler.instant.flutterLocalNotificationsPlugin.cancel(NotificationHandler.instant.notificationId);
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

  closeOverlay() async {
    bool isActive = await FlutterOverlayWindow.isActive();
    if (isActive == true) {
      await FlutterOverlayWindow.closeOverlay();
    }
  }

  locationCurrent() async {
    if (await Permission.locationAlways.status == PermissionStatus.granted) {
      // Either the permission was already granted before or the user just granted it.
      // startTimeDown();
      // debugPrint("xxxx");
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      // debugPrint("xxxx: ${position.latitude} - ${position.longitude}");
      await EumsOfferWallServiceApi().updateLocation(lat: position.latitude, log: position.longitude);
    }
  }
}

// void printWrapped(String text) {
//   final pattern = RegExp('.{1,800}');
//   pattern.allMatches(text).forEach((match) => print(match.group(0)));
// }

// showOverlay(event) async {
//   if (event?['data'] != null && event?['data']['isWebView'] != null) {
//     await FlutterOverlayWindow.showOverlay(
//       overlayTitle: event?['data']['title'],
//       overlayContent: event?['data']['body'],
//     );
//     event?['data']['tokenSdk'] = LocalStoreService.instant.getAccessToken();
//     event?['data']['sizeDevice'] = LocalStoreService.instant.getSizeDevice();
//     receivePort.sendPort.send(event?['data']);
//     await FlutterOverlayWindow.shareData(event?['data']);
//   } else {
//     receivePort.sendPort.send(event?['data']);
//     if (event?['data']['isToast'] != null) {
//       await FlutterOverlayWindow.showOverlay(
//         height: 300,
//         width: WindowSize.matchParent,
//         alignment: OverlayAlignment.bottomCenter,
//       );
//       // _timer = Timer(const Duration(seconds: 4), () async {
//       //   await FlutterOverlayWindow.closeOverlay();
//       // });
//     } else {
//       await LocalStoreService.instant.setDataShare(dataShare: event);
//       await FlutterOverlayWindow.showOverlay(
//         enableDrag: true,
//         height: 300,
//         width: 300,
//         alignment: OverlayAlignment.center,
//         overlayTitle: event?['data']['title'],
//         overlayContent: event?['data']['body'],
//       );
//     }
//     event?['data']['tokenSdk'] = LocalStoreService.instant.getAccessToken();
//     event?['data']['sizeDevice'] = LocalStoreService.instant.getSizeDevice();
//     receivePort.sendPort.send(event?['data']);
//     await FlutterOverlayWindow.shareData(event?['data']);
//   }
// }

// jobQueue(event) async {
//   // await NotificationHandler.instant.flutterLocalNotificationsPlugin.cancel(NotificationHandler.instant.notificationId);
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
//   if (isActive == true) {
//     await FlutterOverlayWindow.closeOverlay();
//   }
// }

// locationCurrent() async {
//   if (await Permission.locationAlways.status == PermissionStatus.granted) {
//     // Either the permission was already granted before or the user just granted it.
//     // startTimeDown();
//     // debugPrint("xxxx");
//     Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//     // debugPrint("xxxx: ${position.latitude} - ${position.longitude}");
//     await EumsOfferWallServiceApi().updateLocation(lat: position.latitude, log: position.longitude);
//   }
// }

// registerDeviceToken() async {
//   try {
//     // CronCustom().initCron();
//     String? token = await FirebaseMessaging.instance.getToken();
//     if (token != null && token.isNotEmpty) {
//       // if(count < 50){
//       await EumsOfferWallServiceApi().createTokenNotifi(token: token);
//       // }
//     }
//   } catch (e) {
//     print('e $e');
//   }
// }

// @pragma('vm:entry-point')
// Future<void> onStart(ServiceInstance service) async {
//   // print('onStart');
//   WidgetsFlutterBinding.ensureInitialized();
//   DartPluginRegistrant.ensureInitialized();

//   await Firebase.initializeApp();

//   await LocalStoreService.instant.init();
//   Queue queue = Queue();
//   // registerDeviceToken();
//   try {
//     service.on('showOverlay').listen((event) async {
//       if (Platform.isAndroid) {
//         queue.add(() async => await jobQueue(event));
//         // NotificationHandler.instant.flutterLocalNotificationsPlugin.cancelAll();
//       } else {}
//     });

//     service.on('closeOverlay').listen((event) async {
//       // await NotificationHandler.instant.flutterLocalNotificationsPlugin.cancelAll();
//       queue.add(() async => await closeOverlay());
//     });

//     service.on('stopService').listen((event) async {
//       // print("eventStop");
//       queue.add(() async => await closeOverlay());
//       // String? token = await FirebaseMessaging.instance.getToken();
//       // // print('deviceToken $token');
//       // // if (token != null && token.isNotEmpty) {
//       // //   await EumsOfferWallServiceApi().unRegisterTokenNotifi(token: token);
//       // // }
//       // if (token != null && token.isNotEmpty) {
//       //   await LocalStoreService.instant.setDeviceToken("");
//       //   await EumsOfferWallServiceApi().unRegisterTokenNotifi(token: token);
//       // }
//       service.stopSelf();
//     });

//     service.on('locationCurrent').listen((event) async {
//       if (await Permission.locationAlways.status == PermissionStatus.granted) {
//         // Either the permission was already granted before or the user just granted it.
//         // startTimeDown();
//         // debugPrint("xxxx");
//         Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//         // debugPrint("xxxx: ${position.latitude} - ${position.longitude}");
//         await EumsOfferWallServiceApi().updateLocation(lat: position.latitude, log: position.longitude);
//       }
//     });
//   } catch (e) {
//     print(e);
//   }
// }

// void startTimeDown() async {
//   if (startLocationCurrent == false) {
//     startLocationCurrent = true;
//     Timer.periodic(const Duration(seconds: 180), (timer) async {
//       try {
//         debugPrint("xxxx");
//         Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//         debugPrint("xxxx: ${position.latitude} - ${position.longitude}");
//         await EumsOfferWallServiceApi().updateLocation(lat: position.latitude, log: position.longitude);
//       } catch (ex) {
//         rethrow;
//       }
//     });
//   }
// }

// @pragma('vm:entry-point')
// Future<bool> onIosBackground(ServiceInstance service) async {
//   WidgetsFlutterBinding.ensureInitialized();
//   DartPluginRegistrant.ensureInitialized();

//   return true;
// }

class EumsAppOfferWall extends EumsAppOfferWallService {
  // LocalStore localStore = LocalStoreService();
  @override
  Future<Widget> openSdk(BuildContext context) async {
    try {
      FlutterView view = WidgetsBinding.instance.platformDispatcher.views.first;
      Size size = view.physicalSize;
      double height = size.height;
      // await LocalStoreService.instant.init();
      LocalStoreService.instant.setSizeDevice(height);
    } catch (e) {
      print("=====> error: $e");
    }

    return const MyHomeScreen();
  }
  // @override
  // Future<Widget> openSdk(BuildContext context, {String? memId, String? memGen, String? memRegion, String? memBirth}) async {
  //   FlutterView view = WidgetsBinding.instance.platformDispatcher.views.first;
  //   Size size = view.physicalSize;
  //   double height = size.height;

  //   MethodOfferwallChannel.instant.init();

  //   dynamic data = await EumsOfferWallService.instance.authConnect(memBirth: memBirth, memGen: memGen, memRegion: memRegion, memId: memId);
  //   localStore.setAccessToken(data['token']);
  //   localStore.setSizeDevice(height);
  //   FlutterBackgroundService().configure(
  //       iosConfiguration: IosConfiguration(),
  //       androidConfiguration: AndroidConfiguration(
  //           onStart: onStart,
  //           autoStart: true,
  //           isForegroundMode: true,
  //           initialNotificationTitle: "인천e음",
  //           initialNotificationContent: "eum 캐시 혜택 서비스가 실행중입니다"));
  //   // openAppSkd(context);
  //   return const MyHomeScreen();
  // }

  // @override
  // openAppSkd(BuildContext context, {String? memId, String? memGen, String? memRegion, String? memBirth}) async {
  //   // await FlutterBackgroundService().configure(
  //   //     iosConfiguration: IosConfiguration(),
  //   //     androidConfiguration: AndroidConfiguration(
  //   //         onStart: onStart,
  //   //         autoStart: true,
  //   //         isForegroundMode: true,
  //   //         initialNotificationTitle: "인천e음",
  //   //         initialNotificationContent: "eum 캐시 혜택 서비스가 실행중입니다"));

  //   // Routings().navigate(context, const MyHomeScreen());
  // }

  @override
  Future<Widget> openSdkTest(BuildContext context, {String? memId, String? memGen, String? memRegion, String? memBirth}) async {
    FlutterView view = WidgetsBinding.instance.platformDispatcher.views.first;
    Size size = view.physicalSize;
    double height = size.height;

    dynamic data = await EumsOfferWallService.instance.authConnect(memBirth: memBirth, memGen: memGen, memRegion: memRegion, memId: memId);
    await LocalStoreService.instant.setAccessToken(data['token']);
    await LocalStoreService.instant.setSizeDevice(height);
    // final autoStart = LocalStoreService.instant.getSaveAdver();
    // final isRunging = await FlutterBackgroundService().isRunning();

    // if (isRunging == false) {
    //   FlutterBackgroundService().configure(
    //       iosConfiguration: IosConfiguration(),
    //       androidConfiguration: AndroidConfiguration(
    //           onStart: onStart,
    //           autoStart: autoStart,
    //           isForegroundMode: true,
    //           initialNotificationTitle: "인천e음",
    //           initialNotificationContent: "eum 캐시 혜택 서비스가 실행중입니다"));
    // }
    // openAppSkd(context);
    return const MyHomeScreen();
  }
}
