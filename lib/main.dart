// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:offerwall/push_notification_bloc/bloc/push_notification_service_bloc.dart';
import 'package:offerwall/widget/true_call_overlay.dart';
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
      home: TrueCallerOverlay(),
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
  @override
  void initState() {
    checkOpenApp();
    checkPermission();

    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  checkPermission() async {
    final bool status = await FlutterOverlayWindow.isPermissionGranted();

    if (!status) {
      await FlutterOverlayWindow.requestPermission();
    } else {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    LocalStore localStore = LocalStoreService();
    switch (state) {
      case AppLifecycleState.resumed:
        checkOpenApp();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        localStore.setDataShare(dataShare: null);

        break;
    }
  }

  checkOpenApp() async {
    LocalStore localStore = LocalStoreService();
    dynamic data = await localStore.getDataShare();
    if (data != null && data != '') {
      EumsAppOfferWallService.instance.openSdk(context,
          memId: "abee997",
          memGen: "w",
          memBirth: "2000-01-01",
          memRegion: "인천_서");
    }
  }

  @override
  Widget build(BuildContext context) {
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
    checkDataNotifi();
    super.initState();
  }

  checkDataNotifi() async {
    dynamic data = await localStore?.getDataShare();
    if (data != null && data != '') {
      EumsAppOfferWallService.instance.openSdk(context,
          memId: "abee997",
          memGen: "w",
          memBirth: "2000-01-01",
          memRegion: "인천_서");
    }else{

    }
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
      child: Scaffold(
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
