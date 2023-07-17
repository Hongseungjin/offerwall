// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:offerwall/push_notification_bloc/bloc/push_notification_service_bloc.dart';
import 'package:sdk_eums/common/local_store/local_store.dart';
import 'package:sdk_eums/common/local_store/local_store_service.dart';
import 'package:sdk_eums/common/routing.dart';
import 'package:sdk_eums/eum_app_offer_wall/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/watch_adver_module/watch_adver_screen.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:sdk_eums/sdk_eums_library.dart';

final receivePort = ReceivePort();

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
        event?['data']['tokenSdk'] = await LocalStoreService().getAccessToken();
        await FlutterOverlayWindow.shareData(event?['data']);
      } else {
        print('showOverlay');
        await FlutterOverlayWindow.showOverlay(
            enableDrag: true,
            height: 300,
            width: 300,
            alignment: OverlayAlignment.center);
        event?['data']['tokenSdk'] = await LocalStoreService().getAccessToken();
        await FlutterOverlayWindow.shareData(event?['data']);
      }
    });

    service.on('setAppTokenBg').listen((event) {
      print('setAppTokenBg $event');
      LocalStoreService().setAccessToken(event?['token']);
    });
  } catch (e) {
    print(e);
  }
}

void main() {
  SdkEums.instant.init(onRun: () async {
    await FlutterBackgroundService().configure(
        iosConfiguration: IosConfiguration(),
        androidConfiguration: AndroidConfiguration(
            onStart: onStart,
            autoStart: true,
            isForegroundMode: true,
            initialNotificationTitle: "인천e음",
            initialNotificationContent: "eum 캐시 혜택 서비스가 실행중입니다"));
    runApp(MaterialApp(home: MyHomePage()));
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
    print('deviceWidth(context) ${deviceWidth(context)}');
    localStore.setDeviceWidth(deviceWidth(context));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    localStore.setDataShare(dataShare: null);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    LocalStore localStore = LocalStoreService();
    print("statestatestate$state");
    switch (state) {
      case AppLifecycleState.resumed:
        // try{
        //  Restart.restartApp();
        // }
        // catch(ex){
        //   print("khongo the resetapp");
        // }
        // checkOpenApp('resumed');
        break;
      case AppLifecycleState.inactive:
        // checkOpenApp('inactive');
        break;
      case AppLifecycleState.paused:
        localStore.setDataShare(dataShare: null);
        break;
      case AppLifecycleState.detached:
        localStore.setDataShare(dataShare: null);
        break;
    }
  }

  // checkOpenApp(type) async {
  //   // print("vao day khong");
  //   //
  //   // LocalStore localStore = LocalStoreService();
  //   // dynamic data = await localStore.getDataShare();
  //   // print("vao day khong$data");
  //   //   EumsAppOfferWallService.instance.openSdk(context,
  //   //       memId: "abee997",
  //   //       memGen: "w",
  //   //       memBirth: "2000-01-01",
  //   //       memRegion: "인천_서");
  //   await Future.delayed(Duration(seconds: 1));
  //   LocalStore localStore = LocalStoreService();
  //   dynamic data = await localStore.getDataShare();
  //   print("vao day chuw $type $data");
  //   if (data != "null") {
  //     EumsAppOfferWallService.instance.openSdk(context,
  //         memId: "abee997",
  //         memGen: "w",
  //         memBirth: "2000-01-01",
  //         memRegion: "인천_서");
  //   }
  // }

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
            BlocProvider<PushNotificationServiceBloc>(
              create: (context) => PushNotificationServiceBloc(),
            ),
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
  late PushNotificationServiceBloc _pushNotificationServiceBloc;
  LocalStore? localStore;
  @override
  void initState() {
    localStore = LocalStoreService();
    // TODO: implement initState
    _pushNotificationServiceBloc = context.read<PushNotificationServiceBloc>();
    _pushNotificationServiceBloc.add(PushNotificationSetup());
    checkToken();
    super.initState();
  }

  checkToken() async {
    print("localStore?.getAccessToken()${localStore?.getAccessToken()}");
  }

  void _listenerAppPushNotification(
      BuildContext context, PushNotificationServiceState state) async {
    if (state.remoteMessage != null) {
      if (state.isForeground) {
        // show custom dialog notification and sound
        if (Platform.operatingSystem == 'android') {
          String? titleMessage = state.remoteMessage?.notification?.title;
          String? bodyMessage = state.remoteMessage?.notification?.body;
          RemoteNotification? notification = state.remoteMessage?.notification;

          _pushNotificationServiceBloc.flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              titleMessage,
              bodyMessage,
              NotificationDetails(
                android: AndroidNotificationDetails(
                    _pushNotificationServiceBloc.channel.id,
                    _pushNotificationServiceBloc.channel.name,
                    channelDescription:
                        _pushNotificationServiceBloc.channel.description,
                    playSound: true,
                    importance: Importance.max,
                    icon: '@mipmap/ic_launcher',
                    onlyAlertOnce: true),
              ));
        } else {}
      } else {
        if (Platform.isIOS) {
          Routing().navigate(context,
              WatchAdverScreen(data: state.remoteMessage!.data['data']));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PushNotificationServiceBloc, PushNotificationServiceState>(
          listener: _listenerAppPushNotification,
        ),
      ],

      /// code old
      child: Scaffold(
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
      ),
    );
  }
}
