// import 'eums_platform_interface.dart';

// class Eums {
//   Future<String?> getPlatformVersion() {
//     return EumsPlatform.instance.getPlatformVersion();
//   }
// }
import 'dart:io';

import 'package:eums/common/const/values.dart';
import 'package:eums/common/local_store/local_store_service.dart';
import 'package:eums/common/routing.dart';
import 'package:eums/eum_app_offer_wall/screen/keep_adverbox_module/keep_adverbox_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_component/events/event_static_component.dart';

import 'eum_app_offer_wall/notification_handler.dart';
import 'eums_library.dart';

// const FirebaseOptions ios = FirebaseOptions(
//   apiKey: 'AIzaSyAWVPR4iDrpxJPBQt91iHK_GuDiLfH2iMI',
//   appId: '1:739452302790:ios:528a2614ed11223240aec7',
//   messagingSenderId: '739452302790',
//   projectId: 'e-ums-24291',
// );

class Eums {
  Eums._();

  static final Eums instant = Eums._();

  // EumsPermission permission = EumsPermission.instant;

  void init({required Function() onRun}) async {
    WidgetsFlutterBinding.ensureInitialized();

    // await Firebase.initializeApp(
    //     options: const FirebaseOptions(
    //         apiKey: 'AIzaSyBkj46lMsOL6WABO5FzeTXTlppVognezoM',
    //         appId: '1:739452302790:android:9fe699ead424427640aec7',
    //         messagingSenderId: '739452302790',
    //         projectId: 'e-ums-24291'));
    // NotificationHandler().initializeFcmNotification();
    onRun.call();
  }

  Future initMaterial({required Widget home, Future Function()? onRun}) async {
    print("============ Firebase.initializeApp ========= ");

    await Firebase.initializeApp();

    await LocalStoreService.instant.init();

    await NotificationHandler.instant.initializeFcmNotification();

    await onRun?.call();

    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: home,
        // navigatorKey: navigatorKeyMain,
        builder: (context, child) {
          return Overlay(
            initialEntries: [
              OverlayEntry(builder: (context) => child ?? const SizedBox()),
            ],
          );
        },
      ),
    );

    try {
      // EventStaticComponent.instance.add(
      //   key: "open-detail-overlay",
      //   event: (params, key) async {
      //     await LocalStoreService.instant.preferences.reload();
      //     final dataShare = LocalStoreService.instant.getDataShare();
      //     if (dataShare != null) {
      //       LocalStoreService.instant.setDataShare(dataShare: null);
      //       Routings().navigate(
      //           navigatorKeyMain.currentContext!,
      //           DetailKeepScreen(
      //             data: dataShare,
      //           ));
      //     }
      //   },
      // );

      await LocalStoreService.instant.preferences.reload();

      final dataShare = LocalStoreService.instant.getDataShare();
      debugPrint("dataShare====> $dataShare");
      if (dataShare != null) {
        await LocalStoreService.instant.setDataShare(dataShare: null);
        Routings().navigate(
            navigatorKeyMain.currentContext!,
            DetailKeepScreen(
              data: dataShare,
            ));
      } else {
        var details = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
        if (details?.didNotificationLaunchApp == true && details?.notificationResponse != null) {
          debugPrint("======> eums.dart ===> call eventOpenNotification");
          NotificationHandler.instant. eventOpenNotification(details!.notificationResponse!);
        }
      }

      // ignore: empty_catches
    } catch (e) {}
  }
}
