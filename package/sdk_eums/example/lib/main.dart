import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:sdk_eums/common/local_store/local_store.dart';
import 'package:sdk_eums/common/local_store/local_store_service.dart';
import 'package:sdk_eums/method_sdk/sdk_eums_platform_interface.dart';
import 'package:sdk_eums/sdk_eums.dart';
import 'package:sdk_eums/sdk_eums_library.dart';

final receivePort = ReceivePort();

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();
  print("=========> call flutterBackgroundService start");
  IsolateNameServer.registerPortWithName(
      receivePort.sendPort, 'overlay_window');
  if (IsolateNameServer.lookupPortByName('overlay_window') != null) {
    IsolateNameServer.removePortNameMapping('overlay_window');
  }
  receivePort.listen((message) async {
    print("receivePort.asBroadcastStream()$message");
    if (message == 'openApp') {
      print("vao day nhe$message");
    }
    if (message is Map) {
      try {
        try {
          final isActive = await FlutterOverlayWindow.isActive();
          if (isActive == true) {
            // await FlutterOverlayWindow.closeOverlay();
            await FlutterOverlayWindow.closeOverlay();
          }
        } catch (e) {
          print("$e");
        }

        await FlutterOverlayWindow.showOverlay(
            enableDrag: true,
            height: 300,
            width: 300,
            alignment: OverlayAlignment.center);
        await FlutterOverlayWindow.shareData(message);
      } catch (e) {
        rethrow;
      }
    }
  });
}

void main() {
  SdkEums.instant.init(
    onRun: () async {
      // final flutterBackgroundService = FlutterBackgroundService();
      await FlutterBackgroundService().configure(
          iosConfiguration: IosConfiguration(),
          androidConfiguration: AndroidConfiguration(
            onStart: onStart,

            // auto start service
            autoStart: true,
            isForegroundMode: true,
          ));
      runApp(const MaterialApp(
        debugShowCheckedModeBanner: true,
        home: MyApp(),
      ));
    },
  );
}

// @pragma("vm:entry-point")
// void overlayMain() {
//   WidgetsFlutterBinding.ensureInitialized();
//   SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
//     statusBarColor: Colors.transparent,
//   ));
//   runApp(
//     const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: TrueCallerOverlay(),
//     ),
//   );
// }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  LocalStore? localStore;
  @override
  void initState() {
    localStore = LocalStoreService();
    print("con cac");
    super.initState();
      onResumed();

    WidgetsBinding.instance.addObserver(this);
    // SdkEums.instant.permission.checkPermission();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // checkOpen();
    setState(() {});
    switch (state) {
      case AppLifecycleState.resumed:
        onResumed();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  void onResumed() {
    checkOpen();
  }

  checkOpen() async {
    print("123123123123123123");
    localStore = LocalStoreService();
    Future.delayed(const Duration(milliseconds: 500), () async {
      dynamic data = await localStore?.getDataShare();
          print("123123123123123123$data");
      if (data == null || data == '') {
      } else {
        // ignore: use_build_context_synchronously
        EumsAppOfferWallService.instance.openSdk(
          context,
          memBirth: "2023-06-09T02:26:42.135Z",
          memId: "abeetest",
          memGen: "m",
          memRegion: "서울_종로",
        );
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              EumsAppOfferWallService.instance.openSdk(
                context,
                memBirth: "2023-06-09T02:26:42.135Z",
                memId: "abeetest",
                memGen: "m",
                memRegion: "서울_종로",
              );
            },
            child: Container(
              height: 50,
              color: Colors.amber,
              width: 100,
              child: Text("Adsync"),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              // EumsOfferWallService.instance.userInfo()
              // EumsOfferWallServiceApi();
              // SdkEumsPlatform.instance.methodAdpopcorn();
            },
            child: const SizedBox(
              height: 50,
              width: 100,
              child: Text("adpopcorn"),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              SdkEumsPlatform.instance.methodAppall();
            },
            child: const SizedBox(
              height: 50,
              width: 100,
              child: Text("Appall"),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              SdkEumsPlatform.instance.methodMafin();
            },
            child: const SizedBox(
              height: 50,
              width: 100,
              child: Text("mafin"),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              SdkEumsPlatform.instance.methodTnk();
            },
            child: const SizedBox(
              height: 50,
              width: 100,
              child: Text("tkn"),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              SdkEumsPlatform.instance.methodOHC();
            },
            child: const SizedBox(
              height: 50,
              width: 100,
              child: Text("ohc"),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              SdkEumsPlatform.instance.methodIvekorea();
            },
            child: const SizedBox(
              height: 50,
              width: 100,
              child: Text("Ivekorea"),
            ),
          ),
        ],
      ),
    );
  }
}
