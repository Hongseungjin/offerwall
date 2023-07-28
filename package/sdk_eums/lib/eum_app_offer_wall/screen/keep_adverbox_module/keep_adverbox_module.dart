import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sdk_eums/common/constants.dart';
import 'package:sdk_eums/common/routing.dart';
import 'package:sdk_eums/common/rx_bus.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/keep_adverbox_module/bloc/keep_adverbox_bloc.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appStyle.dart';
import 'package:sdk_eums/eum_app_offer_wall/widget/app_alert.dart';
import 'package:sdk_eums/eum_app_offer_wall/widget/custom_dialog.dart';
import 'package:sdk_eums/eum_app_offer_wall/widget/custom_webview_keep.dart';
import 'package:sdk_eums/gen/assets.gen.dart';

import '../../../common/events/rx_events.dart';

class KeepAdverboxScreen extends StatefulWidget {
  const KeepAdverboxScreen({Key? key}) : super(key: key);

  @override
  State<KeepAdverboxScreen> createState() => _KeepAdverboxScreenState();
}

class _KeepAdverboxScreenState extends State<KeepAdverboxScreen> {
  final GlobalKey<State<StatefulWidget>> globalKey =
      GlobalKey<State<StatefulWidget>>();
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  dynamic numberDay;

  @override
  void initState() {
    _registerEventBus();
    super.initState();
  }

  Future<void> _registerEventBus() async {
    RxBus.register<RefreshDataKeep>().listen((event) {
      _onRefresh();
    });

    RxBus.register<ShowDataAdver>(tag: Constants.showDataAdver)
        .listen((event) {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<KeepAdverboxBloc>(
      create: (context) =>
          KeepAdverboxBloc()..add(KeepAdverbox(limit: Constants.LIMIT_DATA)),
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
      // EasyLoading.show();
      return;
    }
    if (state.status == KeepAdverboxStatus.failure) {
      // EasyLoading.dismiss();
      // AppAlert.showError(
      //     fToast,
      //     state.error != null
      //         ? state.error!.message != null
      //             ? state.error!.message!
      //             : 'Error!'
      //         : 'Error!');
      return;
    }
    if (state.status == KeepAdverboxStatus.success) {
      // EasyLoading.dismiss();
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
        title: Text('광고 보관함',
            style: AppStyle.bold.copyWith(fontSize: 16, color: AppColor.black)),
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(Icons.arrow_back_ios_outlined,
              color: AppColor.dark, size: 25),
        ),
      ),
      body: SmartRefresher(
        controller: refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        header: CustomHeader(
          builder: (BuildContext context, RefreshStatus? mode) {
            return const Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.transparent)));
          },
        ),
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus? mode) {
            return mode == LoadStatus.loading
                ? Center(
                    child: Column(
                    children: const [
                      Text(' '),
                      CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black)),
                    ],
                  ))
                : Container();
          },
        ),
        enablePullDown: true,
        enablePullUp: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                      color: AppColor.red4.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('광고 볼 시간이 없다면',
                          style: AppStyle.medium.copyWith(fontSize: 20)),
                      RichText(
                          text: TextSpan(
                              text: '보관',
                              style: AppStyle.bold
                                  .copyWith(color: Colors.blue, fontSize: 25),
                              children: [
                            TextSpan(
                              text: '해두고 나중에 보세요~!',
                              style: AppStyle.bold.copyWith(
                                  color: AppColor.black, fontSize: 25),
                            )
                          ])),
                      const SizedBox(height: 5),
                      RichText(
                          text: TextSpan(
                              text: '* 하루 최대 20개',
                              style: AppStyle.regular
                                  .copyWith(color: AppColor.red, fontSize: 12),
                              children: [
                            TextSpan(
                              text: '까지 가능합니다.',
                              style: AppStyle.regular.copyWith(
                                  color: AppColor.color70, fontSize: 12),
                            )
                          ])),
                      const SizedBox(height: 2),
                      RichText(
                          text: TextSpan(
                              text: '* 3일동안 보관',
                              style: AppStyle.regular
                                  .copyWith(color: AppColor.red, fontSize: 12),
                              children: [
                            TextSpan(
                              text: '되며, 3일이 지난 광고는 다른 사람에게 갑니다',
                              style: AppStyle.regular.copyWith(
                                  color: AppColor.color70, fontSize: 12),
                            )
                          ])),
                      const SizedBox(height: 2),
                      Text(
                        '*광고가 만료되거나 소멸되면 저장된 광고가 사라질 수도 있습니다.',
                        style: AppStyle.regular
                            .copyWith(color: AppColor.color70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                data != null
                    ? Wrap(
                        children: List.generate(data.length, (index) {
                          return GestureDetector(
                            onTap: () {
                        
                              Routing().navigate(
                                  context,
                                  DetailKeepScreen(
                                    urlImage: data[index][''],
                                    url: data[index]['url_link'],
                                    id: data[index]['advertiseIdx'],
                                    idx: data[index]['idx'],
                                    typePoint: data[index]['typePoint'],
                                  ));
                            },
                            child: Column(
                              children: [
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Image.asset(
                                      Assets.saveAdverbox.path,
                                      package: "sdk_eums",
                                      height: 40,
                                    ),
                                    // Assets.icons.saveAdverbox.image(height: 40),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      child: Text(
                                        '${data[index]['name'] ?? ''}',
                                        maxLines: 2,
                                        style: AppStyle.bold.copyWith(
                                            color: AppColor.black,
                                            fontSize: 14),
                                      ),
                                    ),
                                    // Text(
                                    //   '(소상공인 광고)',
                                    //   style: AppStyle.regular.copyWith(
                                    //       color: AppColor.black, fontSize: 14),
                                    // ),
                                    const Spacer(),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '광고 남은 기간',
                                          style: AppStyle.medium.copyWith(
                                              color: AppColor.grey5D,
                                              fontSize: 10),
                                        ),
                                        Text(
                                          '${getDayLeft(data[index]['regist_date'])} 일',
                                          style: AppStyle.bold.copyWith(
                                              color: AppColor.black,
                                              fontSize: 16),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Divider(),
                              ],
                            ),
                          );
                        }),
                      )
                    : SizedBox()
              ],
            ),
          ),
        ),
      ),
    );
  }

  int getDayLeft(String? dateTo) {
    if (dateTo != null && dateTo.isNotEmpty) {
      DateTime parseDtFrom = DateTime.parse(dateTo).toLocal();
      DateTime parseDtTo =
          DateTime.parse(dateTo).toLocal().add(Duration(days: 2));
      return parseDtTo.difference(parseDtFrom).inDays > 1
          ? parseDtTo.difference(parseDtFrom).inDays
          : parseDtTo.day - parseDtFrom.day;
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
    globalKey.currentContext
        ?.read<KeepAdverboxBloc>()
        .add(KeepAdverbox(limit: Constants.LIMIT_DATA));
  }

  void _onLoading() async {
    await Future.delayed(const Duration(seconds: 0));
    refreshController.loadComplete();
    List<dynamic>? dataKeep = globalKey.currentContext
        ?.read<KeepAdverboxBloc>()
        .state
        .dataKeepAdverbox;
    if (dataKeep != null) {
      globalKey.currentContext?.read<KeepAdverboxBloc>().add(
          LoadMoreKeepAdverbox(
              limit: Constants.LIMIT_DATA, offset: dataKeep.length));
    }
  }
}

