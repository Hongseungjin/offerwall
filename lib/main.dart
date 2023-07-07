import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:sdk_eums/eum_app_offer_wall/eums_app_i.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:sdk_eums/notification/true_caller_overlay.dart';
import 'package:sdk_eums/sdk_eums.dart';

final receivePort = ReceivePort();

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();
  print("=========> call flutterBackgroundService start");
  IsolateNameServer.registerPortWithName(
      receivePort.sendPort, 'overlay_window');
  if (IsolateNameServer.lookupPortByName('overlay_window') != null) {
    IsolateNameServer.removePortNameMapping('overlay_window');
  }
  receivePort.listen((message) async {
    if (message == 'openApp') {}
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
  SdkEums.instant.init(onRun: () async {
    await FlutterBackgroundService().configure(
        iosConfiguration: IosConfiguration(),
        androidConfiguration: AndroidConfiguration(
          onStart: onStart,
          autoStart: true,
          isForegroundMode: true,
        ));
  });
  runApp(const MaterialApp(home:  MyApp()));
}

@pragma("vm:entry-point")
void overlayMain() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
    statusBarColor: Colors.transparent,
  ));

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TrueCallerOverlay(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              EumsAppOfferWallService.instance.openSdk(context,
                  memId: "abee997",
                  memGen: "w",
                  memBirth: "2000-01-01",
                  memRegion: "인천_서");
            },
            child: Container(
              color: AppColor.color1DF,
              padding:  const EdgeInsets.all(20),
              child: const Text("go to sdk"),
            ),
          )
        ],
      ),
    );
  }
}
