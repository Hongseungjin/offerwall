import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:offerwall/push_notification_bloc/bloc/push_notification_service_bloc.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:sdk_eums/common/local_store/local_store.dart';
import 'package:sdk_eums/common/local_store/local_store_service.dart';
import 'package:sdk_eums/eum_app_offer_wall/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/accumulate_money_module/bloc/accumulate_money_bloc.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/watch_adver_module/bloc/watch_adver_bloc.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:sdk_eums/eum_app_offer_wall/widget/custom_dialog.dart';
import 'package:sdk_eums/eum_app_offer_wall/widget/custom_webview2.dart';
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
  final GlobalKey<State<StatefulWidget>> webViewKey =
      GlobalKey<State<StatefulWidget>>();
  dynamic dataEvent;
  late double offsetX;
  late double offsetY;
  LocalStore localStore = LocalStoreService();
  Timer? _timer;
  int _start = 550;
  int indexStart = 0;
  Color color = Colors.black;
  bool isWebView = false;
  bool showWatch = false;
  bool isDragging = false;
  int _upCounter = 0;
  bool checkApp = false;
  @override
  void initState() {
    localStore = LocalStoreService();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FlutterOverlayWindow.overlayListener.listen((event) async {
      print("Current Event: $event");
      // localStore.setDataShare(dataShare: event);
      setState(() {
        dataEvent = event;
        isWebView = event['isWebView'] != null ? true : false;
      });
    });
  }

  checkTimeNoifi() async {
    _start = 550;
    bool isActive = await FlutterOverlayWindow.isActive();
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
            if (_start == 0) {
              globalKey.currentContext!
                  .read<PushNotificationServiceBloc>()
                  .add(RemoveToken());
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
        // checkTimeNoifi();
        // setState(() {
        //   checkApp = true;
        // });
        getActive();
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

  getActive() async {
    bool isActive = await FlutterOverlayWindow.isActive();
    print('isActiveisActive $isActive');
  }

  @override
  Widget build(BuildContext context) {
    print('isWebView $isWebView');
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
                create: (context) => PushNotificationServiceBloc(),
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
              child: !!isWebView ? _buildWebView() : _buildWidget(context),
            )),
      ),
    );
  }

  bool checkSave = false;

  Widget _buildWebView() {
    String url = '';
    try {
      url = (jsonDecode(dataEvent['data']))['url_link'];
    } catch (e) {
      print(e);
    }
    return BlocProvider<WatchAdverBloc>(
        create: (context) => WatchAdverBloc(),
        child: CustomWebView2(
            key: webViewKey,
            showImage: true,
            showMission: true,
            onClose: () async {
              await FlutterOverlayWindow.closeOverlay();
            },
            onSave: () async {
              try {
                print('checkSave $checkSave');
                setState(() {
                  checkSave = !checkSave;
                });
                print(checkSave);
                if (checkSave) {
                  webViewKey.currentContext?.read<WatchAdverBloc>().add(
                      SaveAdver(
                          advertise_idx:
                              (jsonDecode(dataEvent['data']))['idx']));
                  // await FlutterOverlayWindow.closeOverlay();
                } else {
                  webViewKey.currentContext?.read<WatchAdverBloc>().add(
                      DeleteScrap(id: (jsonDecode(dataEvent['data']))['idx']));
                  // await FlutterOverlayWindow.closeOverlay();
                }
              } catch (e) {
                print(e);
              }
            },
            mission: () async {
              if (dataEvent != null && dataEvent['data'] != null) {
                DialogUtils.showDialogSucessPoint(context,
                    // checkImage: true,
                    //       point: jsonDecode(widget.data['data'])['typePoint'],
                    data: jsonDecode(dataEvent['data']),
                    voidCallback: () async {
                  try {
                    webViewKey.currentContext?.read<WatchAdverBloc>().add(
                        EarnPoin(
                            advertise_idx:
                                (jsonDecode(dataEvent['data']))['idx'],
                            pointType:
                                (jsonDecode(dataEvent['data']))['typePoint']));
                    await Future.delayed(Duration(milliseconds: 500));
                    await FlutterOverlayWindow.closeOverlay();
                    setState(() {
                      isWebView = false;
                    });
                  } catch (e) {
                    print(e);
                  }
                });
              }
            },
            urlLink: url));
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

  double? dy;
  double? dyStart;

  void onVerticalDragEnd(DragEndDetails details) async {
    if (dy != null && dyStart != null && dy! < dyStart!) {
      print('uppp');
      // _timer!.cancel(); // dùng ? nha ko dùng !
      dataEvent['isWebView'] = true;
      FlutterBackgroundService().invoke("showOverlay", {'data': dataEvent});

      // bool isActive = await FlutterOverlayWindow.isActive();
      // if (isActive == true) {
      //   await FlutterOverlayWindow.closeOverlay();
      //   await Future.delayed(const Duration(milliseconds: 500));
      //   if (dataEvent != null) {
      //     await FlutterOverlayWindow.showOverlay();
      //     await Future.delayed(const Duration(milliseconds: 2000));

      //     setState(() {
      //       isWebView = true;
      //     });
      //     // // await FlutterOverlayWindow.updateFlag(OverlayFlag.clickThrough);
      //     // await FlutterOverlayWindow.resizeOverlay(411, 853);
      //   }
      // }
    }

    if (dy != null && dyStart != null && dy! > dyStart!) {
      print('downnnn');
      // _timer!.cancel(); // dùng ? nha ko dùng !
      bool isActive = await FlutterOverlayWindow.isActive();
      if (isActive == true) {
        await FlutterOverlayWindow.closeOverlay();
        // await Future.delayed(const Duration(milliseconds: 500));
        if (dataEvent != null) {
          try {
            globalKey.currentContext?.read<AccumulateMoneyBloc>().add(
                SaveKeepAdver(
                    advertise_idx: (jsonDecode(dataEvent['data']))['idx']));
          } catch (e) {}
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
        child: GestureDetector(
          onVerticalDragStart: (details) => dyStart = details.localPosition.dy,
          onVerticalDragEnd: onVerticalDragEnd,
          onVerticalDragUpdate: (details) => dy = details.localPosition.dy,
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
