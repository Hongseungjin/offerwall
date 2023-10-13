import 'package:flutter/material.dart';

import 'eum_app_offer_wall/notification_handler.dart';
import 'sdk_eums_library.dart';

class SdkEums {
  SdkEums._();

  static final SdkEums instant = SdkEums._();

  SdkEumsPermission permission = SdkEumsPermission.instant;

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

  void initMaterial({required Widget home, Future Function()? onRun}) async {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp();

    await NotificationHandler.instant.initializeFcmNotification();

    await onRun?.call();

    runApp(
      // DevicePreview(
      //   enabled: true,
      //   builder: (context) => MaterialApp(
      //     debugShowCheckedModeBanner: false,
      //     // home: MyHomePage(),
      //     useInheritedMediaQuery: true,
      //     locale: DevicePreview.locale(context),
      //     builder: DevicePreview.appBuilder,
      //     theme: ThemeData.light(),
      //     darkTheme: ThemeData.dark(),

      //     home: MyInitPageEum(child: home),
      //   ),
      // ),
      MaterialApp(
        debugShowCheckedModeBanner: false,
        // useInheritedMediaQuery: true,
        // locale: DevicePreview.locale(context),
        // builder: DevicePreview.appBuilder,
        // theme: ThemeData.light(),
        // darkTheme: ThemeData.dark(),

        home: MyInitPageEum(child: home),
      ),
    );

    var details = await NotificationHandler.instant.flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp == true && details?.notificationResponse != null) {
      NotificationHandler.instant.eventOpenNotification(details!.notificationResponse!);
    }
  }
}

class MyInitPageEum extends StatefulWidget {
  const MyInitPageEum({super.key, required this.child});
  final Widget child;

  @override
  State<MyInitPageEum> createState() => _MyInitPageEumState();
}

class _MyInitPageEumState extends State<MyInitPageEum> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
