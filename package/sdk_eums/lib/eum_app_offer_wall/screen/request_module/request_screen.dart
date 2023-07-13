import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sdk_eums/eum_app_offer_wall/widget/app_alert.dart';
import 'package:sdk_eums/gen/assets.gen.dart';

import '../../../common/constants.dart';
import '../../utils/appColor.dart';
import '../../utils/appStyle.dart';
import '../../utils/app_string.dart';
import 'bloc/request_bloc.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({Key? key}) : super(key: key);

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int tabIndex = 0;
  int tabPreviousIndex = 0;

  @override
  void initState() {
    _tabController = TabController(initialIndex: 0, length: 2, vsync: this);
    _tabController.addListener(() {
      tabIndex = _tabController.index;
      if (tabIndex != tabPreviousIndex) {}
      tabPreviousIndex = _tabController.index;
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RequestBloc>(
      create: (context) => RequestBloc()
        // ..add(TypeInquire())
        ..add(ListInquire(limit: Constants.LIMIT_DATA)),
      child: MultiBlocListener(listeners: [
        BlocListener<RequestBloc, RequestState>(
          listenWhen: (previous, current) =>
              previous.inquireStatus != current.inquireStatus,
          listener: _listenFetchData,
        ),
        BlocListener<RequestBloc, RequestState>(
          listenWhen: (previous, current) =>
              previous.typeInquireStatus != current.typeInquireStatus,
          listener: _listenFetchDataType,
        ),
        BlocListener<RequestBloc, RequestState>(
          listenWhen: (previous, current) =>
              previous.inquireListStatus != current.inquireListStatus,
          listener: _listenFetchDataListType,
        ),
      ], child: _buildContent(context)),
    );
  }

  void _listenFetchDataListType(BuildContext context, RequestState state) {
    if (state.inquireListStatus == InquireListStatus.loading) {
      // EasyLoading.show();
      return;
    }
    if (state.inquireListStatus == InquireListStatus.failure) {
      // EasyLoading.dismiss();
      return;
    }
    if (state.inquireListStatus == InquireListStatus.success) {
      // EasyLoading.dismiss();
    }
  }

  void _listenFetchDataType(BuildContext context, RequestState state) {
    if (state.typeInquireStatus == TypeInquireStatus.loading) {
      // EasyLoading.show();
      return;
    }
    if (state.typeInquireStatus == TypeInquireStatus.failure) {
      // EasyLoading.dismiss();
      return;
    }
    if (state.typeInquireStatus == TypeInquireStatus.success) {
      // EasyLoading.dismiss();
    }
  }

  void _listenFetchData(BuildContext context, RequestState state) {
    if (state.inquireStatus == InquireStatus.loading) {
      // EasyLoading.show();
      return;
    }
    if (state.inquireStatus == InquireStatus.failure) {
      // EasyLoading.dismiss();
      return;
    }
    if (state.inquireStatus == InquireStatus.success) {
      context.read<RequestBloc>().add(ListInquire(limit: Constants.LIMIT_DATA));
      setState(() {
        _tabController.animateTo(_tabController.index + 1,
            duration: Duration(milliseconds: 300));
      });
      // EasyLoading.dismiss();
    }
  }

  Scaffold _buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        backgroundColor: AppColor.white,
        elevation: 1,
        centerTitle: true,
        title: Text(AppString.inquiry,
            style: AppStyle.bold.copyWith(fontSize: 16, color: AppColor.black)),
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(Icons.arrow_back_ios_outlined,
              color: AppColor.dark, size: 25),
        ),
      ),
      body: Column(
        children: [
          TabBar(
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(width: 3.0, color: AppColor.red),
              ),
              controller: _tabController,
              labelPadding:
                  const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              isScrollable: true,
              labelColor: AppColor.red,
              indicatorColor: AppColor.red,
              unselectedLabelColor: AppColor.color70,
              labelStyle: AppStyle.bold.copyWith(color: AppColor.red),
              unselectedLabelStyle:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              tabs: [
                _buildTitleTabBar(AppString.inquiry1),
                _buildTitleTabBar(AppString.detailInquiry)
              ]),
          DefaultTabController(length: 2, child: _buildTabBar())
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: [MakeQuestion(), HistoryRequest()],
      ),
    );
  }

  Container _buildTitleTabBar(String text) {
    // ignore: avoid_unnecessary_containers
    return Container(
      width: MediaQuery.of(context).size.width / 2,
      child: Tab(
          child: Center(
              child: Text(text,
                  style: AppStyle.bold14.copyWith(
                    fontSize: 14,
                  )))),
    );
  }
}

