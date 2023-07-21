import 'dart:convert';

import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:sdk_eums/common/local_store/local_store_service.dart';
import 'package:sdk_eums/eum_app_offer_wall/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:sdk_eums/eum_app_offer_wall/bloc/push_notification_service/bloc/push_notification_service_bloc.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/accumulate_money_module/bloc/accumulate_money_bloc.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/watch_adver_module/bloc/watch_adver_bloc.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:sdk_eums/eum_app_offer_wall/widget/custom_dialog.dart';
import 'package:sdk_eums/eum_app_offer_wall/widget/custom_webview2.dart';
import 'package:sdk_eums/gen/assets.gen.dart';
import 'package:sdk_eums/notification/true_overlay_bloc/true_overlay_bloc.dart';
import 'package:sdk_eums/sdk_eums_library.dart';

import '../common/local_store/local_store.dart';

class TrueCallOverlay extends StatefulWidget {
  const TrueCallOverlay({Key? key}) : super(key: key);

  @override
  State<TrueCallOverlay> createState() => _TrueCallOverlayState();
}

class _TrueCallOverlayState extends State<TrueCallOverlay>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final GlobalKey<State<StatefulWidget>> globalKey =
      GlobalKey<State<StatefulWidget>>();
  final GlobalKey<State<StatefulWidget>> webViewKey =
      GlobalKey<State<StatefulWidget>>();
  LocalStore localStore = LocalStoreService();
  dynamic dataEvent;
  bool isWebView = false;
  bool isToast = false;
  bool checkSave = false;
  double? dy;
  double? dyStart;
  String? tokenSdk;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FlutterOverlayWindow.overlayListener.listen((event) async {
      print("Current Event: $event");
      print("Current Event: ${event['tokenSdk']}");
      setState(() {
        dataEvent = event;
        tokenSdk = event['tokenSdk'] ?? '';
        isWebView = event['isWebView'] != null ? true : false;
        isToast = event['isToast'] != null ? true : false;
      });
      print("tokenEvent $tokenSdk");
    });
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
    print("tokenEvent $tokenSdk");
    return Material(
      color: Colors.transparent,
      child: MultiRepositoryProvider(
          providers: [
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
                  // child: _buildWidgetToast(),
                  child: !!isToast
                      ? _buildWidgetToast()
                      : !!isWebView
                          ? _buildWebView()
                          : _buildWidget(context)))),
    );
  }

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
        title: '',
        key: webViewKey,
        showImage: true,
        showMission: true,
        onClose: () async {
          await FlutterOverlayWindow.closeOverlay();
        },
        bookmark: GestureDetector(
          onTap: () {
            print("envenSdk$tokenSdk");
            setState(() {
              checkSave = !checkSave;
            });
            if (checkSave) {
              TrueOverlauService().saveScrap(
                  advertiseIdx: (jsonDecode(dataEvent['data']))['idx'],
                  token: tokenSdk);
            } else {
              TrueOverlauService().deleteScrap(
                  advertiseIdx: (jsonDecode(dataEvent['data']))['idx'],
                  token: tokenSdk);
            }
          },
          child: checkSave
              ? Image.asset(Assets.saveKeep.path,
                  package: "sdk_eums", height: 30, color: AppColor.black)
              : Image.asset(Assets.deleteKeep.path,
                  package: "sdk_eums", height: 30, color: AppColor.black),
        ),
        mission: () {
          if (dataEvent != null && dataEvent['data'] != null) {
            DialogUtils.showDialogSucessPoint(context,
                data: jsonDecode(dataEvent['data']), voidCallback: () async {
              try {
                TrueOverlauService().missionOfferWallOutside(
                    advertiseIdx: (jsonDecode(dataEvent['data']))['idx'],
                    pointType: (jsonDecode(dataEvent['data']))['typePoint'],
                    token: tokenSdk);
                await Future.delayed(Duration(milliseconds: 500));
                await FlutterOverlayWindow.closeOverlay();
                setState(() {
                  isWebView = false;
                  checkSave = false;
                });
                DeviceApps.openApp('com.app.abeeofferwal');
              } catch (e) {
                print(e);
              }
            });
          }
        },
        urlLink: url,
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    LocalStore localStore = LocalStoreService();
    print("statestatestate$state");
    switch (state) {
      case AppLifecycleState.resumed:
        checkShowToast();
        break;
      case AppLifecycleState.inactive:
        checkShowToast();
        break;
      case AppLifecycleState.paused:
        checkShowToast();
        localStore.setDataShare(dataShare: null);
        break;
      case AppLifecycleState.detached:
        checkShowToast();
        localStore.setDataShare(dataShare: null);
        break;
    }
  }

  checkShowToast() {
    print("isToast$isToast");
    if (isToast) {
      print("isToast123123 $isToast");
      Future.delayed(Duration(seconds: 3), () async {
        print("the end $isToast");
        await FlutterOverlayWindow.closeOverlay();
        setState(() {
          isToast = false;
        });
      });
    }
  }

  openWebView() {
    dataEvent['isWebView'] = true;
    FlutterBackgroundService().invoke("showOverlay", {'data': dataEvent});
  }

  void onVerticalDragEnd(DragEndDetails details) async {
    print("dydy$dy");
    print("dyStartdyStart$dyStart");

    if (dy != null && dyStart != null && dy! < dyStart!) {
      print('uppp');
      // _timer?.cancel(); // dùng ? nha ko dùng !
      dataEvent['isWebView'] = true;
      FlutterBackgroundService().invoke("showOverlay", {'data': dataEvent});
    }

    if (dy != null && dyStart != null && dy! > dyStart!) {
      print('downnnn');
      // _timer?.cancel(); // dùng ? nha ko dùng !
      bool isActive = await FlutterOverlayWindow.isActive();
      if (isActive == true) {
        await FlutterOverlayWindow.closeOverlay();
        if (dataEvent != null) {
          try {
            TrueOverlauService().saveKeep(
                advertiseIdx: (jsonDecode(dataEvent['data']))['idx'],
                token: tokenSdk);
            dataEvent['isToast'] = true;
            FlutterBackgroundService()
                .invoke("showOverlay", {'data': dataEvent});
          } catch (e) {
            print("errrrr$e");
          }
        }
      }
    }
  }

  Widget _buildWidgetToast() {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Center(
              child: Image.asset(
                Assets.alertOverlay.path,
                package: "sdk_eums",
                width: MediaQuery.of(context).size.width - 100,
                // height: 10,
              ),
            ),
            SizedBox(
              height: 16,
            )
          ],
        ));
  }

  Widget _buildWidget(BuildContext context) {
    return BlocProvider<AccumulateMoneyBloc>(
      create: (context) => AccumulateMoneyBloc(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        key: globalKey,
        body: Container(
          constraints: BoxConstraints.tight(const Size(300.0, 200.0)),
          child: GestureDetector(
            onTap: openWebView,
            onVerticalDragStart: (details) =>
                dyStart = details.localPosition.dy,
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
      ),
    );
  }
}
