import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_apps/device_apps.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/instance_manager.dart';
import 'package:sdk_eums/common/constants.dart';
import 'package:sdk_eums/common/events/events.dart';
import 'package:sdk_eums/common/rx_bus.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/detail_offwall_module/bloc/detail_offwall_bloc.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/join_offerwall_module/join_offerwall_screen.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/purchase_offerwall_internal_module/purchase_offerwall_internal_screen.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/register_link_module/register_link_screen.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/visit_offerwall_module/visit_offerwall_screen.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/hex_color.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/loading_dialog.dart';
import 'package:sdk_eums/eum_app_offer_wall/widget/app_alert.dart';
import 'package:sdk_eums/eum_app_offer_wall/widget/setting_fontsize.dart';
import 'package:sdk_eums/gen/assets.gen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/routing.dart';
import '../../utils/appColor.dart';
import '../../utils/appStyle.dart';
import '../../widget/custom_dialog.dart';

class DetailOffWallScreen extends StatefulWidget {
  const DetailOffWallScreen({Key? key, this.xId, this.type, this.title})
      : super(key: key);

  final dynamic xId;
  final dynamic type;
  final String? title;

  @override
  State<DetailOffWallScreen> createState() => _DetailOffWallScreenState();
}

class _DetailOffWallScreenState extends State<DetailOffWallScreen>
    with WidgetsBindingObserver {
  final GlobalKey<State<StatefulWidget>> globalKey =
      GlobalKey<State<StatefulWidget>>();
  FToast fToast = FToast();
  dynamic point;
  dynamic urlApi;
  dynamic dataOfferWallVisit;

  List? _languages = [];
  String lang = '';
  String? title;
  final controllerGet = Get.put(SettingFontSize());

  Future<void> _getPreferredLanguages() async {
    try {
      final languages = await Devicelocale.preferredLanguages;
      print((languages != null)
          ? languages
          : "unable to get preferred languages");
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
      isInstalled =
          await DeviceApps.isAppInstalled(uri.queryParameters['id'] ?? '');
    } catch (e) {
      AppAlert.showError(context, fToast, '$e');
    }
    if (isInstalled == false) {
      launch(urlApi);
    } else {
      // ignore: use_build_context_synchronously
      AppAlert.showError(context, fToast, '이미 설치되어 있는 앱은 참여불가능합니다');
    }
  }

  @override
  void initState() {
    _registerEventBus();
    _getPreferredLanguages();
    fToast.init(context);
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _registerEventBus() async {
    RxBus.register<PushLinkImage>().listen((event) {});
  }

  check() async {
    Uri uri = Uri.parse(urlApi);
    List<Application> apps = await DeviceApps.getInstalledApplications(
        onlyAppsWithLaunchIntent: true, includeSystemApps: true);
    apps.forEach((app) {
      if (app.packageName == uri.queryParameters['id']) {
        globalKey.currentContext
            ?.read<DetailOffWallBloc>()
            .add(MissionCompleteOfferWall(xId: widget.xId));
      }

      // TODO Backend operation
    });
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
      create: (context) =>
          DetailOffWallBloc()..add(DetailOffWal(xId: widget.xId)),
      child: MultiBlocListener(
        listeners: [
          BlocListener<DetailOffWallBloc, DetailOffWallState>(
            listenWhen: (previous, current) =>
                previous.detailOffWallStatus != current.detailOffWallStatus,
            listener: _listenerDetailOffWall,
          ),
          BlocListener<DetailOffWallBloc, DetailOffWallState>(
            listenWhen: (previous, current) =>
                previous.missionCompleteOfferWallStatus !=
                current.missionCompleteOfferWallStatus,
            listener: _listenerMissionOffWall,
          ),
          BlocListener<DetailOffWallBloc, DetailOffWallState>(
            listenWhen: (previous, current) =>
                previous.visitOfferWallInternalStatus !=
                current.visitOfferWallInternalStatus,
            listener: _listenFetchData,
          ),
          BlocListener<DetailOffWallBloc, DetailOffWallState>(
            listenWhen: (previous, current) =>
                previous.joinOfferWallInternalStatus !=
                current.joinOfferWallInternalStatus,
            listener: _listenJoinOfferWall,
          )
        ],
        child: _buildContent(context),
      ),
    );
  }

  void _listenFetchData(BuildContext context, DetailOffWallState state) {
    if (state.visitOfferWallInternalStatus ==
        VisitOfferWallInternalStatus.loading) {
      LoadingDialog.instance.show();
      return;
    }
    if (state.visitOfferWallInternalStatus ==
        VisitOfferWallInternalStatus.failure) {
      LoadingDialog.instance.hide();
      AppAlert.showError(context, fToast, '이미 설치되어 있는 앱은 참여불가능합니다');

      return;
    }
    if (state.visitOfferWallInternalStatus ==
        VisitOfferWallInternalStatus.success) {
      LoadingDialog.instance.hide();
      RxBus.post(UpdateUser());
      DialogUtils.showDialogMissingPoint(context,
          data: dataOfferWallVisit['reward'], voidCallback: () {});
    }
  }

  void _listenJoinOfferWall(BuildContext context, DetailOffWallState state) {
    if (state.joinOfferWallInternalStatus ==
        JoinOfferWallInternalStatus.loading) {
      LoadingDialog.instance.show();
      return;
    }
    if (state.joinOfferWallInternalStatus ==
        JoinOfferWallInternalStatus.failure) {
      LoadingDialog.instance.hide();
      return;
    }
    if (state.joinOfferWallInternalStatus ==
        JoinOfferWallInternalStatus.success) {
      LoadingDialog.instance.hide();
      RxBus.post(UpdateUser());
      DialogUtils.showDialogMissingPoint(context,
          data: dataOfferWallVisit['reward'], voidCallback: () {
        // Navigator.pop(context);
      });
    }
  }

  _listenerMissionOffWall(
      BuildContext context, DetailOffWallState state) async {
    if (state.missionCompleteOfferWallStatus ==
        MissionCompleteOfferWallStatus.loading) {
      LoadingDialog.instance.show();
      return;
    }

    if (state.missionCompleteOfferWallStatus ==
        MissionCompleteOfferWallStatus.failure) {
      LoadingDialog.instance.hide();
      return;
    }
    if (state.missionCompleteOfferWallStatus ==
        MissionCompleteOfferWallStatus.success) {
      LoadingDialog.instance.hide();
      DialogUtils.showDialogMissingPoint(context,
          data: point, voidCallback: () {});
      RxBus.post(UpdateUser());
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
    globalKey.currentContext
        ?.read<DetailOffWallBloc>()
        .add(VisitOffWall(xId: dataOfferWallVisit['idx'], lang: lang));
  }

  _joinOfferWall(bool checkJoin) async {
    if (checkJoin) {
      globalKey.currentContext
          ?.read<DetailOffWallBloc>()
          .add(JoinOffWall(xId: dataOfferWallVisit['idx'], lang: lang));
    }
  }

  Widget _buildContent(BuildContext context) {
    return Scaffold(
        key: globalKey,
        backgroundColor: AppColor.white,
        appBar: AppBar(
          backgroundColor: AppColor.white,
          elevation: 0,
          centerTitle: true,
          title: Text(widget.title ?? '',
              style: AppStyle.bold.copyWith(
                  fontSize: 16 + controllerGet.fontSizeObx.value,
                  color: AppColor.black)),
          leading: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Icon(Icons.arrow_back_ios_outlined,
                color: AppColor.dark, size: 25),
          ),
        ),
        body: BlocBuilder<DetailOffWallBloc, DetailOffWallState>(
          builder: (context, state) {
            if (state.dataDetailOffWall != null) {
              point = state.dataDetailOffWall['reward'] ?? 0;
              urlApi = state.dataDetailOffWall['api'] ?? '';
              dataOfferWallVisit = state.dataDetailOffWall;
              title = state.dataDetailOffWall['title'] ?? "";
            }
            return state.dataDetailOffWall == null
                ? SizedBox()
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                              imageUrl: state.dataDetailOffWall != null
                                  ? "${Constants.baseUrlImage}${state.dataDetailOffWall['thumbnail']}"
                                  : "",
                              placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) {
                                return Assets.logo.image();
                              }),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.dataDetailOffWall != null
                                    ? state.dataDetailOffWall['title']
                                    : "",
                                maxLines: 1,
                                style: AppStyle.bold.copyWith(
                                    fontSize:
                                        18 + controllerGet.fontSizeObx.value),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                Constants.formatMoney(
                                    state.dataDetailOffWall != null
                                        ? state.dataDetailOffWall['reward']
                                        : 0,
                                    suffix: 'P'),
                                style: AppStyle.bold.copyWith(
                                    fontSize:
                                        18 + controllerGet.fontSizeObx.value,
                                    color: HexColor('#f4a43b')),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Text(
                            '적립 방법',
                            style: AppStyle.bold.copyWith(
                                fontSize: 18 + controllerGet.fontSizeObx.value,
                                color: AppColor.black),
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            child: buidlHtml(
                                html: state.dataDetailOffWall != null
                                    ? state.dataDetailOffWall['description']
                                    : '')),
                        const SizedBox(height: 16),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          color: HexColor('#f9f9f9'),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '적립 방법',
                                style: AppStyle.bold.copyWith(
                                    fontSize:
                                        18 + controllerGet.fontSizeObx.value,
                                    color: AppColor.black),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: buidlHtml(
                                    html: state.dataDetailOffWall != null
                                        ? state.dataDetailOffWall['precaution']
                                        : ''),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () {
                            if (widget.type == 'install') {
                              checkInstallApp();
                            } else if (widget.type == 'visit') {
                              print("visit?");
                              Routing().navigate(
                                  context,
                                  VisitOfferWallScren(
                                    data: state.dataDetailOffWall,
                                    voidCallBack: _fetchData,
                                  ));
                            } else if (widget.type == 'join') {
                              Routing().navigate(
                                  context,
                                  JoinOfferWallScreen(
                                    data: state.dataDetailOffWall,
                                    onCallBack: _joinOfferWall,
                                  ));
                            } else if (widget.type == 'shopping') {
                              Routing().navigate(
                                  context,
                                  PurchaseOfferwallInternalScreen(
                                    data: state.dataDetailOffWall,
                                  ));
                            } else if (widget.type == 'subscribe') {
                              Routing().navigate(
                                  context,
                                  RegisterLinkScreen(
                                    data: state.dataDetailOffWall,
                                  ));
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: AppColor.yellow),
                            child: Text(
                              '참여하고 포인트 받기',
                              style: AppStyle.bold.copyWith(
                                  fontSize:
                                      16 + controllerGet.fontSizeObx.value,
                                  color: AppColor.black),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
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
