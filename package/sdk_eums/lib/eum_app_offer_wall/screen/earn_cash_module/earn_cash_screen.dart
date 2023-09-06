import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sdk_eums/common/constants.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/earn_cash_module/bloc/earn_cash_bloc.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appStyle.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/app_string.dart';
import 'package:sdk_eums/gen/assets.gen.dart';

class EarnCashScreen extends StatefulWidget {
  final dynamic account;
  const EarnCashScreen({Key? key, this.account}) : super(key: key);

  @override
  State<EarnCashScreen> createState() => _EarnCashScreenState();
}

class _EarnCashScreenState extends State<EarnCashScreen> {
  final GlobalKey<State<StatefulWidget>> globalKey =
      GlobalKey<State<StatefulWidget>>();
  bool showListPoint = false;
  bool showBeeList = false;
  bool showPointOfferWall = false;
  bool showOfferWallList = false;
  dynamic account;
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    // TODO: implement initState
    account = widget.account;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EarnCashBloc>(
      create: (context) => EarnCashBloc()
        ..add(EarnCashList(limit: 1000000))
        ..add(PointOfferWallList()),
      child: MultiBlocListener(listeners: [
        BlocListener<EarnCashBloc, EarnCashState>(
          listenWhen: (previous, current) =>
              previous.earnCashStatus != current.earnCashStatus,
          listener: _listenFetchData,
        ),
        BlocListener<EarnCashBloc, EarnCashState>(
          listenWhen: (previous, current) =>
              previous.loadMoreEarnCashStatus != current.loadMoreEarnCashStatus,
          listener: _listenLoadMoreData,
        ),
      ], child: _buildContent(context)),
    );
  }

  void _listenLoadMoreData(BuildContext context, EarnCashState state) {
    if (state.loadMoreEarnCashStatus == LoadMoreEarnCashStatus.loading) {
      // EasyLoading.show();
      return;
    }
    if (state.loadMoreEarnCashStatus == LoadMoreEarnCashStatus.failure) {
      // EasyLoading.dismiss();
      return;
    }
    if (state.loadMoreEarnCashStatus == LoadMoreEarnCashStatus.success) {
      // EasyLoading.dismiss();
    }
  }

  void _listenFetchData(BuildContext context, EarnCashState state) {
    if (state.earnCashStatus == EarnCashStatus.loading) {
      // EasyLoading.show();
      return;
    }
    if (state.earnCashStatus == EarnCashStatus.failure) {
      // EasyLoading.dismiss();
      return;
    }
    if (state.earnCashStatus == EarnCashStatus.success) {
      // EasyLoading.dismiss();
    }
  }

  void _onRefresh() async {
    await Future.delayed(const Duration(seconds: 0));
    refreshController.refreshCompleted();
    setState(() {});
    _fetchData();
  }

  _fetchData() async {
    globalKey.currentContext
        ?.read<EarnCashBloc>()
        .add(EarnCashList(limit: 1000000));
  }

  void _onLoading() async {
    await Future.delayed(const Duration(seconds: 0));
    refreshController.loadComplete();
    _fetchDataLoadMore();
  }

  _fetchDataLoadMore({int? offset}) async {
    // await Future.delayed(const Duration(seconds: 0));
    // refreshController.loadComplete();
    // List<dynamic>? dataEarnCash =
    //     globalKey.currentContext?.read<EarnCashBloc>().state.dataEarnCash;
    // if (dataEarnCash != null) {
    //   globalKey.currentContext?.read<EarnCashBloc>().add(LoadMoreEarnCashList(
    //         offset: dataEarnCash.length,
    //         limit: Constants.LIMIT_DATA,
    //       ));
    // }
    //  List<dynamic>? dataOfferWall =
    //     globalKey.currentContext?.read<EarnCashBloc>().state.dataPointOffer;
    // if (dataOfferWall != null) {
    //   globalKey.currentContext?.read<EarnCashBloc>().add(LoadMorePointOfferWallList(
    //         offset: dataOfferWall.length,
    //         limit: Constants.LIMIT_DATA,
    //       ));
    // }
  }

  Scaffold _buildContent(BuildContext context) {
    return Scaffold(
        key: globalKey,
        backgroundColor: AppColor.white,
        appBar: AppBar(
          backgroundColor: AppColor.white,
          elevation: 1,
          centerTitle: true,
          title: Text('포인트 현황',
              style:
                  AppStyle.bold.copyWith(fontSize: 16, color: AppColor.black)),
          leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Icon(Icons.arrow_back_ios_outlined,
                color: AppColor.dark, size: 25),
          ),
        ),
        body: BlocBuilder<EarnCashBloc, EarnCashState>(
          builder: (context, state) {
            return SmartRefresher(
              controller: refreshController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              header: CustomHeader(
                builder: (BuildContext context, RefreshStatus? mode) {
                  return const Center(
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.transparent)));
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
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.black)),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Text(
                            AppString.cumulativeEarnedCash,
                            style: AppStyle.bold.copyWith(fontSize: 24),
                          ),
                          const Spacer(),
                          Image.asset(Assets.point.path,
                              package: "sdk_eums", height: 24),
                          const SizedBox(width: 5),
                          account != null
                              ? Text(
                                  Constants.formatMoney(
                                      account['memPoint'] ?? 0,
                                      suffix: ''),
                                  style: AppStyle.bold.copyWith(
                                      fontSize: 24, color: AppColor.orange1),
                                )
                              : SizedBox()
                        ],
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: AppColor.colorF6,
                            borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppString.checkCashWeek,
                                style: AppStyle.medium.copyWith(
                                    color: AppColor.grey, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(AppString.exchangeCash,
                                style: AppStyle.medium.copyWith(
                                    color: AppColor.grey, fontSize: 12))
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Image.asset(
                        Assets.banerAdverbox.path,
                        package: "sdk_eums",
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppString.earningHistory,
                        style: AppStyle.bold.copyWith(color: AppColor.red),
                      ),
                      const Divider(color: AppColor.red, thickness: 2),
                      _buildList(
                          dataEums: state.dataEarnCash,
                          dataOfferWall: state.dataPointOffer)
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }

  // bool checkShowList = false;
  bool checkBee = false;
  bool checkOfferWall = false;

  _buildList({dynamic dataOfferWall, dynamic dataEums}) {
    dynamic totalPointEum = 0;
    int totalPointOfferWall = 0;
    if (dataEums != null && dataEums.length > 0) {
      for (int i = 0; i < dataEums.length; i++) {
        totalPointEum = totalPointEum + dataEums[i]['user_point'];
      }
    }

    if (dataOfferWall != null && dataOfferWall.length > 0) {
      for (int i = 0; i < dataOfferWall.length; i++) {
        totalPointOfferWall = totalPointOfferWall +
            int.parse(dataOfferWall[i]['point'].toString());
      }
    }
    return GestureDetector(
      onTap: () {
        // setState(() {
        //   checkShowList = !checkShowList;
        // });
      },
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                checkBee = !checkBee;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4)),
                  color: !checkBee ? AppColor.white : AppColor.colorF1),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "찾아가는 광고",
                    style: AppStyle.bold
                        .copyWith(color: AppColor.red5, fontSize: 16),
                  ),
                  const Spacer(),
                  Text(
                    dataOfferWall != null
                        ? Constants.formatMoney(totalPointEum, suffix: '')
                        : '',
                    style: AppStyle.bold
                        .copyWith(fontSize: 20, color: AppColor.black),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Icon(
                      checkBee
                          ? Icons.keyboard_arrow_down_outlined
                          : Icons.keyboard_arrow_up_outlined,
                      size: 24,
                      color: AppColor.grey,
                    ),
                  )
                ],
              ),
            ),
          ),
          if (checkBee) ...[
            dataEums == null
                ? SizedBox()
                : Container(
                    decoration: const BoxDecoration(
                        color: AppColor.colorF1,
                        border: Border(top: BorderSide(color: AppColor.white))),
                    child: Wrap(
                      children: List.generate(
                          dataEums.length,
                          (index) => Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 20),
                                decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(4),
                                        bottomRight: Radius.circular(4)),
                                    color: AppColor.colorF1),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.6,
                                      child: Text(
                                          "${dataEums[index]['advertise'] != null ? dataEums[index]['advertise']['name'] : ""}",
                                          style: AppStyle.medium.copyWith(
                                              fontSize: 14,
                                              color: AppColor.grey)),
                                    ),
                                    const Spacer(),
                                    Text(
                                        dataEums != null
                                            ? Constants.formatMoney(
                                                dataEums[index]['user_point'],
                                                suffix: '')
                                            : '',
                                        style: AppStyle.medium.copyWith(
                                            fontSize: 14,
                                            color: AppColor.grey)),
                                  ],
                                ),
                              )),
                    ),
                  ),
          ],
          GestureDetector(
            onTap: () {
              setState(() {
                setState(() {
                  checkOfferWall = !checkOfferWall;
                });
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4)),
                  color: AppColor.white),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "오퍼월광고",
                    style: AppStyle.bold
                        .copyWith(color: AppColor.red5, fontSize: 16),
                  ),
                  const Spacer(),
                  Text(
                    dataEums != null
                        ? Constants.formatMoney(totalPointOfferWall, suffix: '')
                        : '',
                    style: AppStyle.bold
                        .copyWith(fontSize: 20, color: AppColor.black),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Icon(
                      checkOfferWall
                          ? Icons.keyboard_arrow_down_outlined
                          : Icons.keyboard_arrow_up_outlined,
                      size: 24,
                      color: AppColor.grey,
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: !checkOfferWall ? 16 : 0,
          ),
          if (checkOfferWall) ...[
            dataOfferWall == null
                ? SizedBox()
                : Container(
                    decoration: const BoxDecoration(
                        color: AppColor.colorF1,
                        border: Border(top: BorderSide(color: AppColor.white))),
                    child: Wrap(
                      children: List.generate(
                          dataOfferWall.length,
                          (index) => Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 20),
                                decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(4),
                                        bottomRight: Radius.circular(4)),
                                    color: AppColor.colorF1),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.6,
                                      child: Text(
                                          "${dataOfferWall[index]['reason'] ?? ''}",
                                          style: AppStyle.medium.copyWith(
                                              fontSize: 14,
                                              color: AppColor.grey)),
                                    ),
                                    const Spacer(),
                                    Text(
                                        dataOfferWall != null
                                            ? Constants.formatMoney(
                                                int.parse(dataOfferWall[index]
                                                        ['point']
                                                    .toString()),
                                                suffix: '')
                                            : '',
                                        style: AppStyle.medium.copyWith(
                                            fontSize: 14,
                                            color: AppColor.grey)),
                                  ],
                                ),
                              )),
                    ),
                  ),
          ],
          // },
        ],
      ),
    );
  }
}
