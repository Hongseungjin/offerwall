import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sdk_eums/common/events/rx_events.dart';
import 'package:sdk_eums/common/routing.dart';
import 'package:sdk_eums/common/rx_bus.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appStyle.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/loading_dialog.dart';
import 'package:sdk_eums/eum_app_offer_wall/widget/app_alert.dart';
import 'package:sdk_eums/eum_app_offer_wall/widget/custom_webview.dart';
import 'package:sdk_eums/gen/assets.gen.dart';

import '../../../common/constants.dart';
import 'bloc/scrap_adverbox_bloc.dart';

class ScrapAdverBoxScreen extends StatefulWidget {
  const ScrapAdverBoxScreen({Key? key}) : super(key: key);

  @override
  State<ScrapAdverBoxScreen> createState() => _ScrapAdverBoxScreenState();
}

class _ScrapAdverBoxScreenState extends State<ScrapAdverBoxScreen> {
  final GlobalKey<State<StatefulWidget>> globalKey =
      GlobalKey<State<StatefulWidget>>();
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  String allMedia = '날짜 오름차순';
  String? dataSort;
  @override
  void initState() {
    _registerEventBus();
    super.initState();
  }

  Future<void> _registerEventBus() async {
    RxBus.register<RefreshDataScrap>().listen((event) {
      _onRefresh();
    });
    RxBus.register<RefreshLikeScrap>().listen((event) {
      _onRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ScrapAdverboxBloc>(
      create: (context) =>
          ScrapAdverboxBloc()..add(ScrapAdverbox(limit: Constants.LIMIT_DATA)),
      child: BlocListener<ScrapAdverboxBloc, ScrapAdverboxState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: _listenFetchData,
          child: Scaffold(
            key: globalKey,
            backgroundColor: AppColor.white,
            appBar: AppBar(
              backgroundColor: AppColor.white,
              elevation: 1,
              centerTitle: true,
              title: Text('광고 스크랩',
                  style: AppStyle.bold
                      .copyWith(fontSize: 16, color: AppColor.black)),
              leading: InkWell(
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
              child: BlocBuilder<ScrapAdverboxBloc, ScrapAdverboxState>(
                builder: (context, state) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          Image.asset(
                            Assets.scrap_banner.path,
                            package: "sdk_eums",
                          ),
                          const SizedBox(height: 16),
                          // Container(
                          //   padding: const EdgeInsets.symmetric(horizontal: 16),
                          //   decoration: BoxDecoration(
                          //     border: Border.all(
                          //         color: AppColor.grey5D.withOpacity(0.4)),
                          //     borderRadius: BorderRadius.circular(8),
                          //   ),
                          //   child: _buildDropDown(context),
                          // ),
                          // const SizedBox(height: 16),
                          state.dataScrapAdverbox != null
                              ? Wrap(
                                  children: List.generate(
                                      state.dataScrapAdverbox.length,
                                      (index) => InkWell(
                                            onTap: () {
                                              if (state.dataScrapAdverbox[index]
                                                      ['url_link'] !=
                                                  null) {
                                                Routing().navigate(
                                                    context,
                                                    DetailScrapScreen(
                                                      url: state
                                                              .dataScrapAdverbox[
                                                          index]['url_link'],
                                                      adIdx: state
                                                              .dataScrapAdverbox[
                                                          index]['advertiseIdx'],
                                                    ));
                                              }
                                            },
                                            child: Column(
                                              children: [
                                                const SizedBox(height: 12),
                                                Row(
                                                  children: [
                                                    Image.asset(
                                                        Assets.keep_adver.path,
                                                        package: "sdk_eums",
                                                        height: 40),
                                                    const SizedBox(width: 10),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          state.dataScrapAdverbox[
                                                                      index]
                                                                  ['name'] ??
                                                              '',
                                                          style: AppStyle.bold
                                                              .copyWith(
                                                                  color: AppColor
                                                                      .black,
                                                                  fontSize: 14),
                                                        ),
                                                        const SizedBox(
                                                            height: 2),
                                                        Text(
                                                          '스크랩 날짜 ${state.dataScrapAdverbox[index]['regist_date'] != null ? Constants.formatTimeDay(state.dataScrapAdverbox[index]['regist_date']) : ''} ',
                                                          style: AppStyle.medium
                                                              .copyWith(
                                                                  color: AppColor
                                                                      .grey5D,
                                                                  fontSize: 10),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                const Divider(),
                                              ],
                                            ),
                                          )),
                                )
                              : const SizedBox(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          )),
    );
  }

  Widget _buildDropDown(BuildContext context) {
    dynamic medias = SCRAP_MEDIA.map((item) => item['name']).toList();
    List<DropdownMenuItem<String>> items =
        medias.map<DropdownMenuItem<String>>((String? value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(
          value ?? "",
          textAlign: TextAlign.center,
          style: AppStyle.bold.copyWith(color: AppColor.black),
          maxLines: 1,
        ),
      );
    }).toList();

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        key: GlobalKey<FormFieldState>(),
        isExpanded: true,
        dropdownColor: AppColor.white,
        value: allMedia,
        style: AppStyle.bold.copyWith(color: AppColor.black, fontSize: 14),
        hint: Text(
          allMedia,
          style: AppStyle.bold.copyWith(color: AppColor.black, fontSize: 14),
        ),
        icon: const Icon(
          Icons.arrow_drop_down,
          color: AppColor.black,
        ),
        items: items,
        onChanged: (value) {
          setState(() {
            allMedia = value!;
          });
          _filterMedia(value);
        },
      ),
    );
  }

  void _listenFetchData(BuildContext context, ScrapAdverboxState state) {
    if (state.status == ScrapAdverboxStatus.loading) {
      LoadingDialog.instance.show();
      return;
    }
    if (state.status == ScrapAdverboxStatus.failure) {
      LoadingDialog.instance.hide();
      return;
    }
    if (state.status == ScrapAdverboxStatus.success) {
      LoadingDialog.instance.hide();
    }
  }

  void _onRefresh() async {
    await Future.delayed(const Duration(seconds: 0));
    refreshController.refreshCompleted();
    setState(() {});
    _fetchData();
  }

  _filterMedia(value) {
    if (value != '날짜 오름차순') {
      dynamic media = (SCRAP_MEDIA
          .where((element) => element['name'] == value)
          .toList())[0]['media'];

      dataSort = value;
    } else {
      dataSort = SCRAP_MEDIA[0]['media'];
    }

    _fetchData();
  }

  _fetchData() async {
    globalKey.currentContext
        ?.read<ScrapAdverboxBloc>()
        .add(ScrapAdverbox(limit: Constants.LIMIT_DATA, sort: dataSort));
  }

  void _onLoading() async {
    await Future.delayed(const Duration(seconds: 0));
    refreshController.loadComplete();
    List<dynamic>? dataKeep = globalKey.currentContext
        ?.read<ScrapAdverboxBloc>()
        .state
        .dataScrapAdverbox;
    if (dataKeep != null) {
      globalKey.currentContext?.read<ScrapAdverboxBloc>().add(
          LoadMoreScrapAdverbox(
              limit: Constants.LIMIT_DATA, offset: dataKeep.length));
    }
  }
}

class DetailScrapScreen extends StatefulWidget {
  const DetailScrapScreen({Key? key, this.url, this.adIdx}) : super(key: key);

  final String? url;
  final dynamic adIdx;

  @override
  State<DetailScrapScreen> createState() => _DetailScrapScreenState();
}

class _DetailScrapScreenState extends State<DetailScrapScreen> {
  final GlobalKey<State<StatefulWidget>> globalKey =
      GlobalKey<State<StatefulWidget>>();
  FToast fToast = FToast();
  @override
  void initState() {
    fToast.init(context);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ScrapAdverboxBloc>(
        create: (context) => ScrapAdverboxBloc()
          ..add(ScrapAdverbox(limit: Constants.LIMIT_DATA)),
        child: BlocListener<ScrapAdverboxBloc, ScrapAdverboxState>(
          listenWhen: (previous, current) =>
              previous.deleteScrapAdverboxStatus !=
              current.deleteScrapAdverboxStatus,
          listener: _listenFetchData,
          child: Scaffold(
            key: globalKey,
            body: CustomWebView(
              onClose: () {},
              urlLink: widget.url,
              showImage: true,
              title: '광고 스크랩',
              color: AppColor.red,
              colorIconBack: AppColor.white,
              actions: InkWell(
                onTap: () {
                  globalKey.currentContext
                      ?.read<ScrapAdverboxBloc>()
                      .add(DeleteScrapdverbox(
                        id: widget.adIdx,
                      ));
                },
                child: Padding(
                  padding: const EdgeInsets.all(17.0),
                  child: Image.asset(Assets.bookmark.path,
                      package: "sdk_eums", height: 25),
                ),
              ),
            ),
          ),
        ));
  }

  String getProperHtml(String content) {
    String start1 = 'https:';
    int startIndex1 = content.indexOf(start1);
    String iframeTag1 = content.substring(startIndex1 + 6);
    content = iframeTag1.replaceAll("$iframeTag1", "http:${iframeTag1}");
    return content;
  }

  void _listenFetchData(BuildContext context, ScrapAdverboxState state) {
    if (state.deleteScrapAdverboxStatus == DeleteScrapAdverboxStatus.loading) {
      // EasyLoading.show();
      return;
    }
    if (state.deleteScrapAdverboxStatus == DeleteScrapAdverboxStatus.failure) {
      // EasyLoading.dismiss();
      return;
    }
    if (state.deleteScrapAdverboxStatus == DeleteScrapAdverboxStatus.success) {
      RxBus.post(RefreshDataScrap());
      // EasyLoading.dismiss();
      Navigator.pop(context);
      AppAlert.showSuccess(context, fToast, "Success");
    }
  }
}
