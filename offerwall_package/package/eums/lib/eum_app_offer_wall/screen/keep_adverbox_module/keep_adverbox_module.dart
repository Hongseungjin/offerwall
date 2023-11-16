import 'dart:async';

import 'package:eums/eum_app_offer_wall/widget/toast/app_alert.dart';
import 'package:eums/eum_app_offer_wall/widget/widget_animation_click_v2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/instance_manager.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:eums/common/constants.dart';
import 'package:eums/common/routing.dart';
import 'package:eums/common/rx_bus.dart';
import 'package:eums/eum_app_offer_wall/screen/keep_adverbox_module/bloc/keep_adverbox_bloc.dart';
import 'package:eums/eum_app_offer_wall/screen/report_module/report_page.dart';
import 'package:eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:eums/eum_app_offer_wall/utils/appStyle.dart';
import 'package:eums/eum_app_offer_wall/utils/hex_color.dart';
import 'package:eums/eum_app_offer_wall/utils/loading_dialog.dart';
import 'package:eums/eum_app_offer_wall/widget/widget_animation_click.dart';
import 'package:eums/eum_app_offer_wall/widget/custom_dialog.dart';
import 'package:eums/eum_app_offer_wall/widget/custom_webview_keep.dart';
import 'package:eums/eum_app_offer_wall/widget/setting_fontsize.dart';
import 'package:eums/gen/assets.gen.dart';

import '../../../common/events/rx_events.dart';

class KeepAdverboxScreen extends StatefulWidget {
  const KeepAdverboxScreen({Key? key}) : super(key: key);

  @override
  State<KeepAdverboxScreen> createState() => _KeepAdverboxScreenState();
}

class _KeepAdverboxScreenState extends State<KeepAdverboxScreen> {
  final GlobalKey<State<StatefulWidget>> globalKey = GlobalKey<State<StatefulWidget>>();
  RefreshController refreshController = RefreshController(initialRefresh: false);
  dynamic numberDay;
  final controllerGet = Get.put(SettingFontSize());

  @override
  void initState() {
    _registerEventBus();
    super.initState();
  }

