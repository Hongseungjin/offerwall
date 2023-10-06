import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:get/get_state_manager/get_state_manager.dart';
// import 'package:get/instance_manager.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:sdk_eums/common/constants.dart';
import 'package:sdk_eums/common/local_store/local_store.dart';
import 'package:sdk_eums/common/local_store/local_store_service.dart';
import 'package:sdk_eums/common/routing.dart';
// import 'package:sdk_eums/common/routing.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/detail_offwall_module/detail_offwall_screen.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/home_module/bloc/home_bloc.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/home_module/widget/custom_web_view_banner.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/instruct_app_module/instruct_app.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/my_page_module/my_page.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/scrap_adverbox_module/scrap_adverbox_screen.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/status_point_module/status_point_page.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/using_term_module/using_term_screen.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appStyle.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/hex_color.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/loading_dialog.dart';
import 'package:sdk_eums/eum_app_offer_wall/widget/custom_animation_click.dart';
import 'package:sdk_eums/eum_app_offer_wall/widget/custom_dialog.dart';
import 'package:sdk_eums/eum_app_offer_wall/widget/setting_fontsize.dart';
import 'package:sdk_eums/gen/assets.gen.dart';
import 'package:sdk_eums/sdk_eums_library.dart';

import '../keep_adverbox_module/keep_adverbox_module.dart';
import 'widget/custom_scroll_campaign_detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final GlobalKey<State<StatefulWidget>> globalKey =
      GlobalKey<State<StatefulWidget>>();
  bool isdisable = false;
  LocalStore? localStore;
  final _currentPageNotifier = ValueNotifier<int>(0);
  final ValueNotifier<GlobalKey<NestedScrollViewState>> globalKeyScroll =
      ValueNotifier(GlobalKey());
  late TabController _tabController;
  String? filter;
  String? categary;
  final ScrollController controller = ScrollController();
  int tabIndex = 0;
  int tabPreviousIndex = 0;
  dynamic accont;

  @override
  void initState() {
    localStore = LocalStoreService();

    categary = 'participation';
    _tabController = TabController(initialIndex: 0, length: 2, vsync: this);
    _tabController.addListener(_onTabChange);
    checkPermission();
    controller.addListener(() {});

    super.initState();
  }

  checkPermission() async {
    isdisable = await localStore!.getSaveAdver();
    if (!isdisable) {
      bool isRunning = await FlutterBackgroundService().isRunning();
      if (!isRunning) {
        FlutterBackgroundService().startService();
      }
    }
    if (Platform.isAndroid) {
      final bool status = await FlutterOverlayWindow.isPermissionGranted();

      if (!status) {
        await FlutterOverlayWindow.requestPermission();
      } else {}
      localStore?.setAccessToken(await localStore?.getAccessToken() ?? '');
    }
  }

  _onTabChange() {
    tabIndex = _tabController.index;
    if (tabIndex != tabPreviousIndex) {
      _fetchData();
    }
    tabPreviousIndex = _tabController.index;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (context) => HomeBloc()
        ..add(InfoUser())
        ..add(GetTotalPoint())
        ..add(ListBanner(type: 'main'))
        ..add(ListOfferWall(category: categary, filter: filter)),
      child: MultiBlocListener(
        listeners: [
          BlocListener<HomeBloc, HomeState>(
            listener: _listenListAdver,
          ),
          BlocListener<HomeBloc, HomeState>(
            listenWhen: (previous, current) =>
                previous.getPointStatus != current.getPointStatus,
            listener: _listenDataPoint,
          ),
        ],
        child: WillPopScope(
            onWillPop: () async {
              return true;
            },
            child: _buildContent(context)),
      ),
    );
  }

  void _listenDataPoint(BuildContext context, HomeState state) {
    if (state.getPointStatus == GetPointStatus.loading) {
      LoadingDialog.instance.show();
      return;
    }
    if (state.getPointStatus == GetPointStatus.failure) {
      LoadingDialog.instance.hide();
      return;
    }
    if (state.getPointStatus == GetPointStatus.success) {
      LoadingDialog.instance.hide();
      if (state.totalPoint != null) {
        DialogUtils.showDialogGetPoint(context, data: state.totalPoint);
      }
    }
  }

  void _listenListAdver(BuildContext context, HomeState state) {
    if (state.listAdverStatus == ListAdverStatus.loading) {
      LoadingDialog.instance.show();
      return;
    }
    if (state.listAdverStatus == ListAdverStatus.failure) {
      LoadingDialog.instance.hide();
      return;
    }
    if (state.listAdverStatus == ListAdverStatus.success) {
      LoadingDialog.instance.hide();
    }
  }

  final controllerGet = Get.put(SettingFontSize());

  _buildContent(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state.account != null) {
          accont = state.account;
        }

        return Obx(() => Scaffold(
              appBar: AppBar(
                backgroundColor: AppColor.white,
                leading: WidgetAnimationClick(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: AppColor.black,
                  ),
                ),
                centerTitle: true,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Image.asset(
                        Assets.logo_eums.path,
                        package: "sdk_eums",
                        height: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 14),
                      child: Text('리워드',
                          style: AppStyle.bold.copyWith(
                              color: AppColor.black,
                              fontSize: 4 + controllerGet.fontSizeObx.value)),
                    ),
                  ],
                ),
                actions: [
                  WidgetAnimationClick(
                    onTap: () {
                      Routings().navigate(context, MyPage());
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Image.asset(Assets.my_page.path,
                          package: "sdk_eums", height: 24),
                    ),
                  ),
                  const SizedBox(
                    width: 25,
                  )
                ],
              ),
              key: globalKey,
              body: CustomScrollCampaignDetail(
                buildChildren: (BuildContext context,
                    ValueNotifier<bool> showAppBar,
                    ScrollController scrollController) {
                  return [
                    CustomSliverList(
                      children: [
                        _buildUIShowPoint(
                            point: state.totalPoint != null
                                ? state.totalPoint['userPoint']
                                : 0),
                        Center(
                          child: Wrap(
                            direction: Axis.horizontal,
                            // spacing: 20,
                            children: List.generate(
                                uiIconList.length,
                                (index) => _buildUiIcon(
                                    onTap: () {
                                      switch (index) {
                                        case 0:
                                          Routings().navigate(
                                              context,
                                              StatusPointPage(
                                                  account: state.account));
                                          break;
                                        case 1:
                                          Routings().navigate(context,
                                              const KeepAdverboxScreen());
                                          break;
                                        case 2:
                                          Routings().navigate(context,
                                              const ScrapAdverBoxScreen());
                                          break;
                                        case 3:
                                          Routings().navigate(
                                              context, UsingTermScreen());
                                          break;
                                        default:
                                      }
                                    },
                                    urlImage: uiIconList[index]['icon'],
                                    title: uiIconList[index]['title'])),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildUIBannerImage(dataBanner: state.bannerList),
                      ],
                    ),
                    CustomSliverAppBar(
                      expandedHeight: 0,
                      toolbarHeight:
                          kToolbarHeight - MediaQuery.of(context).padding.top,
                      header: TabBar(
                        onTap: (value) {
                          int index = value;
                          if (_tabController.index == 0) {
                            categary = 'participation';
                          } else {
                            categary = 'mission';
                          }
                          _fetchData();
                          setState(() {
                            _tabController.index = index;
                          });
                        },
                        labelPadding:
                            const EdgeInsets.only(bottom: 10, top: 10),
                        controller: _tabController,
                        indicatorColor: HexColor('#f4a43b'),
                        unselectedLabelColor: HexColor('#707070'),
                        labelColor: HexColor('#f4a43b'),
                        labelStyle:
                            AppStyle.bold.copyWith(color: HexColor('#707070')),
                        tabs: [
                          Text(
                            '참여하고 리워드',
                            style: AppStyle.regular.copyWith(
                                fontSize: controllerGet.fontSizeObx.value),
                          ),
                          Text(
                            '쇼핑하고 리워드',
                            style: AppStyle.regular.copyWith(
                                fontSize: controllerGet.fontSizeObx.value),
                          ),
                        ],
                      ),
                    ),
                    CustomSliverList(
                      children: [
                        _buildUIPoint(
                            point: state.totalPoint != null
                                ? state.totalPoint['totalPointCanGet']
                                : 0),
                        ListViewHome(
                          tab: _tabController.index,
                          filter: _filterMedia,
                          scrollController: controller,
                        ),
                        // ListViewHome(
                        //   tab: _tabController.index,
                        //   filter: _filterMedia,
                        //   scrollController: controller,
                        // )
                      ],
                    )
                  ];
                },
                onRefresh: () {
                  _fetchData();
                },
                scrollController: controller,
              ),
            ));
      },
    );
  }

  _fetchData() async {
    if (_tabController.index == 0) {
      categary = 'participation';
    } else {
      categary = 'mission';
    }
    await Future.delayed(const Duration(seconds: 0));

    globalKey.currentContext?.read<HomeBloc>().add(ListOfferWall(
          limit: 10,
          filter: filter,
          category: categary,
        ));
  }

  _filterMedia(String? value) {
    if (value != '최신순') {
      dynamic media = (DATA_MEDIA
          .where((element) => element['name'] == value)
          .toList())[0]['media'];

      filter = media;
    } else {
      filter = DATA_MEDIA[2]['media'];
    }

    _fetchData();
  }

  _buildUIPoint({int? point}) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: HexColor('#888888').withOpacity(.2), width: 5),
              top: BorderSide(
                  color: HexColor('#888888').withOpacity(.2), width: 5))),
      child: Center(
        child: Wrap(
          spacing: 12,
          direction: Axis.horizontal,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '지금 획득 가능한 포인트',
              style: AppStyle.regular.copyWith(
                  color: HexColor('#888888'),
                  fontSize: controllerGet.fontSizeObx.value),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(Assets.icon_point_y.path,
                    package: "sdk_eums", height: 24),
                const SizedBox(width: 6),
                Text(
                  Constants.formatMoney(point, suffix: ''),
                  style: AppStyle.bold
                      .copyWith(fontSize: 6 + controllerGet.fontSizeObx.value),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  _buildUIShowPoint({
    int? point,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
          border: Border.all(color: HexColor('#e5e5e5')),
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              '현재 적립된 포인트',
              style: AppStyle.regular.copyWith(
                  fontSize: controllerGet.fontSizeObx.value,
                  color: Colors.black),
            ),
          ),
          WidgetAnimationClick(
            onTap: () {
              Routings().navigate(context, StatusPointPage(account: accont));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(Assets.icon_point_y.path,
                      package: "sdk_eums", height: 24),
                  const SizedBox(width: 12),
                  Text(Constants.formatMoney(point, suffix: ''),
                      style: AppStyle.bold
                          .copyWith(fontSize: 30, color: Colors.black)),
                  Text('P',
                      style: AppStyle.bold
                          .copyWith(fontSize: 18, color: Colors.black)),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black,
                    size: 18,
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          WidgetAnimationClick(
            onTap: () {
              Routings().navigate(context, InstructAppScreen());
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Image.asset(Assets.err_grey.path,
                      package: "sdk_eums", height: 12),
                  const SizedBox(width: 4),
                  Text(
                    '서비스 이용 안내',
                    style: AppStyle.regular12.copyWith(
                        color: HexColor('#888888'),
                        fontSize: controllerGet.fontSizeObx.value - 2),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: HexColor('#f4f4f4'),
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 1.5,
                  child: Text(
                    isdisable ? '벌 광고 비활성화 중입니다' : '벌 광고 활성화 중입니다',
                    maxLines: 2,
                    style: AppStyle.medium.copyWith(
                        color: Colors.black,
                        fontSize: controllerGet.fontSizeObx.value),
                  ),
                ),
                const Spacer(),
                WidgetAnimationClick(
                  onTap: () async {
                    setState(() {
                      isdisable = !isdisable;
                    });
                    localStore?.setSaveAdver(isdisable);
                    if (isdisable) {
                      String? token =
                          await FirebaseMessaging.instance.getToken();

                      await EumsOfferWallServiceApi()
                          .unRegisterTokenNotifi(token: token);
                      FlutterBackgroundService().invoke("stopService");
                    } else {
                      dynamic data = <String, dynamic>{
                        'count': 0,
                        'date': Constants.formatTime(
                            DateTime.now().toIso8601String()),
                      };
                      localStore?.setCountAdvertisement(data);
                      String? token =
                          await FirebaseMessaging.instance.getToken();
                      await EumsOfferWallServiceApi()
                          .createTokenNotifi(token: token);
                      bool isRunning =
                          await FlutterBackgroundService().isRunning();
                      if (!isRunning) {
                        FlutterBackgroundService().startService();
                      }
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                    width: 34,
                    decoration: BoxDecoration(
                        color: !isdisable ? AppColor.orange2 : AppColor.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: !isdisable
                                ? Colors.transparent
                                : AppColor.color70)),
                    child: Row(
                      children: [
                        isdisable
                            ? Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColor.color70,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Image.asset(
                                  Assets.check.path,
                                  package: "sdk_eums",
                                  height: 7,
                                  color: Colors.transparent,
                                ),
                              )
                            : const SizedBox(),
                        const Spacer(),
                        isdisable
                            ? const SizedBox()
                            : Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColor.white,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Image.asset(
                                  Assets.check.path,
                                  package: "sdk_eums",
                                  height: 7,
                                  color: Colors.transparent,
                                ),
                              ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  _buildUiIcon({String? title, String? urlImage, Function()? onTap}) {
    return WidgetAnimationClick(
      onTap: onTap,
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 4,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 9),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: HexColor('#888888').withOpacity(0.3)),
              child:
                  Image.asset(urlImage ?? '', package: "sdk_eums", height: 50),
            ),
            const SizedBox(height: 4),
            Text(
              title ?? '',
              style: AppStyle.regular12.copyWith(
                  color: Colors.black,
                  fontSize: controllerGet.fontSizeObx.value - 2),
            )
          ],
        ),
      ),
    );
  }

  _buildUIBannerImage({List? dataBanner}) {
    return Stack(
      children: [
        SizedBox(
          height: 164,
          width: MediaQuery.of(context).size.width,
          child: CarouselSlider(
            options: CarouselOptions(
              autoPlay: true,
              scrollDirection: Axis.horizontal,
              enlargeCenterPage: true,
              viewportFraction: 1,
              onPageChanged: (int index, CarouselPageChangedReason c) {
                setState(() {});
                _currentPageNotifier.value = index;
              },
            ),
            items: (dataBanner ?? []).map((i) {
              return Builder(
                builder: (BuildContext context) {
                  return WidgetAnimationClick(
                    onTap: () {
                      Routings().navigate(
                          context,
                          CustomWebViewBanner(
                            urlLink: i['deep_link_url'],
                          ));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                          height: 164,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                          imageUrl:
                              'https://abee997.co.kr/admin/uploads/banner/${i['img_url']}',
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) {
                            return Image.asset(Assets.logo.path,
                                package: "sdk_eums", width: 30, height: 30);
                          }),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
        Positioned(
          top: 12,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.grey.withOpacity(.5),
                borderRadius: BorderRadius.circular(12)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                  '${_currentPageNotifier.value + 1}/${dataBanner?.length ?? 0}')
            ]),
          ),
        ),
      ],
    );
  }
}

class ListViewHome extends StatefulWidget {
  const ListViewHome(
      {Key? key,
      required this.tab,
      this.fetchData,
      this.fetchDataLoadMore,
      this.scrollController,
      this.filter})
      : super(key: key);

  final int tab;
  final Function? fetchData;
  final Function? fetchDataLoadMore;
  final Function? filter;
  final ScrollController? scrollController;

  @override
  State<ListViewHome> createState() => _ListViewHomeState();
}

class _ListViewHomeState extends State<ListViewHome> {
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  ScrollController? controller;

  String allMedia = '최신순';
  final controllerGet = Get.put(SettingFontSize());

  @override
  Widget build(BuildContext context) {
    return _buildContent(context);
  }

  void _onRefresh() async {
    await Future.delayed(const Duration(seconds: 0));
    refreshController.refreshCompleted();
    setState(() {});
    widget.fetchData!();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(seconds: 0));
    refreshController.loadComplete();
    List<dynamic>? dataCampaign =
        context.read<HomeBloc>().state.listDataOfferWall;
    if (dataCampaign != null) {}
  }

  Widget _buildDropDown(BuildContext context) {
    dynamic medias = DATA_MEDIA.map((item) => item['name']).toList();
    List<DropdownMenuItem<String>> items =
        medias.map<DropdownMenuItem<String>>((String? value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(
          value ?? "",
          textAlign: TextAlign.center,
          style: AppStyle.bold.copyWith(
              color: AppColor.black, fontSize: controllerGet.fontSizeObx.value),
        ),
      );
    }).toList();

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        dropdownColor: AppColor.white,
        value: allMedia,
        style: AppStyle.bold.copyWith(color: AppColor.black, fontSize: 14),
        hint: Text(
          allMedia,
          style: AppStyle.bold.copyWith(color: AppColor.black, fontSize: 14),
        ),
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColor.black,
          size: 24,
        ),
        items: items,
        onChanged: (value) {
          setState(() {
            allMedia = value!;
          });

          widget.filter!(value);
        },
      ),
    );
  }

  _buildContent(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Column(
          children: [
            Container(
              color: AppColor.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '전체 ${state.listDataOfferWall != null ? state.listDataOfferWall.length : 0} 개',
                    style: AppStyle.regular
                        .copyWith(fontSize: controllerGet.fontSizeObx.value),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 35,
                    width: 100,
                    child: Center(child: _buildDropDown(context)),
                  ),
                ],
              ),
            ),
            Container(
              decoration:
                  const BoxDecoration(color: AppColor.white, border: Border()),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: state.listDataOfferWall != null
                  ? Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: List.generate(
                          state.listDataOfferWall?.length ?? 0,
                          (index) => WidgetAnimationClick(
                                child: widget.tab == 0
                                    ? _buildItemRow(
                                        data: state.listDataOfferWall[index])
                                    : _buildItemColum(
                                        data: state.listDataOfferWall[index]),
                                onTap: () {
                                  Routings().navigate(
                                      context,
                                      DetailOffWallScreen(
                                        title: state.listDataOfferWall[index]
                                            ['title'],
                                        xId: state.listDataOfferWall[index]
                                            ['idx'],
                                        type: state.listDataOfferWall[index]
                                            ['type'],
                                      ));
                                },
                              )),
                    )
                  : const SizedBox(),
            ),
          ],
        );
      },
    );
  }

  _buildItemColum({dynamic data}) {
    return Container(
      color: Colors.white,
      width: (MediaQuery.of(context).size.width - 48) / 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
                width: MediaQuery.of(context).size.width,
                height: 200,
                fit: BoxFit.cover,
                imageUrl: '${Constants.baseUrlImage}${data['thumbnail']}',
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) {
                  return Image.asset(Assets.logo.path,
                      package: "sdk_eums", width: 30, height: 30);
                }),
          ),
          const SizedBox(height: 4),
          Text(
            data['title'] ?? "",
            maxLines: 2,
            style: AppStyle.regular.copyWith(
                fontSize: controllerGet.fontSizeObx.value, color: Colors.black),
          ),
          const SizedBox(height: 4),
          Text(
            Constants.formatMoney(data['reward'], suffix: '원'),
            style: AppStyle.regular.copyWith(
                decoration: TextDecoration.lineThrough,
                fontSize: controllerGet.fontSizeObx.value,
                color: HexColor('#888888')),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text('60% ',
                  style: AppStyle.bold.copyWith(
                      color: HexColor('#ff7169'),
                      fontSize: 2 + controllerGet.fontSizeObx.value)),
              Text(Constants.formatMoney(data['reward'], suffix: '원'),
                  style: AppStyle.bold.copyWith(
                      color: HexColor('#000000'),
                      fontSize: 2 + controllerGet.fontSizeObx.value))
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: HexColor('#fdd000'),
                borderRadius: BorderRadius.circular(5)),
            child: Text(
              '+${Constants.formatMoney(data['reward'], suffix: '')}',
              style: AppStyle.bold.copyWith(
                  color: Colors.black,
                  fontSize: controllerGet.fontSizeObx.value),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  _buildItemRow({dynamic data}) {
    String title = '';
    switch (data['type']) {
      case 'install':
        title = '설치하면${Constants.formatMoney(data['reward'], suffix: '')}적립';
        break;
      case 'visit':
        title = '방문하면${Constants.formatMoney(data['reward'], suffix: '')}적립';
        break;
      case 'join':
        title = '가입하면${Constants.formatMoney(data['reward'], suffix: '')}적립';
        break;
      case 'shopping':
        title = '구매하면${Constants.formatMoney(data['reward'], suffix: '')}적립';
        break;
      case 'subscribe':
        title =
            '구독/좋아요/팔로우 하면 ${Constants.formatMoney(data['reward'], suffix: '')}적립 ';
        break;
      default:
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              child: CachedNetworkImage(
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                  fit: BoxFit.cover,
                  imageUrl: '${Constants.baseUrlImage}${data['thumbnail']}',
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) {
                    return Image.asset(Assets.logo.path,
                        package: "sdk_eums", width: 30, height: 30);
                  }),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                data['title'] ?? "",
                // maxLines: 2,
                style: AppStyle.bold.copyWith(
                    color: Colors.black,
                    fontSize: 2 + controllerGet.fontSizeObx.value),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: (MediaQuery.of(context).size.width) / 1.8 - 10,
                    child: Text(
                      title,
                      style: AppStyle.regular.copyWith(
                          color: HexColor('#666666'),
                          fontSize: controllerGet.fontSizeObx.value),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: HexColor('#fdd000')),
                    child: Text(
                      '포인트받기',
                      style: AppStyle.regular
                          .copyWith(fontSize: controllerGet.fontSizeObx.value),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List uiIconList = [
  {'title': '포인트 현황', 'icon': Assets.icon_point.path},
  {
    'title': '광고 보관함',
    'icon': Assets.icon_loudspeaker.path,
  },
  {
    'title': '스크랩 광고',
    'icon': Assets.adv_scrap.path,
  },
  {'title': '이용안내', 'icon': Assets.icon_info.path}
];
