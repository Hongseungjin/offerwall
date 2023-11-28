import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:eums/common/const/values.dart';
import 'package:eums/eum_app_offer_wall/notification_handler.dart';
import 'package:eums/eum_app_offer_wall/utils/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:eums/eums_library.dart';
import 'package:queue/queue.dart';

import '../common/local_store/local_store_service.dart';

class EumsApp {
  EumsApp._();
  static EumsApp instant = EumsApp._();

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
  //     // await FlutterOverlayWindow.shareData(event?['data']);
  //   } else {
  //     if (event?['data']['isToast'] != null) {
  //       FlutterOverlayWindow.showToast(message: event?['data']['messageToast'] ?? '');
  //       return;
  //       // await FlutterOverlayWindow.closeOverlay();

  //       // await FlutterOverlayWindow.showOverlay(
  //       //   height: 300,
  //       //   width: WindowSize.matchParent,
  //       //   alignment: OverlayAlignment.bottomCenter,
  //       // );
  //     } else {
  //       // await LocalStoreService.instant.setDataShare(dataShare: event);
  //       double height = 420;

  //       await FlutterOverlayWindow.showOverlay(
  //         enableDrag: true,
  //         height: height.toInt(),
  //         width: height.toInt(),
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
  //   // bool isActive = await FlutterOverlayWindow.isActive();
  //   // if (isActive == true) {
  //   await FlutterOverlayWindow.closeOverlay();
  //   await Future.delayed(const Duration(milliseconds: 1000));
  //   await showOverlay(event);
  //   // } else {
  //   //   // await Future.delayed(const Duration(milliseconds: 1000));
  //   //   await showOverlay(event);
  //   // }
  // }

  // closeOverlay() async {
  //   debugPrint("=====> closeOverlay");