  Future<void> _registerEventBus() async {
    RxBus.register<RefreshDataKeep>().listen((event) {
      _onRefresh();
    });

    RxBus.register<ShowDataAdver>(tag: Constants.showDataAdver).listen((event) {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<KeepAdverboxBloc>(
      create: (context) => KeepAdverboxBloc()..add(KeepAdverbox(limit: Constants.LIMIT_DATA)),
      child: BlocListener<KeepAdverboxBloc, KeepAdverboxState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: _listenFetchData,
        child: BlocBuilder<KeepAdverboxBloc, KeepAdverboxState>(
          builder: (context, state) {
            return _buildContent(context, state.dataKeepAdverbox);
          },
        ),
      ),
    );
  }

  void _listenFetchData(BuildContext context, KeepAdverboxState state) {
    if (state.status == KeepAdverboxStatus.loading) {
      LoadingDialog.instance.show();
      return;
    }
    if (state.status == KeepAdverboxStatus.failure) {
      LoadingDialog.instance.hide();
      return;
    }
    if (state.status == KeepAdverboxStatus.success) {
      LoadingDialog.instance.hide();
    }
  }

  DateTime now = DateTime.now();

  Scaffold _buildContent(context, dynamic data) {
    return Scaffold(
      key: globalKey,
      backgroundColor: AppColor.white,
      appBar: AppBar(
        backgroundColor: AppColor.white,
        elevation: 1,
        centerTitle: true,
        title: Text('광고 보관함', style: AppStyle.bold.copyWith(fontSize: 2 + controllerGet.fontSizeObx.value, color: AppColor.black)),
        leading: InkWell(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(Icons.arrow_back_ios_outlined, color: AppColor.dark, size: 25),
        ),
      ),
      body: SmartRefresher(
        controller: refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        header: CustomHeader(
          builder: (BuildContext context, RefreshStatus? mode) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.transparent)));
          },
        ),
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus? mode) {
            return mode == LoadStatus.loading
                ? const Center(
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.black)),
                  )
                : Container();
          },
        ),
        enablePullDown: true,
        enablePullUp: true,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Container(
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //   decoration: BoxDecoration(
              //       color: AppColor.red4.withOpacity(0.3),
              //       borderRadius: BorderRadius.circular(12)),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text('광고 볼 시간이 없다면',
              //           style: AppStyle.medium.copyWith(fontSize: 20)),
              //       RichText(
              //           text: TextSpan(
              //               text: '보관',
              //               style: AppStyle.bold
              //                   .copyWith(color: Colors.blue, fontSize: 25),
              //               children: [
              //             TextSpan(
              //               text: '해두고 나중에 보세요~!',
              //               style: AppStyle.bold
              //                   .copyWith(color: AppColor.black, fontSize: 25),
              //             )
              //           ])),
              //       const SizedBox(height: 5),
              //       RichText(
              //           text: TextSpan(
              //               text: '* 하루 최대 20개',
              //               style: AppStyle.regular
              //                   .copyWith(color: AppColor.red, fontSize: 12),
              //               children: [
              //             TextSpan(
              //               text: '까지 가능합니다.',
              //               style: AppStyle.regular.copyWith(
              //                   color: AppColor.color70, fontSize: 12),
              //             )
              //           ])),
              //       const SizedBox(height: 2),
              //       RichText(
              //           text: TextSpan(
              //               text: '* 3일동안 보관',
              //               style: AppStyle.regular
              //                   .copyWith(color: AppColor.red, fontSize: 12),
              //               children: [
              //             TextSpan(
              //               text: '되며, 3일이 지난 광고는 다른 사람에게 갑니다',
              //               style: AppStyle.regular.copyWith(
              //                   color: AppColor.color70, fontSize: 12),
              //             )
              //           ])),
              //       const SizedBox(height: 2),
              //       Text(
              //         '*광고가 만료되거나 소멸되면 저장된 광고가 사라질 수도 있습니다.',
              //         style: AppStyle.regular
              //             .copyWith(color: AppColor.color70, fontSize: 12),
              //       ),
              //     ],
              //   ),
              // ),

              // Image.asset(
              //   Assets.banner_keep.path,
              //   package: "eums",
              //   // height: 40,
              // ),
              Assets.icons.bannerKeep.image(),
              Container(
                height: 5,
                width: MediaQuery.of(context).size.width,
                color: const Color(0xfff4f4f4),
              ),
              // const Divider(),
              data != null
                  ? Wrap(
                      children: List.generate(data.length, (index) {
                        return Container(
                          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: HexColor('#f4f4f4')))),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                          child: WidgetAnimationClick(
                            onTap: () {
                              Routings().navigate(
                                  context,
                                  DetailKeepScreen(
                                    data: data[index],
                                    // urlImage: data[index][''],
                                    // url: data[index]['url_link'],
                                    // id: data[index]['advertiseIdx'],
                                    // idx: data[index]['idx'],
                                    // typePoint: data[index]['typePoint'],
                                  ));
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  // child: Image.asset(
                                  //   Assets.scrap_adver.path,
                                  //   package: "eums",
                                  //   height: 40,
                                  //   width: 40,
                                  // ),
                                  child: Assets.icons.scrapAdver.image(
                                    height: 40,
                                    width: 40,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${data[index]['name'] ?? ''}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppStyle.bold.copyWith(color: AppColor.black, fontSize: controllerGet.fontSizeObx.value),
                                      ),
                                      const SizedBox(height: 4),
                                      RichText(
                                          text: TextSpan(
                                              text: '남은 기간 ',
                                              style: AppStyle.regular
                                                  .copyWith(color: HexColor('#888888'), fontSize: controllerGet.fontSizeObx.value - 2),
                                              children: [
                                            TextSpan(
                                              text: ' 2',
                                              style:
                                                  AppStyle.bold.copyWith(color: HexColor('#888888'), fontSize: controllerGet.fontSizeObx.value - 2),
                                            ),
                                            TextSpan(
                                              text: ' 일',
                                              style: AppStyle.regular
                                                  .copyWith(color: HexColor('#888888'), fontSize: controllerGet.fontSizeObx.value - 2),
                                            )
                                          ])),
                                      const SizedBox(height: 4),
                                      Text(
                                        '보관한 날짜 ${Constants.formatTimeNew(data[index]['regist_date'] ?? '')} ',
                                        maxLines: 3,
                                        style: AppStyle.medium.copyWith(color: HexColor('#888888'), fontSize: controllerGet.fontSizeObx.value - 2),
                                      ),
                                    ],
                                  ),
                                ),
                                WidgetAnimationClickV2(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                                  color: HexColor('#fdd000'),
                                  borderRadius: BorderRadius.circular(5),
                                  onTap: () {
                                    Routings().navigate(
                                        context,
                                        DetailKeepScreen(
                                          data: data[index],
                                          // urlImage: data[index][''],
                                          // url: data[index]['url_link'],
                                          // id: data[index]['advertiseIdx'],
                                          // idx: data[index]['idx'],
                                          // typePoint: data[index]['typePoint'],
                                        ));
                                  },
                                  child: Text(
                                    '광고보기',
                                    style: AppStyle.bold.copyWith(fontSize: controllerGet.fontSizeObx.value),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                    )
                  : const SizedBox()
            ],
          ),
        ),
      ),
    );
  }

  int getDayLeft(String? dateTo) {
    if (dateTo != null && dateTo.isNotEmpty == true) {
      DateTime parseDtFrom = DateTime.parse(dateTo).toLocal();
      DateTime parseDtTo = DateTime.parse(dateTo).toLocal().add(const Duration(days: 2));
      return parseDtTo.difference(parseDtFrom).inDays > 1 ? parseDtTo.difference(parseDtFrom).inDays : parseDtTo.day - parseDtFrom.day;
    } else {
      return -1;
    }
  }

  void _onRefresh() async {
    await Future.delayed(const Duration(seconds: 0));
    refreshController.refreshCompleted();
    _fetchData();
  }

  _fetchData() async {
    globalKey.currentContext?.read<KeepAdverboxBloc>().add(KeepAdverbox(limit: Constants.LIMIT_DATA));
  }

  void _onLoading() async {
    await Future.delayed(const Duration(seconds: 0));
    refreshController.loadComplete();
    List<dynamic>? dataKeep = globalKey.currentContext?.read<KeepAdverboxBloc>().state.dataKeepAdverbox;
    if (dataKeep != null) {
      globalKey.currentContext?.read<KeepAdverboxBloc>().add(LoadMoreKeepAdverbox(limit: Constants.LIMIT_DATA, offset: dataKeep.length));
    }
  }
}

