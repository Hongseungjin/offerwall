import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:sdk_eums/common/constants.dart';
import 'package:sdk_eums/common/local_store/local_store.dart';
import 'package:sdk_eums/common/local_store/local_store_service.dart';
import 'package:sdk_eums/common/routing.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/home_module/bloc/home_bloc.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/scrap_adverbox_module/scrap_adverbox_screen.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/status_point_module/status_point_page.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appStyle.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/hex_color.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/loading_dialog.dart';
import 'package:sdk_eums/gen/assets.gen.dart';
import 'package:sdk_eums/sdk_eums_library.dart';

import '../keep_adverbox_module/keep_adverbox_module.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  bool isdisable = false;
  LocalStore? localStore;
  final _currentPageNotifier = ValueNotifier<int>(0);
  final ValueNotifier<GlobalKey<NestedScrollViewState>> globalKeyScroll =
      ValueNotifier(GlobalKey());
  late TabController _tabController;
  String? filter;

  @override
  void initState() {
    localStore = LocalStoreService();
    _tabController = TabController(initialIndex: 0, length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (context) => HomeBloc()
        ..add(ListOfferWall())
        ..add(InfoUser()),
      child: MultiBlocListener(
        listeners: [
          BlocListener<HomeBloc, HomeState>(
            listener: _listenListAdver,
          ),
        ],
        child: WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: _buildContent(context)),
      ),
    );
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

  _buildContent(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child:
                      ValueListenableBuilder<GlobalKey<NestedScrollViewState>>(
                    valueListenable: globalKeyScroll,
                    builder: (context, value, child) {
                      return NestedScrollView(
                        key: value,
                        physics: const AlwaysScrollableScrollPhysics(),
                        floatHeaderSlivers: true,
                        headerSliverBuilder:
                            (BuildContext context, bool innerBoxIsScrolled) {
                          return [
                            SliverAppBar(
                              toolbarHeight:
                                  MediaQuery.of(context).size.height /
                                      (5 / 3.5),
                              backgroundColor: Colors.white,
                              automaticallyImplyLeading: false,
                              actions: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                    children: [
                                      _buildUIShowPoint(point: '2000'),
                                      Wrap(
                                        spacing: 10,
                                        children: List.generate(
                                            uiIconList.length,
                                            (index) => _buildUiIcon(
                                                onTap: () {
                                                  switch (index) {
                                                    case 0:
                                                      Routing().navigate(
                                                          context,
                                                          StatusPointPage(
                                                              account: state
                                                                  .account));
                                                      break;
                                                    case 1:
                                                      Routing().navigate(
                                                          context,
                                                          KeepAdverboxScreen());
                                                      break;
                                                    case 2:
                                                      Routing().navigate(
                                                          context,
                                                          ScrapAdverBoxScreen());

                                                      break;
                                                    default:
                                                  }
                                                },
                                                urlImage: uiIconList[index]
                                                    ['icon'],
                                                title: uiIconList[index]
                                                    ['title'])),
                                      ),
                                      const SizedBox(height: 20),
                                      _buildUIBannerImage()
                                    ],
                                  ),
                                )
                              ],
                            )
                          ];
                        },
                        body: Column(
                          children: [
                            TabBar(
                              onTap: (value) {
                                int index = value;
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
                              labelStyle: AppStyle.bold
                                  .copyWith(color: HexColor('#707070')),
                              tabs: const [
                                Text(
                                  '다이아 충전',
                                ),
                                Text('이용내역'),
                              ],
                            ),
                            _buildUIPoint(point: 123123123),
                            Expanded(
                              child: Container(
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(24),
                                        topRight: Radius.circular(24))),
                                child: TabBarView(
                                    controller: _tabController,
                                    children: [
                                      ListViewHome(
                                        tab: _tabController.index,
                                        filter: _filterMedia,
                                      ),
                                      ListViewHome(
                                        tab: _tabController.index,
                                        filter: _filterMedia,
                                      )
                                    ]),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _filterMedia(String? value) {
    setState(() {
      filter = value;
    });
    // _fetchData();
  }

  _buildUIPoint({int? point}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: HexColor('#888888').withOpacity(.2), width: 5),
              top: BorderSide(
                  color: HexColor('#888888').withOpacity(.2), width: 5))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            '지금 획득 가능한 포인트',
            style: AppStyle.regular
                .copyWith(color: HexColor('#888888'), fontSize: 14),
          ),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: HexColor('#fcc900')),
            child: Text('P', style: AppStyle.bold.copyWith(fontSize: 18)),
          ),
          Text(
            Constants.formatMoney(point, suffix: ''),
            style: AppStyle.bold.copyWith(fontSize: 20),
          )
        ],
      ),
    );
  }

  _buildUIShowPoint({
    String? point,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
          border: Border.all(color: HexColor('#e5e5e5')),
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              '현재 적립된 포인트',
              style:
                  AppStyle.regular.copyWith(fontSize: 14, color: Colors.black),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: HexColor('#fcc900')),
                  child: Text('P', style: AppStyle.bold.copyWith(fontSize: 18)),
                ),
                const SizedBox(width: 12),
                Text(point ?? '',
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
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '서비스 이용 안내',
              style: AppStyle.regular12.copyWith(color: HexColor('#888888')),
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
                Text(
                  isdisable ? ' 벌 광고 활성화 중 입니다.' : '벌 광고 비활성화 중 입니다.',
                  style: AppStyle.medium
                      .copyWith(color: Colors.black, fontSize: 14),
                ),
                const Spacer(),
                GestureDetector(
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
                    width: 40,
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
                                padding: const EdgeInsets.all(7),
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
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: HexColor('#888888').withOpacity(0.3)),
            child: Image.asset(urlImage ?? '', package: "sdk_eums", height: 35),
          ),
          const SizedBox(height: 4),
          Text(
            title ?? '',
            style: AppStyle.regular12.copyWith(color: Colors.black),
          )
        ],
      ),
    );
  }

  _buildUIBannerImage() {
    return Stack(
      children: [
        CarouselSlider(
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
          items: imageList.map((i) {
            return Builder(
              builder: (BuildContext context) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(i,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.fitWidth,
                      package: "sdk_eums"),
                );
              },
            );
          }).toList(),
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
              Text('${_currentPageNotifier.value + 1}/${imageList.length}')
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
      this.filter})
      : super(key: key);

  final int tab;
  final Function? fetchData;
  final Function? fetchDataLoadMore;
  final Function? filter;

  @override
  State<ListViewHome> createState() => _ListViewHomeState();
}

