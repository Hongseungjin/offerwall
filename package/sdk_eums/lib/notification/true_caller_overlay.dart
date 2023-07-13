import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:sdk_eums/common/events/rx_events.dart';
import 'package:sdk_eums/common/local_store/local_store.dart';
import 'package:sdk_eums/common/local_store/local_store_service.dart';
import 'package:sdk_eums/common/routing.dart';
import 'package:sdk_eums/common/rx_bus.dart';
import 'package:sdk_eums/eum_app_offer_wall/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/accumulate_money_module/bloc/accumulate_money_bloc.dart';
import 'package:sdk_eums/gen/assets.gen.dart';
import 'package:sdk_eums/sdk_eums_library.dart';

import '../eum_app_offer_wall/screen/watch_adver_module/watch_adver_screen.dart';

class TrueCallerOverlay extends StatefulWidget {
  const TrueCallerOverlay({Key? key}) : super(key: key);

  @override
  State<TrueCallerOverlay> createState() => _TrueCallerOverlayState();
}

class _TrueCallerOverlayState extends State<TrueCallerOverlay>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final GlobalKey<State<StatefulWidget>> globalKey =
      GlobalKey<State<StatefulWidget>>();
  dynamic dataEvent;
  late double offsetX;
  late double offsetY;
  LocalStore? localStore;

  Timer? _timer;
  int _start = 550;
  int indexStart = 0;
  Color color = Colors.black;

  bool showWatch = false;
  bool isDragging = false;

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
          if (_start == 0) {
      
          }
        }
      },
    );
  }


  bool checkApp = false;

  @override
  void initState() {
    offsetX = 0;
    offsetY = 0;
    color = Colors.black;
    localStore = LocalStoreService();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    print("vafo day123123");
    startTimer();
    FlutterOverlayWindow.overlayListener.listen((event) {
      log("$event");
      print("FlutterOverlayWindow.overlayListener: $event");
      localStore!.setDataShare(dataShare: event);
      setState(() {
        dataEvent = event;
      });
      print("FlutterOverlayWindow.overlayListener:dataEvent $dataEvent");
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        setState(() {
          checkApp = true;
        });
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    FlutterOverlayWindow.closeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<LocalStore>(
              create: (context) => LocalStoreService()),
          RepositoryProvider<EumsOfferWallService>(
              create: (context) => EumsOfferWallServiceApi())
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
              // BlocProvider<SettingBloc>(
              //     create: (context) => SettingBloc()..add(InfoUser())),
            ],
            child: MultiBlocListener(
              listeners: [
                BlocListener<AuthenticationBloc, AuthenticationState>(
                  listenWhen: (previous, current) =>
                      previous.logoutStatus != current.logoutStatus,
                  listener: (context, state) {
                    if (state.logoutStatus == LogoutStatus.loading) {
                      // EasyLoading.show();
                      return;
                    }
                    if (state.logoutStatus == LogoutStatus.finish) {
                      // EasyLoading.dismiss();
                      return;
                    }
                  },
                ),
              ],
              child: _buildWidget(context),
            )),
      ),
    );
  }

  _buildWidget(BuildContext context) {
    return BlocProvider<AccumulateMoneyBloc>(
      create: (context) => AccumulateMoneyBloc(),
      child: MultiBlocListener(listeners: [
        BlocListener<AccumulateMoneyBloc, AccumulateMoneyState>(
          listenWhen: (previous, current) =>
              previous.accumulateMoneyStatus != current.accumulateMoneyStatus,
          listener: _listenFetchData,
        ),
        BlocListener<AccumulateMoneyBloc, AccumulateMoneyState>(
          listenWhen: (previous, current) =>
              previous.saveKeepStatus != current.saveKeepStatus,
          listener: _listenSaveKeep,
        ),
      ], child: _buildContent(context)),
    );
  }

  _buildContent(BuildContext context) {
    final showDraggable = color == Colors.black;

    return GestureDetector(
      onTap: () async {},
      child: Scaffold(
        backgroundColor: Colors.transparent,
        key: globalKey,
        body: Container(
          constraints: BoxConstraints.tight(const Size(300.0, 200.0)),
          child: Listener(
            onPointerDown: (event) async {
             
            },
            onPointerMove: (event) async {
              if (30 < event.position.dy && event.position.dy < 50) {
                bool isActive = await FlutterOverlayWindow.isActive();
                if (isActive == true) {
                  await FlutterOverlayWindow.closeOverlay();
                  Future.delayed(const Duration(milliseconds: 500), () async {
                    dynamic data = await localStore?.getDataShare();
                    if (data != null || data != '') {
                      DeviceApps.openApp('com.app.abeeofferwal');
                      // await Restart.restartApp();
                    }
                  });
                }
              }
              if (60 < event.position.dy && event.position.dy < 70) {
                globalKey.currentContext?.read<AccumulateMoneyBloc>().add(
                    SaveKeepAdver(
                        advertise_idx: jsonDecode(dataEvent['data'])['idx']));
                await FlutterOverlayWindow.closeOverlay();
              }
            },
            onPointerUp: (event) {
              print("onPointerUp$event");
            },
            child: Image.asset(
              Assets.icon_logo.path,
              package: "sdk_eums",
              width: 100,
              height: 100,
            ),
          ),
        ),
      ),
    );
  }

  isOpenTab() {
    Routing().navigate(
        context,
        WatchAdverScreen(
          data: dataEvent,
        ));
  }

  void _listenFetchData(BuildContext context, AccumulateMoneyState state) {
    if (state.accumulateMoneyStatus == AccumulateMoneyStatus.loading) {
      // EasyLoading.show();
      return;
    }
    if (state.accumulateMoneyStatus == AccumulateMoneyStatus.failure) {
      // EasyLoading.dismiss();
      return;
    }
    if (state.accumulateMoneyStatus == AccumulateMoneyStatus.success) {
      // EasyLoading.dismiss();
    }
  }

  void _listenSaveKeep(BuildContext context, AccumulateMoneyState state) {
    if (state.saveKeepStatus == SaveKeepStatus.loading) {
      // EasyLoading.show();
      return;
    }
    if (state.saveKeepStatus == SaveKeepStatus.failure) {
      // EasyLoading.dismiss();
      return;
    }
    if (state.saveKeepStatus == SaveKeepStatus.success) {
      // EasyLoading.dismiss();
      setState(() {
        color = Colors.black;
      });
      if (Platform.isIOS) {
        RxBus.post(UpdateUser());
        Routing().popToRoot(context);
      }
      if (Platform.isAndroid) {
        FlutterOverlayWindow.closeOverlay();
        checkOpenApp();
      }
    }
  }

  checkOpenApp() async {
    // PackageInfo packageInfo = await PackageInfo.fromPlatform();
    // String packageName = packageInfo.packageName;
    // DeviceApps.openApp(packageName);
    // print("packageName$packageName");
  }
}
