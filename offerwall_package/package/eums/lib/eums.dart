// import 'eums_platform_interface.dart';

// class Eums {
//   Future<String?> getPlatformVersion() {
//     return EumsPlatform.instance.getPlatformVersion();
//   }
// }
import 'package:eums/common/const/values.dart';
import 'package:eums/common/local_store/local_store_service.dart';
import 'package:flutter/material.dart';

import 'eum_app_offer_wall/notification_handler.dart';
import 'eums_library.dart';

class Eums {
  Eums._();

  static final Eums instant = Eums._();

  EumsPermission permission = EumsPermission.instant;

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
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);


    await LocalStoreService.instant.init();

    print("============ Firebase.initializeApp ========= ");

    await NotificationHandler.instant.initializeFcmNotification();

    await onRun?.call();

  
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: home,
        navigatorKey: navigatorKeyMain,
        builder: (context, child) {
          return Overlay(
            initialEntries: [
              OverlayEntry(builder: (context) => child ?? const SizedBox()),
            ],
          );
        },
      ),
    );

    var details = await NotificationHandler.instant.flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp == true && details?.notificationResponse != null) {
      NotificationHandler.instant.eventOpenNotification(details!.notificationResponse!);
    }
  }
}