class MakeQuestion extends StatefulWidget {
  const MakeQuestion({Key? key}) : super(key: key);

  @override
  State<MakeQuestion> createState() => _MakeQuestionState();
}

class _MakeQuestionState extends State<MakeQuestion> {
  dynamic selectedArea;
  String nameBank = '문의 유형 선택';
  bool check = false;
  TextEditingController contentCtrl = TextEditingController();
  FToast fToast = FToast();

  @override
  void initState() {
    fToast.init(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RequestBloc, RequestState>(
      builder: (context, state) {
        return SingleChildScrollView(
          child: Container(
            color: AppColor.colorC9.withOpacity(0.2),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: AppColor.white,
                    border: Border.all(color: AppColor.colorCC, width: 1),
                  ),
                  child: DropdownButtonFormField<dynamic>(
                    dropdownColor: AppColor.white,
                    menuMaxHeight: MediaQuery.of(context).size.width,
                    decoration: InputDecoration(
                      fillColor: AppColor.white,
                      hintText: nameBank,
                      border: InputBorder.none,
                    ),
                    hint: Text(
                      nameBank,
                    ),
                    style: AppStyle.bold.copyWith(color: AppColor.grey5D),
                    value: selectedArea,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_outlined,
                      color: AppColor.black,
                    ),
                    items: List<int>.generate(
                            QUESTION_LIST.length, (index) => index)
                        .map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem(
                        // alignment: Alignment.center,
                        value: value,
                        child: Container(
                          color: AppColor.white,
                          width: MediaQuery.of(context).size.width - 120,
                          child: Text(
                            "${QUESTION_LIST[value]['name']}",
                            overflow: TextOverflow.visible,
                            textAlign: TextAlign.start,
                            // style: AppTextStyles.medium16,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (dynamic index) {
                      setState(() {
                        selectedArea = index;
                      });
                    },
                  ),
                ),
                Row(
                  children: [
                    Image.asset(Assets.errOrange.path,
                        package: "sdk_eums", height: 20),
                    Text('  문의 하기 안내  ',
                        style: AppStyle.bold
                            .copyWith(color: AppColor.orange4, fontSize: 16)),
                    const Icon(
                      Icons.keyboard_arrow_down_outlined,
                      size: 20,
                      color: AppColor.orange4,
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                      color: AppColor.white,
                      borderRadius: BorderRadius.circular(6),
                      border:
                          Border.all(color: AppColor.color70.withOpacity(0.7))),
                  child: TextFormField(
                    controller: contentCtrl,
                    maxLength: 200,
                    maxLines: 9,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        hintText: '문의 내용을 입력해 주세요.',
                        border: InputBorder.none,
                        hintStyle: AppStyle.bold.copyWith(
                            color: AppColor.color70.withOpacity(0.7))),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      check = !check;
                    });
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: check
                                    ? AppColor.orange4
                                    : Colors.transparent,
                                border: Border.all(
                                    color: !check
                                        ? AppColor.orange4
                                        : Colors.transparent)),
                            child: Icon(
                              Icons.check,
                              size: 17,
                              color:
                                  check ? AppColor.white : Colors.transparent,
                            )),
                        const SizedBox(width: 8),
                        RichText(
                            text: TextSpan(
                                text: '원활한 답변을 위한',
                                style: AppStyle.bold.copyWith(
                                    fontSize: 14, color: AppColor.black),
                                children: [
                              TextSpan(
                                text: '기기 정보 수집 약관',
                                style: AppStyle.bold.copyWith(
                                    fontSize: 14, color: AppColor.red),
                              ),
                              TextSpan(
                                text: '에 동의합니다',
                                style: AppStyle.bold.copyWith(
                                    fontSize: 14, color: AppColor.black),
                              )
                            ]))
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Text(
                    '수집항목 \n - 안드로이드 버전 정보 (OS Version, API Version) \n- 기기 제조가 정보 \n- 기기 모델명 (기기 고유 모델명) \n- 현재 설치된 앱 버전 \n',
                    style: AppStyle.regular.copyWith(color: AppColor.grey5D),
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    if (contentCtrl.text == "" || selectedArea == null) {
                      AppAlert.showError(context, fToast, "empty field");
                    } else {
                      if (check) {
                        getInquire();
                      }
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                        color: !check
                            ? AppColor.yellow.withOpacity(0.5)
                            : AppColor.yellow,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      '문의하기 ',
                      style: AppStyle.bold
                          .copyWith(color: AppColor.black, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  String deviceManufacturer = '';
  String deviceModelName = '';
  String deviceOsVersion = '';
  String deviceSdkVersion = '';
  String deviceAppVersion = '';

  getInquire() async {
    FocusScope.of(context).unfocus();
    deviceSdkVersion = '0.0.3';

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    deviceAppVersion = packageInfo.version;
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
      deviceOsVersion = androidInfo.version.release;
      deviceModelName = androidInfo.model;
      deviceManufacturer = androidInfo.manufacturer;
    } else {
      IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
      deviceOsVersion = iosInfo.systemVersion ?? '';
      deviceModelName = iosInfo.model ?? '';
    }

    context.read<RequestBloc>().add(RequestInquire(
        type: QUESTION_LIST[selectedArea]['media'],
        contents: contentCtrl.text,
        deviceAppVersion: deviceAppVersion,
        deviceManufacturer: deviceManufacturer,
        deviceModelName: deviceModelName,
        deviceOsVersion: deviceOsVersion,
        deviceSdkVersion: deviceSdkVersion));
  }
}

class HistoryRequest extends StatefulWidget {
  const HistoryRequest({Key? key}) : super(key: key);

  @override
  State<HistoryRequest> createState() => _HistoryRequestState();
}

class _HistoryRequestState extends State<HistoryRequest> {
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RequestBloc, RequestState>(
      builder: (context, state) {
        return state.dataListInquire != null
            ? SmartRefresher(
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
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: AppColor.colorC9)),
                      child: Wrap(
                        children: List.generate(
                            state.dataListInquire.length,
                            (index) => _buildItem(
                                index: index,
                                data: state.dataListInquire[index],
                                dataRequest: state.dataListInquire)),
                      ),
                    ),
                  ),
                ),
              )
            : SizedBox();
      },
    );
  }

  void _onRefresh() async {
    await Future.delayed(const Duration(seconds: 0));
    refreshController.refreshCompleted();
    setState(() {});
    _fetchData();
  }

  _fetchData() async {
    context.read<RequestBloc>().add(ListInquire(limit: Constants.LIMIT_DATA));
  }

  void _onLoading() async {
    await Future.delayed(const Duration(seconds: 0));
    refreshController.loadComplete();
    _fetchDataLoadMore();
  }

  _fetchDataLoadMore({int? offset}) async {
    await Future.delayed(const Duration(seconds: 0));
    refreshController.loadComplete();
    List<dynamic>? dataRequest =
        context.read<RequestBloc>().state.dataListInquire;
    if (dataRequest != null) {
      context.read<RequestBloc>().add(LoadMoreListInquire(
            offset: dataRequest.length,
            limit: Constants.LIMIT_DATA,
          ));
    }
  }

  final Set<dynamic> _saved = Set<dynamic>();

  _buildItem({int? index, dynamic data, List? dataRequest}) {
    bool isShowDes = _saved.contains(data);
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            // if (data['ripple_fl'] == "0") {
            if (isShowDes) {
              setState(() {
                _saved.remove(data);
              });
            } else {
              setState(() {
                _saved.add(data);
              });
            }
            // }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isShowDes ? AppColor.blue2 : AppColor.white,
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${data['contents']}",
                      style: AppStyle.bold
                          .copyWith(color: AppColor.black, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Constants.formatTime(data['regist_date']),
                      style: AppStyle.medium
                          .copyWith(color: AppColor.black, fontSize: 12),
                    )
                  ],
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: data['ripple_fl'] == 0
                            ? AppColor.color70
                            : AppColor.red,
                      )),
                  child: Text(
                    data['ripple_fl'] != 0 ? '답변완료' : '대기중',
                    style: AppStyle.bold.copyWith(
                        color: data['ripple_fl'] == 0
                            ? AppColor.color70
                            : AppColor.red,
                        fontSize: 10),
                  ),
                )
              ],
            ),
          ),
        ),
        if (isShowDes)
          if (data['answers'] != []) ...{
            Wrap(
              children: List.generate(
                  data['answers'].length,
                  (index) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Image.asset(Assets.enter.path,
                                    package: "sdk_eums", height: 24),
                                Text(
                                  "${data['answers'][index]['contents']}",
                                  style: AppStyle.bold.copyWith(
                                      color: AppColor.black, fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "${data['answers'][index]['contents']}",
                              style: AppStyle.bold.copyWith(
                                  color: AppColor.color70, fontSize: 14),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      )),
            ),
          },
        index != dataRequest!.length - 1 ? Divider() : SizedBox()
      ],
    );
  }
}