class _ListViewHomeState extends State<ListViewHome> {
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  ScrollController? controller;

  String allMedia = '최신순';

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
    if (dataCampaign != null) {
      widget.fetchDataLoadMore!(offset: dataCampaign.length);
    }
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
          style: AppStyle.bold.copyWith(color: AppColor.black),
          maxLines: 1,
        ),
      );
    }).toList();

    // _filterMedia(String? value) {
    //   if (value != '최신순') {
    //     dynamic media = (DATA_MEDIA
    //         .where((element) => element['name'] == value)
    //         .toList())[0]['media'];

    //     filter = media;
    //   } else {
    //     filter = DATA_MEDIA[2]['media'];
    //   }
    //   // _fetchData();
    // }

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
          Icons.arrow_drop_down,
          color: AppColor.black,
        ),
        items: items,
        onChanged: (value) {
          setState(() {
            allMedia = value!;
          });

          widget.filter!(value);

          // _filterMedia(value);
        },
      ),
    );
  }

  _buildContent(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Column(
          children: [
            Row(
              children: [
                Text('asdjkas'),
                Container(
                  height: 35,
                  width: 100,
                  child: Center(child: _buildDropDown(context)),
                ),
              ],
            ),
            Expanded(
              child: Container(
                  decoration: BoxDecoration(
                      color: AppColor.white,
                      border: Border(
                          top: BorderSide(
                              color: AppColor.grey5D.withOpacity(0.2),
                              width: 2))),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: SmartRefresher(
                    controller: refreshController,
                    onRefresh: _onRefresh,
                    onLoading: _onLoading,
                    header: CustomHeader(
                      builder: (BuildContext context, RefreshStatus? mode) {
                        return const Center(
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.black)));
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
                            : SizedBox();
                      },
                    ),
                    enablePullDown: true,
                    enablePullUp: true,
                    child: state.listDataOfferWall != null
                        ? Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: List.generate(
                                state.listDataOfferWall.length,
                                (index) => widget.tab == 0
                                    ? _buildItemRow(
                                        data: state.listDataOfferWall[index])
                                    : _buildItemColum(
                                        data: state.listDataOfferWall[index])),
                          )
                        : SizedBox(),
                    // child: state.listDataOfferWall != null
                    //     ? ListView.builder(
                    //         controller: controller,
                    //         itemCount: state.listDataOfferWall.length ?? 0,
                    //         itemBuilder: (context, index) {
                    //           return widget.tab == 0
                    //               ? _buildItemRow(
                    //                   data: state.listDataOfferWall[index])
                    //               : _buildItemColum(
                    //                   data: state.listDataOfferWall[index]);
                    //         },
                    //       )
                    //     : const SizedBox()),
                  )),
            ),
          ],
        );
      },
    );
    // return Padding(
    //   padding: const EdgeInsets.all(16),
    //   child: SingleChildScrollView(
    //     child: Wrap(
    //       spacing: 12,
    //       runSpacing: 12,
    //       children: List.generate(10,
    //           (index) => widget.tab == 0 ? _buildItemRow() : _buildItemColum()),
    //     ),
    //   ),
    // );
  }

  _buildItemColum({dynamic data}) {
    return Container(
      color: Colors.white,
      width: (MediaQuery.of(context).size.width - 48) / 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(10)),
              child: Image.asset(Assets.rewardGuide.path,
                  width: (MediaQuery.of(context).size.width - 48) / 2,
                  height: (MediaQuery.of(context).size.width - 48) / 2,
                  fit: BoxFit.fitWidth,
                  package: "sdk_eums"),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data['title'] ?? "",
            maxLines: 2,
            style: AppStyle.regular.copyWith(fontSize: 14, color: Colors.black),
          ),
          const SizedBox(height: 4),
          Text(
            Constants.formatMoney(data['reward'], suffix: '원'),
            style: AppStyle.regular.copyWith(
                decoration: TextDecoration.lineThrough,
                color: HexColor('#888888')),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text('60% ',
                  style: AppStyle.bold
                      .copyWith(color: HexColor('#ff7169'), fontSize: 16)),
              Text(Constants.formatMoney(data['reward'], suffix: '원'),
                  style: AppStyle.bold
                      .copyWith(color: HexColor('#000000'), fontSize: 16))
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  _buildItemRow({dynamic data}) {
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
                  topLeft: Radius.circular(16), topRight: Radius.circular(16)),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                data['title'] ?? "",
                style: AppStyle.bold.copyWith(color: Colors.black),
              ),
            ),
            // const SizedBox(
            //   height: 5,
            // ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
            //   child: Text("리워드페이지 출석하고 캐시 받자!",
            //       style: AppStyle.bold.copyWith(color: Colors.black)),
            // ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Text(
                    '출석하면 최대',
                    style: AppStyle.regular
                        .copyWith(color: HexColor('#666666'), fontSize: 14),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '+${Constants.formatMoney(data['reward'], suffix: '')}',
                    style: AppStyle.bold
                        .copyWith(color: HexColor('f4a43b'), fontSize: 14),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: HexColor('#fdd000')),
                    child: const Text('포인트받기'),
                  )
                ],
              ),
            )
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

List imageList = [Assets.rewardGuide.path, Assets.rewardGuideMome.path];