class DetailKeepScreen extends StatefulWidget {
  const DetailKeepScreen(
      {Key? key, this.url, this.idx, this.id, this.typePoint, this.urlImage})
      : super(key: key);

  final String? url;
  final String? urlImage;
  final dynamic id;
  final dynamic typePoint;
  final dynamic idx;

  @override
  State<DetailKeepScreen> createState() => _DetailKeepScreenState();
}

class _DetailKeepScreenState extends State<DetailKeepScreen> {
  final GlobalKey<State<StatefulWidget>> globalKey =
      GlobalKey<State<StatefulWidget>>();
  FToast fToast = FToast();

  final _controller = ScrollController();

  @override
  void initState() {
    fToast.init(context);
    // TODO: implement initStat
    super.initState();

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
            listenWhen: (previous, current) =>
                previous.deleteKeepStatus != current.deleteKeepStatus,
            listener: _listenFetchData,
          ),
          BlocListener<KeepAdverboxBloc, KeepAdverboxState>(
            listenWhen: (previous, current) =>
                previous.adverKeepStatus != current.adverKeepStatus,
            listener: _listenPointFetchData,
          ),
          BlocListener<KeepAdverboxBloc, KeepAdverboxState>(
            listenWhen: (previous, current) =>
                previous.saveKeepStatus != current.saveKeepStatus,
            listener: _listenSaveKeep,
          ),
          BlocListener<KeepAdverboxBloc, KeepAdverboxState>(
            listenWhen: (previous, current) =>
                previous.saveScrapStatus != current.saveScrapStatus,
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
    if (state.saveScrapStatus == SaveScrapStatus.success) {}
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
      AppAlert.showSuccess(context, fToast, "Success");
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
  bool checkSave = true;

  onVerticalDrapEnd(DragEndDetails details) {}

  _buildContent(BuildContext context) {
    return Scaffold(
        key: globalKey,
        body: BlocBuilder<KeepAdverboxBloc, KeepAdverboxState>(
          builder: (context, state) {
            return CustomWebViewKeep(
              urlLink: widget.url,
              uriImage: widget.urlImage,
              bookmark: GestureDetector(
                onTap: () {
                  setState(() {
                    checkSave = !checkSave;
                  });
                  if (!checkSave) {
                    globalKey.currentContext
                        ?.read<KeepAdverboxBloc>()
                        .add(SaveScrap(advertise_idx: widget.id));
                  } else {
                    globalKey.currentContext
                        ?.read<KeepAdverboxBloc>()
                        .add(DeleteScrap(advertise_idx: widget.id));
                  }
                },
                child: Image.asset(
                    checkSave ? Assets.deleteKeep.path : Assets.saveKeep.path,
                    package: "sdk_eums",
                    height: 27,
                    color: AppColor.black),
              ),
              mission: () {
                DialogUtils.showDialogSucessPoint(context,
                    checkImage: true,
                    point: widget.typePoint,
                    data: (state.dataAdvertiseSponsor), voidCallback: () {
                  context
                      .read<KeepAdverboxBloc>()
                      .add(DeleteKeep(id: widget.id));
                  globalKey.currentContext?.read<KeepAdverboxBloc>().add(
                      EarnPoin(
                          advertise_idx: widget.id,
                          pointType: widget.typePoint));
                });
              },
            );
          },
        ));
  }
}
