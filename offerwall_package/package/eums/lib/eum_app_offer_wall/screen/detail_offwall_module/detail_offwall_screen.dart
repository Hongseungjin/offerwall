import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_apps/device_apps.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:dio/dio.dart';
import 'package:eums/common/api.dart';
import 'package:eums/eum_app_offer_wall/widget/toast/app_alert.dart';
import 'package:eums/eum_app_offer_wall/widget/widget_animation_click_v2.dart';
import 'package:eums/eums_library.dart';
import 'package:eums/eums_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_component/events/event_static_component.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/instance_manager.dart';
import 'package:eums/common/constants.dart';
import 'package:eums/common/events/events.dart';
import 'package:eums/common/rx_bus.dart';
import 'package:eums/eum_app_offer_wall/screen/detail_offwall_module/bloc/detail_offwall_bloc.dart';
import 'package:eums/eum_app_offer_wall/screen/join_offerwall_module/join_offerwall_screen.dart';
import 'package:eums/eum_app_offer_wall/screen/purchase_offerwall_internal_module/purchase_offerwall_internal_screen.dart';
import 'package:eums/eum_app_offer_wall/screen/register_link_module/register_link_screen.dart';
import 'package:eums/eum_app_offer_wall/screen/visit_offerwall_module/visit_offerwall_screen.dart';
import 'package:eums/eum_app_offer_wall/utils/hex_color.dart';
import 'package:eums/eum_app_offer_wall/utils/loading_dialog.dart';
import 'package:eums/eum_app_offer_wall/widget/setting_fontsize.dart';
import 'package:eums/gen/assets.gen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../../../common/routing.dart';
import '../../utils/appColor.dart';
import '../../utils/appStyle.dart';
import '../../widget/custom_dialog.dart';

class DetailOffWallScreen extends StatefulWidget {
  const DetailOffWallScreen({Key? key, this.xId, this.type, this.title}) : super(key: key);

  final dynamic xId;
  final dynamic type;
  final String? title;

  @override
  State<DetailOffWallScreen> createState() => _DetailOffWallScreenState();
}

class _DetailOffWallScreenState extends State<DetailOffWallScreen> with WidgetsBindingObserver {
  final GlobalKey<State<StatefulWidget>> globalKey = GlobalKey<State<StatefulWidget>>();
  // FToast fToast = FToast();
  dynamic point;
  dynamic urlApi;
  dynamic dataOfferWallVisit;

  List? _languages = [];
  String lang = '';
  String? title;
  String? thumbnail;
  final controllerGet = Get.put(SettingFontSize());

  final urlGetPackageName = "https://itunes.apple.com/lookup?id=";

  Future<void> _getPreferredLanguages() async {
    try {
      final languages = await Devicelocale.preferredLanguages;
      print((languages != null) ? languages : "unable to get preferred languages");
      setState(() => _languages = languages);
      print("_languages$_languages");
    } on PlatformException {
      print("Error obtaining preferred languages");
    }

    if (_languages?[0] == 'ko-KR') {
      lang = 'kor';
    } else {
      lang = 'eng';
    }
  }

  checkInstallApp() async {
    Uri uri = Uri.parse(urlApi);
    bool isInstalled = false;
    try {
      String packageName = "";
      //Check Platform android
      if (Platform.isAndroid) {
        packageName = uri.queryParameters['id'] ?? '';
      } else
      //Check Platform ios
      if (Platform.isIOS) {
        try {
          int indexID = uri.path.indexOf("/id");
          final appStoreId = uri.path.substring(indexID + 3);
          var response = await http.get(Uri.parse('$urlGetPackageName$appStoreId'));
          final dataJson = jsonDecode(response.body);
          packageName = ((dataJson['results'] as List).first as Map)['bundleId'];
        } catch (e) {
          // Show errors on the screen if any
          AppAlert.showError('$e');
          return false;
        }
      }
      final appName = await EumsPlatformInterface.instance.getAppNameByPackage(packageName);
      if (appName.isNotEmpty == true) {
        isInstalled = true;
      } else {
        isInstalled = false;
      }
    } catch (e) {
      // Show errors on the screen if any
      AppAlert.showError('$e');
      return false;
    }

    return isInstalled;
  }

