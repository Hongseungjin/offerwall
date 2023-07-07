import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:sdk_eums/common/local_store/local_store.dart';
import 'package:sdk_eums/common/local_store/local_store_service.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:sdk_eums/notification/true_caller_overlay.dart';
import 'package:sdk_eums/sdk_eums_library.dart';

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
    print("receivePort.asBroadcastStream()$message");
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
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
    statusBarColor: Colors.transparent,
  ));
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TrueCallerOverlay(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>  with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  LocalStore? localStore;
  @override
  void initState() {
    localStore = LocalStoreService();
    print("con cac");
    super.initState();
    checkOpen();
    WidgetsBinding.instance.addObserver(this);
    SdkEums.instant.permission.checkPermission();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        checkOpen();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }



  checkOpen() async {
    print("vao day khong");
    localStore = LocalStoreService();
    Future.delayed(const Duration(milliseconds: 500), () async {
      dynamic data = await localStore?.getDataShare();
      print("dataslkdjalsjk;lda$data");
      if (data == null || data == '') {
      } else {
        // ignore: use_build_context_synchronously
        EumsAppOfferWallService.instance.openSdk(context,
            memId: "abee997",
            memGen: "w",
            memBirth: "2000-01-01",
            memRegion: "인천_서");
        Future.delayed(const Duration(seconds: 2), (){
          localStore!.removeKey('SAVE_DATA_SHARE');
          print("vao day");
        });
      }
    });
  }
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
