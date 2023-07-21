import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:sdk_eums/common/local_store/local_store_service.dart';
import 'package:sdk_eums/notification/true_caller_overlay.dart';
import 'package:sdk_eums/sdk_eums_library.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SdkEums.instant.init(onRun: () async {
    await FlutterBackgroundService().configure(
        iosConfiguration: IosConfiguration(),
        androidConfiguration: AndroidConfiguration(
            onStart: onStart,
            autoStart: true,
            isForegroundMode: true,
            initialNotificationTitle: "인천e음",
            initialNotificationContent: "eum 캐시 혜택 서비스가 실행중입니다"));
    runApp(const MaterialApp(
      debugShowCheckedModeBanner: true,
      home: MainAppScreen(),
    ));
  });
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  try {
    service.on('showOverlay').listen((event) async {
      bool isActive = await FlutterOverlayWindow.isActive();
      if (isActive == true) {
        await FlutterOverlayWindow.closeOverlay();
        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (event?['data'] != null && event?['data']['isWebView'] != null) {
        print('showWebView');
        await FlutterOverlayWindow.showOverlay();
        await FlutterOverlayWindow.shareData(event?['data']);
      } else {
        print('showOverlay123123123');
        try {
          await FlutterOverlayWindow.showOverlay(
              enableDrag: true,
              height: 300,
              width: 300,
              alignment: OverlayAlignment.center);
          await FlutterOverlayWindow.shareData(event?['data']);
          print("vao day khong");
        } catch (e) {
          print("errrrrr$e");
        }
      }
      print('showOverlay123$isActive');
    });

    service.on('setAppTokenBg').listen((event) {
      print('setAppTokenBg $event');
      LocalStoreService().setAccessToken(event?['token']);
    });
    service.on('onOffNotifi').listen((event) async {
      if (event?['data']) {
        FirebaseMessaging.instance.deleteToken();
        FlutterBackgroundService().invoke("stopService");
      } else {
        FlutterBackgroundService().startService();
        Future.delayed(const Duration(seconds: 5), () async {
          String? token = await FirebaseMessaging.instance.getToken();
          dynamic checkShowOnOff = await LocalStoreService().getSaveAdver();
          if (!checkShowOnOff) {
            print("tokentokentokennotifile ${token}");
            await EumsOfferWallServiceApi().createTokenNotifi(token: token);
          }
        });
      }
      print("onOffNotifi$event");
    });
    service.on('stopService').listen((event) {
      service.stopSelf();
    });
  } catch (e) {
    print(e);
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('message.data ${message.data}');
  FlutterBackgroundService().invoke("showOverlay", {'data': message.data});
}

@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
    statusBarColor: Colors.transparent,
  ));
  Future.delayed(Duration(milliseconds: 30), () {
    runApp(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: TrueCallOverlay(),
      ),
    );
  });
}

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({Key? key}) : super(key: key);

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
              child: Text("go to sdk"),
            ),
          ),
        ],
      ),
    );
  }
}
