import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:device_apps/device_apps.dart';
import 'package:eums/common/local_store/local_store_service.dart';
import 'package:eums/eum_app_offer_wall/eums_app.dart';
import 'package:eums/eum_app_offer_wall/notification_handler.dart';
import 'package:eums/eum_app_offer_wall/widget/toast/app_alert.dart';
import 'package:eums/gen/style_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:eums/common/routing.dart';
import 'package:eums/eum_app_offer_wall/screen/accumulate_money_module/bloc/accumulate_money_bloc.dart';
import 'package:eums/eum_app_offer_wall/screen/report_module/report_page.dart';
import 'package:eums/eum_app_offer_wall/screen/watch_adver_module/bloc/watch_adver_bloc.dart';
import 'package:eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:eums/eum_app_offer_wall/utils/hex_color.dart';
import 'package:eums/eum_app_offer_wall/widget/custom_dialog.dart';
import 'package:eums/eum_app_offer_wall/widget/custom_webview_overlay.dart';
import 'package:eums/gen/assets.gen.dart';
import 'package:eums/notification/true_overlay_bloc/true_overlay_bloc.dart';
import 'package:eums/eums_library.dart';

import '../eum_app_offer_wall/bloc/authentication_bloc/authentication_bloc.dart';

String kPortName = 'overlay_port';
final receivePort = ReceivePort();

class TrueCallOverlay extends StatefulWidget {
  const TrueCallOverlay({Key? key}) : super(key: key);

  @override
  State<TrueCallOverlay> createState() => _TrueCallOverlayState();
}

