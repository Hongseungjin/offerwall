import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:offerwall/push_notification_bloc/bloc/push_notification_service_bloc.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:sdk_eums/common/local_store/local_store.dart';
import 'package:sdk_eums/common/local_store/local_store_service.dart';
import 'package:sdk_eums/eum_app_offer_wall/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/accumulate_money_module/bloc/accumulate_money_bloc.dart';
import 'package:sdk_eums/gen/assets.gen.dart';
import 'package:sdk_eums/sdk_eums_library.dart';

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
  LocalStore localStore = LocalStoreService();
  Timer? _timer;
  int _start = 550;
  int indexStart = 0;
  Color color = Colors.black;

  bool showWatch = false;
  bool isDragging = false;
  int _upCounter = 0;
  bool checkApp = false;

  @override
  void initState() {
    localStore = LocalStoreService();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FlutterOverlayWindow.overlayListener.listen((event) {
      localStore.setDataShare(dataShare: event);
      setState(() {
        dataEvent = event;
      });
    });
  }

  checkTimeNoifi() async {
    _start = 550;
    bool isActive = await FlutterOverlayWindow.isActive();
    print("isActive${isActive}");
    if (isActive) {
      _timer = Timer.periodic(
        const Duration(seconds: 1),
            (Timer timer) {
          if (_start == 0) {
            setState(() {
              timer.cancel();
            });
          } else {
            setState(() {
              _start--;
            });
            print("_start_start$_start");
            if (_start == 0) {
              globalKey.currentContext!.read<PushNotificationServiceBloc>().add(RemoveToken());
            }
          }
        },
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("state$state");
    switch (state) {
      case AppLifecycleState.resumed:
        checkTimeNoifi();
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
              BlocProvider<PushNotificationServiceBloc>(
                create: (context) =>
                PushNotificationServiceBloc(),
              ),
              BlocProvider<AuthenticationBloc>(
                create: (context) =>
                    AuthenticationBloc()..add(CheckSaveAccountLogged()),
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
              previous.saveKeepStatus != current.saveKeepStatus,
          listener: _listenSaveKeep,
        ),
      ], child: _buildContent(context)),
    );
  }

  void _listenSaveKeep(BuildContext context, AccumulateMoneyState state) {
    if (state.saveKeepStatus == SaveKeepStatus.loading) {
      return;
    }
    if (state.saveKeepStatus == SaveKeepStatus.failure) {
      return;
    }
    if (state.saveKeepStatus == SaveKeepStatus.success) {
      setState(() {
        color = Colors.black;
      });
    }
  }

  void _incrementUp(PointerEvent details) async {
    /// it runs this code over and over again
    _upCounter = 0;
    setState(() {
      _upCounter++;
    });

    double heightScreen = MediaQuery.of(context).size.height;
    double deviceRatio = MediaQuery.of(context).devicePixelRatio;

    double count = heightScreen * deviceRatio;

    if (0 < details.position.dy && details.position.dy < 35) {
      if (_upCounter != 0) {
        _upCounter = 0;
        _timer!.cancel();
        bool isActive = await FlutterOverlayWindow.isActive();
        if (isActive == true) {
          await FlutterOverlayWindow.closeOverlay();
          Future.delayed(const Duration(milliseconds: 500), () async {
            dynamic data = await localStore.getDataShare();
            if (data != null || data != '') {
              DeviceApps.openApp('com.app.abeeofferwal');
            }
          });
        }
      }
    }

    if (40 < details.position.dy) {
      if (_upCounter != 0) {
        _upCounter = 0;
        _timer!.cancel();
        dynamic data = await localStore.getDataShare();
        print("datadatadatadatadata$data");
        if (data != 'null') {
          globalKey.currentContext?.read<AccumulateMoneyBloc>().add(
              SaveKeepAdver(
                  advertise_idx:
                      jsonDecode((jsonDecode(data)['data']))['idx']));
          Future.delayed(Duration(milliseconds: 350), () {
            localStore.setDataShare(dataShare: null);
            FlutterOverlayWindow.closeOverlay();
          });
        } else {
          localStore.setDataShare(dataShare: null);
          FlutterOverlayWindow.closeOverlay();
        }
      }
    }
  }

  bool checkH = false;


  _buildContent(BuildContext context) {
    final showDraggable = color == Colors.black;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.transparent,
      key: globalKey,
      body: Container(
        constraints: BoxConstraints.tight(const Size(300.0, 200.0)),
        child: Listener(
          onPointerUp: _incrementUp,
          onPointerMove: (event) async {},
          child: Image.asset(
            Assets.icon_logo.path,
            package: "sdk_eums",
            width: 100,
            height: 100,
          ),
        ),
      ),


    );
  }
}