  //   // bool isActive = await FlutterOverlayWindow.isActive();
  //   // if (isActive == true) {
  //   await FlutterOverlayWindow.closeOverlay();
  //   // }
  // }

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

void printWrapped(String text) {
  final pattern = RegExp('.{1,800}');
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

showOverlay(event) async {
  try {
    if (event?['data'] != null && event?['data']['isWebView'] == true) {
      TrueCallOverlay.showDetailOfferwall = true;
      await FlutterOverlayWindow.showOverlay(
        overlayTitle: event?['data']['title'],
        overlayContent: event?['data']['body'],
      );
      event?['data']['tokenSdk'] = LocalStoreService.instant.getAccessToken();
      event?['data']['sizeDevice'] = LocalStoreService.instant.getSizeDevice();
      await FlutterOverlayWindow.shareData(event?['data']);
    } else {
      if (event?['data']['isToast'] != null) {
        FlutterOverlayWindow.showToast(message: event?['data']['messageToast'] ?? '');

        // await FlutterOverlayWindow.showOverlay(
        //   height: 300,
        //   width: WindowSize.matchParent,
        //   alignment: OverlayAlignment.bottomCenter,
        // );
        // _timer = Timer(const Duration(seconds: 4), () async {
        //   await FlutterOverlayWindow.closeOverlay();
        // });
      } else {
        // await LocalStoreService.instant.setDataShare(dataShare: event);
        await FlutterOverlayWindow.showOverlay(
          enableDrag: true,
          height: 420,
          width: 420,
          alignment: OverlayAlignment.center,
          overlayTitle: event?['data']['title'],
          overlayContent: event?['data']['body'],
        );
      }
      event?['data']['tokenSdk'] = LocalStoreService.instant.getAccessToken();
      event?['data']['sizeDevice'] = LocalStoreService.instant.getSizeDevice();
      await FlutterOverlayWindow.shareData(event?['data']);
    }
  } catch (e) {
    rethrow;
  }
}

jobQueue(event) async {
  try {
    // await NotificationHandler.instant.flutterLocalNotificationsPlugin.cancel(NotificationHandler.instant.notificationId);

    bool isActive = await FlutterOverlayWindow.isActive();
    if (isActive == true) {
      if (TrueCallOverlay.showDetailOfferwall == false) {
        await FlutterOverlayWindow.closeOverlay();
        await Future.delayed(const Duration(milliseconds: 1000));
        await showOverlay(event);
      }
    } else {
      TrueCallOverlay.showDetailOfferwall = false;
      await Future.delayed(const Duration(milliseconds: 1000));
      await showOverlay(event);
    }
  } catch (e) {
    rethrow;
  }
}

closeOverlay() async {
  try {
    bool isActive = await FlutterOverlayWindow.isActive();
    if (isActive == true) {
      await FlutterOverlayWindow.closeOverlay();
    }
  } catch (e) {
    required;
  }
}

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

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  // print('onStart');
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  await Firebase.initializeApp();
  await LocalStoreService.instant.init();

  Queue queue = Queue();
  // // registerDeviceToken();
  try {
    // if (Platform.isIOS) {
    //   Timer.periodic(const Duration(seconds: 15), (timer) async {
    //     try {
    //       await EumsOfferWallServiceApi().startBackgroundFirebaseMessage();
    //     } catch (ex) {
    //       rethrow;
    //     }
    //   });
    // }

    service.on('showOverlay').listen((event) async {
      if (Platform.isAndroid) {
        queue.add(() async => await jobQueue(event));
        // NotificationHandler.instant.flutterLocalNotificationsPlugin.cancelAll();
      } else {}
    });

    service.on('closeOverlay').listen((event) async {
      // await NotificationHandler.instant.flutterLocalNotificationsPlugin.cancelAll();
      queue.add(() async => await closeOverlay());
    });

    service.on('stopService').listen((event) async {
      // print("eventStop");
      queue.add(() async => await closeOverlay());
      String? token = await FirebaseMessaging.instance.getToken();
      // print('deviceToken $token');
      // if (token != null && token.isNotEmpty) {
      //   await EumsOfferWallServiceApi().unRegisterTokenNotifi(token: token);
      // }
      if (token != null && token.isNotEmpty) {
        await LocalStoreService.instant.setDeviceToken("");
        await EumsOfferWallServiceApi().unRegisterTokenNotifi(token: token);
      }
      await service.stopSelf();
    });

    //   service.on('locationCurrent').listen((event) async {
    //     if (await Permission.locationAlways.status == PermissionStatus.granted) {
    //       // Either the permission was already granted before or the user just granted it.
    //       // startTimeDown();
    //       // debugPrint("xxxx");
    //       Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    //       // debugPrint("xxxx: ${position.latitude} - ${position.longitude}");
    //       await EumsOfferWallServiceApi().updateLocation(lat: position.latitude, log: position.longitude);
    //     }
    //   });
  } catch (e) {
    print(e);
  }
}

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

class EumsAppOfferWall extends EumsAppOfferWallService {
  // LocalStore localStore = LocalStoreService();
  @override
  Future<Widget> openSdk(BuildContext context) async {
    try {
      FlutterView view = WidgetsBinding.instance.platformDispatcher.views.first;
      Size size = view.physicalSize;
      double height = size.height;
      // await LocalStoreService.instant.init();
      await LocalStoreService.instant.setSizeDevice(height);

      final autoStart = LocalStoreService.instant.getSaveAdver();
      // final isRunning = await FlutterBackgroundService().isRunning();

      // if (isRunning == false) {
      FlutterBackgroundService().configure(
          iosConfiguration: IosConfiguration(
            autoStart: autoStart,
            onBackground: (service) async {
              return true;
            },
            onForeground: onStart,
          ),
          androidConfiguration: AndroidConfiguration(
              onStart: onStart,
              autoStart: autoStart,
              autoStartOnBoot: autoStart,
              isForegroundMode: true,
              initialNotificationTitle: "인천e음",
              initialNotificationContent: "eum 캐시 혜택 서비스가 실행중입니다"));
      // }
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
    await LocalStoreService.instant.preferences.setString(LocalStoreService.instant.firebaseKey,
        "AAAArCrKtcY:APA91bHDmRlnGIMV9TUWHBgdx_cW59irrr6GssIkX45DUSHiTXcfHV3b0MynCOxwUdm6VTTxhp7lz3dIqAbi0SnoUFnkXlK-0ncZMX-3a3oWV8ywqaEm9A9aGnX-k50SI19hzqOgprRp");

    final autoStart = LocalStoreService.instant.getSaveAdver();

    // final isRunning = await FlutterBackgroundService().isRunning();

    // if (isRunning == false) {
    FlutterBackgroundService().configure(
        iosConfiguration: IosConfiguration(
          autoStart: autoStart,
          onBackground: iosBackground,
          onForeground: onStart,
        ),
        androidConfiguration: AndroidConfiguration(
            onStart: onStart,
            autoStart: autoStart,
            autoStartOnBoot: autoStart,
            isForegroundMode: true,
            initialNotificationTitle: "인천e음",
            initialNotificationContent: "eum 캐시 혜택 서비스가 실행중입니다"));
    // }
    // openAppSkd(context);
    return const MyHomeScreen();
  }
}