class DetailKeepScreen extends StatefulWidget {
  const DetailKeepScreen({Key? key, this.data}) : super(key: key);

  final dynamic data;

  @override
  State<DetailKeepScreen> createState() => _DetailKeepScreenState();
}

class _DetailKeepScreenState extends State<DetailKeepScreen> {
  final GlobalKey<State<StatefulWidget>> globalKey = GlobalKey<State<StatefulWidget>>();
  // FToast fToast = FToast();

  final _controller = ScrollController();
  final controllerGet = Get.put(SettingFontSize());

  @override
  void initState() {
    // fToast.init(context);
    // TODO: implement initStat
    super.initState();
    checkSave = widget.data['isScrap'] ?? false;

    _controller.addListener(() {
      if (_controller.position.atEdge) {
        bool isTop = _controller.position.pixels == 0;
        if (isTop) {
          print('At the top');
        } else {
          print('At the bottom');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<KeepAdverboxBloc>(
        create: (context) => KeepAdverboxBloc()
          ..add(KeepAdverbox(limit: Constants.LIMIT_DATA))
          ..add(GetAdvertiseSponsor()),
        child: MultiBlocListener(listeners: [
          BlocListener<KeepAdverboxBloc, KeepAdverboxState>(
            listenWhen: (previous, current) => previous.deleteKeepStatus != current.deleteKeepStatus,
            listener: _listenFetchData,
          ),
          BlocListener<KeepAdverboxBloc, KeepAdverboxState>(
            listenWhen: (previous, current) => previous.adverKeepStatus != current.adverKeepStatus,
            listener: _listenPointFetchData,
          ),
          BlocListener<KeepAdverboxBloc, KeepAdverboxState>(
            listenWhen: (previous, current) => previous.saveKeepStatus != current.saveKeepStatus,
            listener: _listenSaveKeep,
          ),
          BlocListener<KeepAdverboxBloc, KeepAdverboxState>(
            listenWhen: (previous, current) => previous.saveScrapStatus != current.saveScrapStatus,
            listener: _listenSaveScrap,
          ),
        ], child: _buildContent(context)));
  }

  void _listenSaveScrap(BuildContext context, KeepAdverboxState state) {
    if (state.saveScrapStatus == SaveScrapStatus.loading) {
      // EasyLoading.show();
      return;
    }
    if (state.saveScrapStatus == SaveScrapStatus.failure) {
      // EasyLoading.dismiss();
      return;
    }
    if (state.saveScrapStatus == SaveScrapStatus.success) {
      // AppAlert.showSuccess("Success");
      AppAlert.showSuccess("광고 스크랩을 완료하였습니다", type: AppAlertType.bottom);
    }
  }

  void _listenPointFetchData(BuildContext context, KeepAdverboxState state) {
    if (state.adverKeepStatus == AdverKeepStatus.loading) {
      // EasyLoading.show();
      return;
    }
    if (state.adverKeepStatus == AdverKeepStatus.failure) {
      // EasyLoading.dismiss();
      return;
    }
    if (state.adverKeepStatus == AdverKeepStatus.success) {
      RxBus.post(UpdateUser());
      RxBus.post(RefreshDataKeep());
      Navigator.pop(context);
      // AppAlert.showSuccess(context, fToast, "Success");
      AppAlert.showSuccess("Success");
    }
  }

  void _listenSaveKeep(BuildContext context, KeepAdverboxState state) {
    if (state.saveKeepStatus == SaveKeepStatus.loading) {
      // EasyLoading.show();
      return;
    }
    if (state.saveKeepStatus == SaveKeepStatus.failure) {
      // EasyLoading.dismiss();
      return;
    }
    if (state.saveKeepStatus == SaveKeepStatus.success) {
      RxBus.post(UpdateUser());
    }
  }

  void _listenFetchData(BuildContext context, KeepAdverboxState state) {
    if (state.deleteKeepStatus == DeleteKeepStatus.loading) {
      // EasyLoading.show();
      return;
    }
    if (state.deleteKeepStatus == DeleteKeepStatus.failure) {
      // EasyLoading.dismiss();
      return;
    }
    if (state.deleteKeepStatus == DeleteKeepStatus.success) {
      RxBus.post(RefreshDataKeep());
      // Navigator.pop(context);
      // AppAlert.showSuccess(context, fToast, "Success");
    }
  }

  double? dyStart;
  double? dy;
  bool checkSave = false;

  onVerticalDrapEnd(DragEndDetails details) {}

  _buildContent(BuildContext context) {
    return Scaffold(
        key: globalKey,
        body: BlocBuilder<KeepAdverboxBloc, KeepAdverboxState>(
          builder: (context, state) {
            return CustomWebViewKeep(
              urlLink: widget.data['url_link'],
              // uriImage: widget.data[''],
              title: widget.data['name'],

              report: InkWell(
                  onTap: () async {
                    final result = await Routings().navigate(
                        context,
                        ReportPage(
                          data: widget.data,
                          deleteAdver: true,
                        ));

                    if (result == true) {
                      // ignore: use_build_context_synchronously
                      // AppAlert.showSuccess(context, fToast, "Success");
                      AppAlert.showSuccess("Success");
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    // child: Image.asset(Assets.report.path, package: "eums", height: 16),
                    child: Assets.icons.report.image(height: 16),
                  )),
              bookmark: InkWell(
                onTap: () {
                  setState(() {
                    checkSave = !checkSave;
                  });
                  if (checkSave) {
                    globalKey.currentContext
                        ?.read<KeepAdverboxBloc>()
                        .add(SaveScrap(advertiseIdx: widget.data['advertiseIdx'], adType: widget.data['ad_type']));
                  } else {
                    globalKey.currentContext?.read<KeepAdverboxBloc>().add(DeleteScrap(idx: widget.data['idx']));
                  }
                },
                child: Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, color: HexColor('#eeeeee')),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Image.asset(!checkSave ? Assets.icons.deleteKeep.path : Assets.icons.saveKeep.path,
                      package: "eums", height: 18, color: AppColor.black),
                ),
              ),
              mission: () {
                DialogUtils.showDialogRewardPoint(context, checkImage: true, point: widget.data['typePoint'], data: (state.dataAdvertiseSponsor),
                    voidCallback: () {
                  // context.read<KeepAdverboxBloc>().add(DeleteKeep(id: widget.data['advertiseIdx']));
                  context.read<KeepAdverboxBloc>().add(DeleteKeep(idx: widget.data['idx']));
                  globalKey.currentContext
                      ?.read<KeepAdverboxBloc>()
                      .add(EarnPoint(advertiseIdx: widget.data['advertiseIdx'], pointType: widget.data['typePoint'], adType: widget.data['ad_type']));
                });
              },
            );
          },
        ));
  }
}