class _TrueCallOverlayState extends State<TrueCallOverlay> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final GlobalKey<State<StatefulWidget>> globalKey = GlobalKey<State<StatefulWidget>>();
  // final GlobalKey<State<StatefulWidget>> webViewKey = GlobalKey<State<StatefulWidget>>();
  // LocalStore localStore = LocalStoreService();
  dynamic dataEvent;
  bool isWebView = false;
  bool isToast = false;
  bool checkSave = false;
  double? dy;
  double? dyStart;
  String? tokenSdk;
  double deviceWidth = 0;
  double deviceHeight = 0;
  final MethodChannel _backgroundChannel = const MethodChannel("x-slayer/overlay");
  int countAdvertisement = 0;
  double heightScreen = 0.0;

  String messageToast = "";

  @override
  void initState() {
    // TODO: implement initState
    // print('inittt overlay');
    initCallbackDrag();
    WidgetsBinding.instance.addObserver(this);

    receivePort.listen((event) async {
      try {
        setState(() {
          dataEvent = event;
          tokenSdk = event['tokenSdk'] ?? '';
          deviceHeight = double.parse(event['sizeDevice'] ?? '0');
          isWebView = event['isWebView'] != null ? true : false;
          isToast = event['isToast'] != null ? true : false;
          messageToast = event['messageToast'] ?? '';
          // checkSave = false;
          try {
            final dataTemp = (jsonDecode(event['data']));
            checkSave = dataTemp['isScrap'] ?? false;
          } catch (e) {}
          deviceWidth = event['deviceWidth'] ?? 0;
        });

        // printWrapped('overlayListener $event');
        // printWrapped('overlayListener $deviceHeight');
      } catch (e) {
        // print('errorrrrrr $e');
        rethrow;
      }
    });
    IsolateNameServer.registerPortWithName(receivePort.sendPort, kPortName);

    FlutterOverlayWindow.overlayListener.listen((event) async {
      try {
        setState(() {
          dataEvent = event;
          tokenSdk = event['tokenSdk'] ?? '';
          deviceHeight = double.parse(event['sizeDevice'] ?? '0');
          isWebView = event['isWebView'] != null ? true : false;
          isToast = event['isToast'] != null ? true : false;
          messageToast = event['messageToast'] ?? '';
          // checkSave = false;
          final dataTemp = (jsonDecode(event['data']));
          checkSave = dataTemp['isScrap'] ?? false;
          deviceWidth = event['deviceWidth'] ?? 0;
        });
        debugPrint("xxxx: FlutterOverlayWindow.overlayListener");
      } catch (e) {
        // print('errorrrrrr $e');
        rethrow;
      }
    });
    super.initState();
  }

  var pixelRatio = window.devicePixelRatio;

  initCallbackDrag() {
    _backgroundChannel.setMethodCallHandler((MethodCall call) async {
      await Firebase.initializeApp();
      await LocalStoreService.instant.init();

      // if ('START_DRAG' == call.method) {
      //   // print('start ${call.method} ${call.arguments}');
      //   // dyStart = call.arguments;
      //   debugPrint("xxxx->>> START_DRAG");

      //   dyStart = call.arguments;
      // } else
      if ('END_DRAG' == call.method) {
        heightScreen = call.arguments['height'];
        // print('end ${call.method} ${call.arguments}');
        dy = call.arguments['lastY'];
        // dy = 1900;
        // debugPrint("xxxx->>> END_DRAG $dy - $heightScreen");

        onVerticalDragEnd();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    heightScreen = MediaQuery.of(context).size.height;

    return Material(
      color: Colors.transparent,
      child: MultiRepositoryProvider(
          providers: [RepositoryProvider<EumsOfferWallService>(create: (context) => EumsOfferWallServiceApi())],
          child: MultiBlocProvider(
              providers: [
                BlocProvider<AuthenticationBloc>(
                  create: (context) => AuthenticationBloc()..add(CheckSaveAccountLogged()),
                ),
              ],
              child: MultiBlocListener(
                  listeners: [
                    BlocListener<AuthenticationBloc, AuthenticationState>(
                      listenWhen: (previous, current) => previous.logoutStatus != current.logoutStatus,
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
                  child: isToast
                      ? _buildWidgetToast()
                      : isWebView
                          ? _buildWebView()
                          : _buildWidget(context)))),
    );
  }

  Widget _buildWebView() {
    String url = '';
    try {
      url = (jsonDecode(dataEvent['data']))['url_link'];
    } catch (e) {
      // print(e);
      // FlutterBackgroundService().invoke("closeOverlay");
      EumsApp.instant.closeOverlay();
    }
    return BlocProvider<WatchAdverBloc>(
      create: (context) => WatchAdverBloc(),
      child: CustomWebViewOverlay(
        title: '${(jsonDecode(dataEvent['data']))['name']}',
        // key: webViewKey,
        showImage: !isWebView,
        // showMission: true,
        deviceWidth: deviceWidth,
        actions: Row(
          children: [
            InkWell(
                onTap: () async {
                  await Routings().navigate(
                      context,
                      ReportPage(
                        checkOverlay: true,
                        paddingTop: kToolbarHeight + MediaQuery.of(context).padding.bottom,
                        data: (jsonDecode(dataEvent['data'])),
                        deleteAdver: true,
                      ));
                  // if (result == true) {
                  //   // ignore: use_build_context_synchronously
                  //   AppAlert.showSuccess("Success");
                  // }
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 16),
                  // child: Image.asset(Assets.report.path, package: "eums", height: 30),
                  child: Assets.icons.report.image(height: 30),
                )),
            // Container(
            //   decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
            //   padding: const EdgeInsets.symmetric(vertical: 5),
            //   child: ClipRRect(
            //     borderRadius: BorderRadius.circular(12),
            //     child: CachedNetworkImage(
            //         width: MediaQuery.of(context).size.width - 64,
            //         fit: BoxFit.cover,
            //         imageUrl: Constants.baseUrlImage + (jsonDecode(dataEvent['data']))['advertiseSponsor']['image'],
            //         placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
            //         errorWidget: (context, url, error) {
            //           return Image.asset(Assets.logo.path, package: "eums", height: 16);
            //         }),
            //   ),
            // ),
          ],
        ),
        onClose: () async {
          // FlutterBackgroundService().invoke("closeOverlay");
          await EumsApp.instant.closeOverlay();
        },
        bookmark: InkWell(
            onTap: () {
              setState(() {
                checkSave = !checkSave;
              });
              try {
                final data = (jsonDecode(dataEvent['data']));
                if (checkSave) {
                  TrueOverlayService().saveScrap(advertiseIdx: data['idx'], token: tokenSdk!, adType: data['ad_type']!);
                  AppAlert.showSuccess("Success");
                } else {
                  TrueOverlayService().deleteScrap(advertiseIdx: data['idx'], token: tokenSdk);
                  AppAlert.showSuccess("Deleted");
                }
              } catch (e) {
                // FlutterBackgroundService().invoke("closeOverlay");
                EumsApp.instant.closeOverlay();
                rethrow;
              }
            },
            child: Container(
              decoration: BoxDecoration(shape: BoxShape.circle, color: HexColor('#eeeeee')),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Image.asset(!checkSave ? Assets.icons.deleteKeep.path : Assets.icons.saveKeep.path,
                  package: "eums", height: 18, color: AppColor.black),
            )
            // checkSave
            //     ? Image.asset(Assets.saveKeep.path,
            //         package: "eums", height: 30, color: AppColor.black)
            //     : Image.asset(Assets.deleteKeep.path,
            //         package: "eums", height: 30, color: AppColor.black),
            ),
        mission: () {
          if (dataEvent != null && dataEvent['data'] != null) {
            DialogUtils.showDialogRewardPoint(context, data: jsonDecode(dataEvent['data']), voidCallback: () async {
              try {
                setState(() {
                  isWebView = false;
                  checkSave = false;
                });

                // FlutterBackgroundService().invoke("closeOverlay");

                await DeviceApps.openApp('com.app.abeeofferwal');
                final dataTemp = jsonDecode(dataEvent['data']);

                TrueOverlayService().missionOfferWallOutside(
                    advertiseIdx: dataTemp['idx'], pointType: dataTemp['typePoint'], token: tokenSdk, adType: dataTemp['ad_type']);
                EumsApp.instant.closeOverlay();
              } catch (e) {
                // print(e);
                // FlutterBackgroundService().invoke("closeOverlay");
                await EumsApp.instant.closeOverlay();
              }
            });
          }
        },
        urlLink: url,
      ),
    );
  }

  // openWebView() {
  //   dataEvent['isWebView'] = true;
  //   FlutterBackgroundService().invoke("showOverlay", {'data': dataEvent});
  // }

  void onVerticalDragEnd() async {
    if (dy! > (heightScreen - heightScreen * .2)) {
      NotificationHandler.instant.flutterLocalNotificationsPlugin.cancel(NotificationHandler.instant.notificationId);

      try {
        final data = (jsonDecode(dataEvent['data']));
        await TrueOverlayService().saveKeep(advertiseIdx: data['idx'], adType: data['ad_type'], token: tokenSdk!);
        // FlutterBackgroundService().invoke("closeOverlay");

        dynamic dataToast = {};
        dataToast['isToast'] = true;
        dataToast['isWebView'] = null;
        // dataToast['messageToast'] = "광고 보관 완료 후 3일 이내에 받아주세요";
        dataToast['messageToast'] = "광고가 KEEP 추가";
        // FlutterBackgroundService().invoke("showOverlay", {'data': dataToast});
        await EumsApp.instant.jobQueue({'data': dataToast});

        // ignore: empty_catches
      } catch (e) {
        dynamic dataToast = {};
        dataToast['isToast'] = true;
        dataToast['isWebView'] = null;
        dataToast['messageToast'] = "일일 저장량을 초과했습니다.";
        // FlutterBackgroundService().invoke("showOverlay", {'data': dataToast});
        await EumsApp.instant.jobQueue({'data': dataToast});

        // FlutterBackgroundService().invoke("closeOverlay");
        rethrow;
      }
    } else {
      if (dy! < heightScreen * .2) {
        await NotificationHandler.instant.flutterLocalNotificationsPlugin.cancel(NotificationHandler.instant.notificationId);
        if (dataEvent != null) {
          dataEvent['isWebView'] = true;

          // FlutterBackgroundService().invoke("showOverlay", {'data': dataEvent});
          await EumsApp.instant.jobQueue({'data': dataEvent});

          await DeviceApps.openApp('com.app.abeeofferwal');
        } else {
          // FlutterBackgroundService().invoke("closeOverlay");
          await EumsApp.instant.closeOverlay();
        }
      }
    }
  }

  Widget _buildWidgetToast() {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            // Center(
            //   // child: Image.asset(
            //   //   Assets.alertOverlay.path,
            //   //   package: "eums",
            //   //   width: MediaQuery.of(context).size.width - 150,
            //   //   // height: 10,
            //   // ),
            //   child: Assets.icons.alertOverlay.image(
            //     width: MediaQuery.of(context).size.width - 150,
            //   ),
            // ),
            Center(
              child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.black87),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Assets.icons.logo.image(width: 40, height: 40, fit: BoxFit.cover),
                      Padding(
                        padding: const EdgeInsets.only(left: 5, right: 16),
                        child: Text(dataEvent['messageToast'], style: StyleFont.medium().copyWith(color: Colors.white)),
                      ),
                    ],
                  )),
            ),
            const SizedBox(
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
            // child: InkWell(
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Assets.icons.iconLogo.image(
                width: 100,
                height: 100,
              ),
              // child: Image.asset(
              //   Assets.icon_logo.path,
              //   package: "eums",
              //   width: 100,
              //   height: 100,
              // ),
            ),
            // ),
            // ),
          ),
        ));
  }
}
