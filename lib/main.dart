import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queue/queue.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:sdk_eums/common/local_store/local_store.dart';
import 'package:sdk_eums/common/local_store/local_store_service.dart';
import 'package:sdk_eums/eum_app_offer_wall/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:sdk_eums/sdk_eums_library.dart';
// import '../package/sdk_eums/lib/notification/notification_handler.dart';

final receivePort = ReceivePort();

// showOverlay(event) async {
//   if (event?['data'] != null && event?['data']['isWebView'] != null) {
//     await FlutterOverlayWindow.showOverlay();
//     event?['data']['tokenSdk'] = await LocalStoreService().getAccessToken();
//     event?['data']['deviceWidth'] =
//         double.parse(await LocalStoreService().getDeviceWidth());
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
//       await FlutterOverlayWindow.showOverlay(
//           enableDrag: true,
//           height: 300,
//           width: 300,
//           alignment: OverlayAlignment.center);
//     }
//     event?['data']['tokenSdk'] = await LocalStoreService().getAccessToken();
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

// registerDeviceToken(String? token) async {
//   try {
//     if (token != null && token.isNotEmpty) {
//       await EumsOfferWallServiceApi().createTokenNotifi(token: token);
//     } else {
//       String? _token = await LocalStoreService().getDeviceToken();
//       print('deviceToken $_token');
//       if (_token != null && _token.isNotEmpty) {
//         await EumsOfferWallServiceApi().createTokenNotifi(token: _token);
//       }
//     }
//   } catch (e) {
//     print('e $e');
//   }
// }

// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) {
//   print('onStart');
//   DartPluginRegistrant.ensureInitialized();
//   // await Firebase.initializeApp();
//   Queue queue = Queue();
//   registerDeviceToken(null);
//   try {
//     service.on('showOverlay').listen((event) async {
//       queue.add(() async => await jobQueue(event));
//       // NotificationHandler().flutterLocalNotificationsPlugin.cancelAll();
//     });

//     service.on('closeOverlay').listen((event) async {
//       queue.add(() async => await closeOverlay());
//     });

//     service.on('registerDeviceToken').listen((event) async {
//       print('registerDeviceToken $event');
//       registerDeviceToken(event?['data']);
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
//       queue.add(() async => await closeOverlay());
//       String? token = await LocalStoreService().getDeviceToken();
//       print('deviceToken $token');
//       if (token != null && token.isNotEmpty) {
//         await EumsOfferWallServiceApi().unRegisterTokenNotifi(token: token);
//       }
//       service.stopSelf();
//     });
//   } catch (e) {
//     print(e);
//   }
// }

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(home: MyHomePage()));
  initApp();
}

initApp() async {
  SdkEums.instant.init(onRun: () async {
    // await FlutterBackgroundService().configure(
    //     iosConfiguration: IosConfiguration(),
    //     androidConfiguration: AndroidConfiguration(
    //         onStart: onStart,
    //         autoStart: true,
    //         isForegroundMode: true,
    //         initialNotificationTitle: "인천e음",
    //         initialNotificationContent: "eum 캐시 혜택 서비스가 실행중입니다"));
    // await Firebase.initializeApp();
    // NotificationHandler().initializeFcmNotification();
  });
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
      home: TrueCallOverlay(),
    ),
  );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  LocalStore localStore = LocalStoreService();
  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;
  double deviceHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
  @override
  void initState() {
    // checkOpenApp('initState');
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  setDeviceWidth() {
    localStore.setDeviceWidth(deviceWidth(context));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    localStore.setDataShare(dataShare: null);
  }

  @override
  Widget build(BuildContext context) {
    setDeviceWidth();
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<LocalStore>(
            create: (context) => LocalStoreService()),
      ],
      child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthenticationBloc>(
              create: (context) =>
                  AuthenticationBloc()..add(CheckSaveAccountLogged()),
            ),
            // BlocProvider<PushNotificationServiceBloc>(
            //   create: (context) => PushNotificationServiceBloc(),
            // ),
          ],
          child: MultiBlocListener(
            listeners: [
              BlocListener<AuthenticationBloc, AuthenticationState>(
                listenWhen: (previous, current) =>
                    previous.logoutStatus != current.logoutStatus,
                listener: (context, state) {
                  if (state.logoutStatus == LogoutStatus.loading) {
                    return;
                  }

                  if (state.logoutStatus == LogoutStatus.finish) {
                    return;
                  }
                },
              ),
            ],
            child: GestureDetector(
              onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
              child: const MaterialApp(
                debugShowCheckedModeBanner: false,
                home: AppMainScreen(),
              ),
            ),
          )),
    );
  }
}

class AppMainScreen extends StatefulWidget {
  const AppMainScreen({Key? key}) : super(key: key);

  @override
  State<AppMainScreen> createState() => _AppMainScreenState();
}

class _AppMainScreenState extends State<AppMainScreen> {
  LocalStore? localStore;
  @override
  void initState() {
    localStore = LocalStoreService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          GestureDetector(
            onTap: () async {
              await localStore?.setDataShare(dataShare: null);
              EumsAppOfferWallService.instance.openSdk(context,
                  memId: "abee997",
                  memGen: "w",
                  memBirth: "2000-01-01",
                  memRegion: "인천_서");
            },
            child: Container(
                color: AppColor.blue1,
                padding: EdgeInsets.all(20),
                child: const Text('go to sdk')),
          )
        ],
      ),
    );
  }
}
