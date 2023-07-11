import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:device_apps/device_apps.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
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
  AnimationController? _controller;

  Alignment _dragAlignment = Alignment.center;
  Animation<Alignment>? _animation;

  void _runAnimation(Offset pixelsPerSecond, Size size) {
    _animation = _controller?.drive(
      AlignmentTween(
        begin: _dragAlignment,
        end: Alignment.center,
      ),
    );
    final unitsPerSecondX = pixelsPerSecond.dx / size.width;
    final unitsPerSecondY = pixelsPerSecond.dy / size.height;
    final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
    final unitVelocity = unitsPerSecond.distance;
  }

  Timer? _timer;
  int _start = 550;
  int indexStart = 0;
  Color color = Colors.black;

  bool showWatch = false;
  bool isDragging = false;
  int _upCounter = 0;

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
            removeToken();
          }
        }
      },
    );
  }

  removeToken() async {
    await Firebase.initializeApp();
    await FirebaseMessaging.instance.deleteToken();
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
    _controller = AnimationController(vsync: this);

    _controller?.addListener(() {
      setState(() {
        _dragAlignment = _animation!.value;
      });
    });
    startTimer();
    FlutterOverlayWindow.overlayListener.listen((event) {
      print("overlayListener$event");
      localStore.setDataShare(dataShare: event);
      setState(() {
        dataEvent = event;
      });
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
    _controller?.dispose();
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
    if (0 < details.position.dy && details.position.dy < 30) {
      if (_upCounter != 0) {
        _upCounter = 0;
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

    if (40 < details.position.dy.abs().floorToDouble()) {
      if (_upCounter != 0) {
        _upCounter = 0;
        localStore.setDataShare(dataShare: null);
        globalKey.currentContext?.read<AccumulateMoneyBloc>().add(
            SaveKeepAdver(advertise_idx: jsonDecode(dataEvent['data'])['idx']));
        print("concac${await localStore.getDataShare()}");
        await FlutterOverlayWindow.closeOverlay();
      } else {}
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
