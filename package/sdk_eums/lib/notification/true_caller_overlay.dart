import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:sdk_eums/common/constants.dart';
import 'package:sdk_eums/common/local_store/local_store_service.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/accumulate_money_module/bloc/accumulate_money_bloc.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/watch_adver_module/bloc/watch_adver_bloc.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:sdk_eums/eum_app_offer_wall/widget/custom_dialog.dart';
import 'package:sdk_eums/eum_app_offer_wall/widget/custom_webview2.dart';
import 'package:sdk_eums/gen/assets.gen.dart';
import 'package:sdk_eums/notification/true_overlay_bloc/true_overlay_bloc.dart';
import 'package:sdk_eums/sdk_eums_library.dart';

import '../common/local_store/local_store.dart';
import '../eum_app_offer_wall/bloc/authentication_bloc/authentication_bloc.dart';

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
  double deviceWidth = 0;
  MethodChannel _backgroundChannel = MethodChannel("x-slayer/overlay");

  @override
  void initState() {
    // TODO: implement initState
    print('inittt overlay');
    initCallbackDrag();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FlutterOverlayWindow.overlayListener.listen((event) async {
      try {
        setState(() {
          dataEvent = event;
          tokenSdk = event['tokenSdk'] ?? '';
          isWebView = event['isWebView'] != null ? true : false;
          isToast = event['isToast'] != null ? true : false;
          checkSave = false;
          deviceWidth = event['deviceWidth'] ?? 0;
        });
        print('overlayListener $event');
      } catch (e) {
        print('errorrrrrr $e');
      }
    });
  }

  initCallbackDrag() {
    _backgroundChannel.setMethodCallHandler((MethodCall call) async {
      if ('START_DRAG' == call.method) {
        print('start ${call.method} ${call.arguments}');
        dyStart = call.arguments;
      } else if ('END_DRAG' == call.method) {
        print('end ${call.method} ${call.arguments}');
        dy = call.arguments;
        onVerticalDragEnd();
      }
    });
  }

  @override
  void dispose() {
    print('disposeeeee');
    // TODO: implement dispose
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: MultiRepositoryProvider(
          providers: [
            RepositoryProvider<EumsOfferWallService>(
                create: (context) => EumsOfferWallServiceApi())
          ],
          child: MultiBlocProvider(
              providers: [
                // BlocProvider<PushNotificationServiceBloc>(
                //   create: (context) => PushNotificationServiceBloc(),
                // ),
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
      FlutterBackgroundService().invoke("closeOverlay");
    }
    return BlocProvider<WatchAdverBloc>(
      create: (context) => WatchAdverBloc(),
      child: CustomWebView2(
        title: '',
        key: webViewKey,
        showImage: true,
        showMission: true,
        deviceWidth: deviceWidth,
        actions: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24)
              ),
              padding: EdgeInsets.symmetric(vertical: 5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                    width: MediaQuery.of(context).size.width - 64,
                    fit: BoxFit.cover,
                    imageUrl: Constants.baseUrlImage +
                        (jsonDecode(dataEvent['data']))['advertiseSponsor']['image'],
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) {
                      return Image.asset(Assets.logo.path,
                          package: "sdk_eums", height: 16);
                    }),
              ),
            ),
                const SizedBox(width: 20,)
          ],
        ),
        onClose: () async {
          FlutterBackgroundService().invoke("closeOverlay");
        },
        bookmark: GestureDetector(
          onTap: () {
            setState(() {
              checkSave = !checkSave;
            });
            try {
              if (checkSave) {
                TrueOverlauService().saveScrap(
                    advertiseIdx: (jsonDecode(dataEvent['data']))['idx'],
                    token: tokenSdk);
              } else {
                TrueOverlauService().deleteScrap(
                    advertiseIdx: (jsonDecode(dataEvent['data']))['idx'],
                    token: tokenSdk);
              }
            } catch (e) {
              print('e $e');
              FlutterBackgroundService().invoke("closeOverlay");
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
                setState(() {
                  isWebView = false;
                  checkSave = false;
                });
                FlutterBackgroundService().invoke("closeOverlay");
                DeviceApps.openApp('com.app.abeeofferwal');
              } catch (e) {
                print(e);
                FlutterBackgroundService().invoke("closeOverlay");
              }
            });
          }
        },
        urlLink: url,
      ),
    );
  }

  openWebView() {
    dataEvent['isWebView'] = true;
    FlutterBackgroundService().invoke("showOverlay", {'data': dataEvent});
  }

  void onVerticalDragEnd() async {
    if (dy != null && dyStart != null && dy! < dyStart!) {
      print('up$dataEvent');
      if (dataEvent != null) {
        dataEvent['isWebView'] = true;
        FlutterBackgroundService().invoke("showOverlay", {'data': dataEvent});
      } else {
        FlutterBackgroundService().invoke("closeOverlay");
      }
    }

    if (dy != null && dyStart != null && dy! > dyStart!) {
      print('downnnn$dataEvent');
      if (dataEvent != null) {
        try {
          TrueOverlauService().saveKeep(
              advertiseIdx: (jsonDecode(dataEvent['data']))['idx'],
              token: tokenSdk);
          dataEvent['isToast'] = true;
          FlutterBackgroundService().invoke("showOverlay", {'data': dataEvent});
        } catch (e) {
          print("errrrr$e");
          FlutterBackgroundService().invoke("closeOverlay");
        }
      } else {
        FlutterBackgroundService().invoke("closeOverlay");
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
                width: MediaQuery.of(context).size.width - 150,
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
            // child: GestureDetector(
            //   onTap: openWebView,
            //   onVerticalDragStart: (details) {
            //     print('start ${details.localPosition.dy}');
            //     dyStart = details.localPosition.dy;
            //   },
            //   onVerticalDragEnd: onVerticalDragEnd,
            //   onVerticalDragUpdate: (details) {
            //     print('update ${details.localPosition.dy}');
            //     dy = details.localPosition.dy;
            //   },
            child: Image.asset(
              Assets.icon_logo.path,
              package: "sdk_eums",
              width: 100,
              height: 100,
            ),
            // ),
            // ),
          ),
        ));
  }
}