  @override
  void initState() {
    _registerEventBus();
    _getPreferredLanguages();
    // fToast.init(context);
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _registerEventBus() async {
    RxBus.register<PushLinkImage>().listen((event) {});
  }

  check() async {
    // Uri uri = Uri.parse(urlApi);
    // // List<Application> apps = await DeviceApps.getInstalledApplications(onlyAppsWithLaunchIntent: true, includeSystemApps: true);
    // List<Application> apps = await DeviceApps.getInstalledApplications();
    // for (var app in apps) {
    //   if (app.packageName == uri.queryParameters['id']) {
    //     globalKey.currentContext?.read<DetailOffWallBloc>().add(MissionCompleteOfferWall(xId: widget.xId));
    //   }
    //   // TODO Backend operation
    // }

    final checkInstalled = await checkInstallApp();
    if (checkInstalled == true) {
      globalKey.currentContext?.read<DetailOffWallBloc>().add(MissionCompleteOfferWall(xId: widget.xId));
    }
  }

  void _unregisterEventBus() {
    RxBus.destroy();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _unregisterEventBus();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (widget.type == 'install') {
        check();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DetailOffWallBloc>(
      create: (context) => DetailOffWallBloc()..add(DetailOffWal(xId: widget.xId)),
      child: MultiBlocListener(
        listeners: [
          BlocListener<DetailOffWallBloc, DetailOffWallState>(
            listenWhen: (previous, current) => previous.detailOffWallStatus != current.detailOffWallStatus,
            listener: _listenerDetailOffWall,
          ),
          BlocListener<DetailOffWallBloc, DetailOffWallState>(
            listenWhen: (previous, current) => previous.missionCompleteOfferWallStatus != current.missionCompleteOfferWallStatus,
            listener: _listenerMissionOffWall,
          ),
          BlocListener<DetailOffWallBloc, DetailOffWallState>(
            listenWhen: (previous, current) => previous.visitOfferWallInternalStatus != current.visitOfferWallInternalStatus,
            listener: _listenFetchData,
          ),
          BlocListener<DetailOffWallBloc, DetailOffWallState>(
            listenWhen: (previous, current) => previous.joinOfferWallInternalStatus != current.joinOfferWallInternalStatus,
            listener: _listenJoinOfferWall,
          )
        ],
        child: _buildContent(context),
      ),
    );
  }

  void _listenFetchData(BuildContext context, DetailOffWallState state) {
    if (state.visitOfferWallInternalStatus == VisitOfferWallInternalStatus.loading) {
      LoadingDialog.instance.show();
      return;
    }
    if (state.visitOfferWallInternalStatus == VisitOfferWallInternalStatus.failure) {
      LoadingDialog.instance.hide();
      // AppAlert.showError(context, fToast, '이미 설치되어 있는 앱은 참여불가능합니다');
      AppAlert.showError('이미 설치되어 있는 앱은 참여불가능합니다');

      return;
    }
    if (state.visitOfferWallInternalStatus == VisitOfferWallInternalStatus.success) {
      LoadingDialog.instance.hide();
      EventStaticComponent.instance.call(key: "UpdateUser");
      // RxBus.post(UpdateUser());
      DialogUtils.showDialogMissingPoint(context, data: dataOfferWallVisit['reward'], voidCallback: () {});
    }
  }

  void _listenJoinOfferWall(BuildContext context, DetailOffWallState state) {
    if (state.joinOfferWallInternalStatus == JoinOfferWallInternalStatus.loading) {
      LoadingDialog.instance.show();
      return;
    }
    if (state.joinOfferWallInternalStatus == JoinOfferWallInternalStatus.failure) {
      LoadingDialog.instance.hide();
      return;
    }
    if (state.joinOfferWallInternalStatus == JoinOfferWallInternalStatus.success) {
      LoadingDialog.instance.hide();
      EventStaticComponent.instance.call(key: "UpdateUser");
      // RxBus.post(UpdateUser());
      DialogUtils.showDialogMissingPoint(context, data: dataOfferWallVisit['reward'], voidCallback: () {
        // Navigator.pop(context);
      });
    }
  }

  _listenerMissionOffWall(BuildContext context, DetailOffWallState state) async {
    if (state.missionCompleteOfferWallStatus == MissionCompleteOfferWallStatus.loading) {
      LoadingDialog.instance.show();
      return;
    }

    if (state.missionCompleteOfferWallStatus == MissionCompleteOfferWallStatus.failure) {
      LoadingDialog.instance.hide();
      return;
    }
    if (state.missionCompleteOfferWallStatus == MissionCompleteOfferWallStatus.success) {
      LoadingDialog.instance.hide();
      DialogUtils.showDialogMissingPoint(context, data: point, voidCallback: () {});
      EventStaticComponent.instance.call(key: "UpdateUser");
      // RxBus.post(UpdateUser());
    }
  }

  _listenerDetailOffWall(BuildContext context, DetailOffWallState state) async {
    if (state.detailOffWallStatus == DetailOffWallStatus.loading) {
      LoadingDialog.instance.show();
      return;
    }

    if (state.detailOffWallStatus == DetailOffWallStatus.failure) {
      LoadingDialog.instance.hide();
      return;
    }
    if (state.detailOffWallStatus == DetailOffWallStatus.success) {
      LoadingDialog.instance.hide();
    }
  }

  _fetchData() async {
    globalKey.currentContext?.read<DetailOffWallBloc>().add(VisitOffWall(xId: dataOfferWallVisit['idx'], lang: lang));
  }

  _joinOfferWall(bool checkJoin) async {
    if (checkJoin) {
      globalKey.currentContext?.read<DetailOffWallBloc>().add(JoinOffWall(xId: dataOfferWallVisit['idx'], lang: lang));
    }
  }

  Widget _buildContent(BuildContext context) {
    // print("controllerGet.fontSizeObx.value${controllerGet.fontSizeObx.value}");
    return Scaffold(
        key: globalKey,
        backgroundColor: AppColor.white,
        appBar: AppBar(
          backgroundColor: AppColor.white,
          elevation: 0,
          centerTitle: true,
          title: Text(widget.title ?? '', style: AppStyle.bold.copyWith(fontSize: 2 + controllerGet.fontSizeObx.value, color: AppColor.black)),
          leading: WidgetAnimationClickV2(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Icon(Icons.arrow_back_ios_outlined, color: AppColor.dark, size: 25),
          ),
        ),
        body: BlocBuilder<DetailOffWallBloc, DetailOffWallState>(
          builder: (context, state) {
            if (state.dataDetailOffWall != null) {
              point = state.dataDetailOffWall['reward'] ?? 0;
              if (Platform.isAndroid) {
                urlApi = state.dataDetailOffWall['api'] ?? '';
              }
              if (Platform.isIOS) {
                urlApi = state.dataDetailOffWall['api_ios'] ?? '';
              }
              dataOfferWallVisit = state.dataDetailOffWall;
              title = state.dataDetailOffWall['title'] ?? "";
              thumbnail = state.dataDetailOffWall["sub_thumbnail"] ?? "";
            }
            return state.dataDetailOffWall == null
                ? const SizedBox()
                : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.width,
                                    fit: BoxFit.cover,
                                    imageUrl: state.dataDetailOffWall != null ? "${Constants.baseUrlImage}$thumbnail" : "",
                                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) {
                                      return Assets.logo.image(package: 'eums');
                                    }),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      state.dataDetailOffWall != null ? state.dataDetailOffWall['title'] : "",
                                      maxLines: 1,
                                      style: AppStyle.bold.copyWith(fontSize: 4 + controllerGet.fontSizeObx.value),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      Constants.formatMoney(state.dataDetailOffWall != null ? state.dataDetailOffWall['reward'] : 0, suffix: 'P'),
                                      style: AppStyle.bold.copyWith(fontSize: 4 + controllerGet.fontSizeObx.value, color: HexColor('#f4a43b')),
                                    )
                                  ],
                                ),
                              ),
                              // const Divider(
                              //   color: AppColor.colorC9,
                              //   thickness: 8,
                              // ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Text(
                                  '적립 방법',
                                  style: AppStyle.bold.copyWith(fontSize: 4 + controllerGet.fontSizeObx.value, color: AppColor.black),
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: buidlHtml(html: state.dataDetailOffWall != null ? state.dataDetailOffWall['description'] : '')),
                              const SizedBox(height: 16),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                color: HexColor('#f9f9f9'),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      // '적립 방법',
                                      '주의사항',
                                      style: AppStyle.bold.copyWith(fontSize: 4 + controllerGet.fontSizeObx.value, color: AppColor.black),
                                    ),
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16),
                                      child: buidlHtml(html: state.dataDetailOffWall != null ? state.dataDetailOffWall['precaution'] : ''),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // InkWell(
                              //   onTap: () {
                              //     Routing().navigate(context, RequestScreen());
                              //   },
                              //   child: Container(
                              //     margin: const EdgeInsets.symmetric(horizontal: 16),
                              //     padding: const EdgeInsets.symmetric(vertical: 16),
                              //     width: MediaQuery.of(context).size.width,
                              //     decoration: BoxDecoration(
                              //         borderRadius: BorderRadius.circular(8),
                              //         color: AppColor.colorC9.withOpacity(0.5)),
                              //     child: Text(
                              //       AppString.earningInquiry,
                              //       style: AppStyle.medium.copyWith(
                              //           fontSize: 16, color: AppColor.black),
                              //       textAlign: TextAlign.center,
                              //     ),
                              //   ),
                              // ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: WidgetAnimationClickV2(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          borderRadius: BorderRadius.circular(8),
                          color: AppColor.yellow,
                          onTap: () async {
                            debugPrint("xxxx: ${widget.type}");
                            if (widget.type == 'install') {
                              final isInstalled = await checkInstallApp();
                              if (isInstalled == false) {
                                launchUrl(
                                  Uri.parse(urlApi),
                                );
                              } else {
                                // ignore: use_build_context_synchronously
                                // AppAlert.showError(context, fToast, '이미 설치되어 있는 앱은 참여불가능합니다');
                                AppAlert.showError('이미 설치되어 있는 앱은 참여불가능합니다');
                                check();
                              }
                            } else if (widget.type == 'visit') {
                              print("visit?");
                              Routings().navigate(
                                  context,
                                  VisitOfferWallScren(
                                    data: state.dataDetailOffWall,
                                    voidCallBack: _fetchData,
                                  ));
                            } else if (widget.type == 'join') {
                              Routings().navigate(
                                  context,
                                  JoinOfferWallScreen(
                                    data: state.dataDetailOffWall,
                                    onCallBack: _joinOfferWall,
                                  ));
                            } else if (widget.type == 'shopping') {
                              Routings().navigate(
                                  context,
                                  PurchaseOfferwallInternalScreen(
                                    data: state.dataDetailOffWall,
                                  ));
                            } else if (widget.type == 'subscribe') {
                              Routings().navigate(
                                  context,
                                  RegisterLinkScreen(
                                    data: state.dataDetailOffWall,
                                  ));
                            }
                          },
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              '참여하고 포인트 받기',
                              style: AppStyle.bold.copyWith(fontSize: 2 + controllerGet.fontSizeObx.value, color: AppColor.black),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
          },
        ));
  }

  buidlHtml({String? html}) {
    return HtmlWidget(
      html ?? '',
      customStylesBuilder: (e) {
        if (e.classes.contains('ql-align-center')) {
          return {'text-align': 'center'};
        }

        return null;
      },
    );
  }
}
