import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:eums/common/events/rx_events.dart';
import 'package:eums/common/method_native/host_api.dart';
import 'package:eums/common/rx_bus.dart';
import 'package:eums/eum_app_offer_wall/lifecycale_event_handle.dart';
import 'package:eums/eum_app_offer_wall/notification_handler.dart';
import 'package:eums/eum_app_offer_wall/widget/check_box/widget_swip_check_box.dart';
import 'package:eums/eum_app_offer_wall/widget/dialogs/widget_dialog_location.dart';
import 'package:eums/eum_app_offer_wall/widget/toast/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_component/flutter_component.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:get/get_state_manager/get_state_manager.dart';
// import 'package:get/instance_manager.dart';
import 'package:eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:eums/common/constants.dart';
import 'package:eums/common/local_store/local_store_service.dart';
import 'package:eums/common/routing.dart';
// import 'package:eums/common/routing.dart';
import 'package:eums/eum_app_offer_wall/screen/home_module/bloc/home_bloc.dart';
import 'package:eums/eum_app_offer_wall/screen/home_module/widget/custom_web_view_banner.dart';
import 'package:eums/eum_app_offer_wall/screen/instruct_app_module/instruct_app.dart';
import 'package:eums/eum_app_offer_wall/screen/my_page_module/my_page.dart';
import 'package:eums/eum_app_offer_wall/screen/scrap_adverbox_module/scrap_adverbox_screen.dart';
import 'package:eums/eum_app_offer_wall/screen/status_point_module/status_point_page.dart';
import 'package:eums/eum_app_offer_wall/screen/using_term_module/using_term_screen.dart';
import 'package:eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:eums/eum_app_offer_wall/utils/appStyle.dart';
import 'package:eums/eum_app_offer_wall/utils/hex_color.dart';
import 'package:eums/eum_app_offer_wall/utils/loading_dialog.dart';
import 'package:eums/eum_app_offer_wall/widget/custom_animation_click.dart';
import 'package:eums/eum_app_offer_wall/widget/custom_dialog.dart';
import 'package:eums/eum_app_offer_wall/widget/setting_fontsize.dart';
import 'package:eums/gen/assets.gen.dart';
import 'package:eums/eums_library.dart';

import '../keep_adverbox_module/keep_adverbox_module.dart';
import 'widget/custom_scroll.dart';
import 'widget/widget_list_data_offerwall.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // final GlobalKey<State<StatefulWidget>> globalKey = GlobalKey<State<StatefulWidget>>();
  bool isStartBackground = false;
  // late LocalStore localStore;
  final _currentPageNotifier = ValueNotifier<int>(0);
  final ValueNotifier<GlobalKey<NestedScrollViewState>> globalKeyScroll = ValueNotifier(GlobalKey());
  late TabController _tabController;
  String? filter;
  late String category;
  final ScrollController controller = ScrollController();
  int tabIndex = 0;
  int tabPreviousIndex = 0;
  // dynamic account;

  bool firstShowDialogPoint = false;

  late HostOfferWallApi hostApi;

  late HomeBloc blocMain;
  late List<HomeBloc> blocs = [HomeBloc(), HomeBloc()];

  HomeInitState? homeInit;
  HomeBannerState? homeBannerState;
  List<HomeListDataOfferWallState?> homeListDataOfferWallStates = [null, null];

  @override
  void initState() {
    blocMain = HomeBloc();
    // localStore = LocalStoreService();
    hostApi = HostOfferWallApi();
    category = 'participation';

    // bloc
    //   ..add(InfoUser())
    //   ..add(GetTotalPoint())
    //   ..add(ListBanner(type: 'main'))
    //   ..add(ListOfferWall(category: categary, filter: filter, limit: 10));

    _tabController = TabController(initialIndex: 0, length: 2, vsync: this);
    _tabController.addListener(_onTabChange);
    checkPermission();
    // controller.addListener(() {});
    _registerEventBus();
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      blocMain
        ..add(HomeInitEvent())
        ..add(HomeBannerEvent(type: 'main'));

      blocs.first.add(HomeListDataOfferWallEvent(category: category, filter: filter));
      blocs.last.add(HomeListDataOfferWallEvent(category: category, filter: filter));
    });
    WidgetsBinding.instance.addObserver(LifecycleEventHandler(resumeCallBack: () async {
      // _permissionNotification();
      var status = await Permission.locationAlways.status;
      if (!status.isGranted) {
        AppAlert.showError("위치 권한이 아직 부여되지 않았습니다.");
      } else {
        AppAlert.showSuccess("위치 권한이 부여되었습니다.");
      }
    }));
  }

  @override
  void dispose() {
    _unregisterEventBus();
    super.dispose();
  }

  Future<void> _registerEventBus() async {
    RxBus.register<UpdateUser>().listen((event) {
      _fetchData();
    });
    EventStaticComponent.instance.add(
      key: "isStartBackground",
      event: (params, key) {
        if (params['data'] != null) {
          isStartBackground = params['data'];
          setState(() {});
        }
      },
    );
  }

  void _unregisterEventBus() {
    RxBus.destroy();
  }

  checkPermission() async {
    isStartBackground = LocalStoreService.instant.getSaveAdver();
    if (isStartBackground) {
      // bool isRunning = await FlutterBackgroundService().isRunning();
      // if (!isRunning) {
      //   LoadingDialog.instance.show();
      //   await FlutterBackgroundService().startService();
      //   LoadingDialog.instance.hide();
      // }
    }
    if (Platform.isAndroid) {
      final bool status = await FlutterOverlayWindow.isPermissionGranted();

      if (!status) {
        await FlutterOverlayWindow.requestPermission();
      } else {}
      LocalStoreService.instant.setAccessToken(LocalStoreService.instant.getAccessToken());
    }
  }

  _onTabChange() {
    tabIndex = _tabController.index;
    if (tabIndex != tabPreviousIndex) {
      // _fetchData();
      if (_tabController.index == 0) {
        category = 'participation';
      } else {
        category = 'mission';
      }
      setState(() {});

      if (homeListDataOfferWallStates[_tabController.index] == null) {
        blocs[_tabController.index].add(HomeListDataOfferWallEvent(
          filter: filter,
          category: category,
        ));
      }
    }
    tabPreviousIndex = _tabController.index;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(
          create: (context) => blocMain,
        ),
        ...List.generate(
          blocs.length,
          (index) => BlocProvider(
            create: (context) => blocs[index],
          ),
        )
      ],
      child: MultiBlocListener(
        listeners: [
          // BlocListener<HomeBloc, HomeState>(
          //   listener: _listenListAdver,
          // ),
          BlocListener<HomeBloc, HomeState>(
            bloc: blocMain,

            // listenWhen: (previous, current) => previous.getPointStatus != current.getPointStatus,
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
    // if (state.getPointStatus == GetPointStatus.loading) {
    //   LoadingDialog.instance.show();
    //   return;
    // }
    // if (state.getPointStatus == GetPointStatus.failure) {
    //   LoadingDialog.instance.hide();
    //   return;
    // }
    // if (state.getPointStatus == GetPointStatus.success) {
    //   LoadingDialog.instance.hide();
    //   if (state.totalPoint != null && firstShowDialogPoint == false) {
    //     firstShowDialogPoint = true;
    //     DialogUtils.showDialogGetPoint(context, data: state.totalPoint);
    //   }
    // }
    if (state is HomeInitState) {
      if (state.totalPoint != null && firstShowDialogPoint == false) {
        firstShowDialogPoint = true;
        DialogUtils.showDialogGetPoint(context, data: state.totalPoint);
      }
    }
  }

  // void _listenListAdver(BuildContext context, HomeState state) {
  //   if (state.listAdverStatus == ListAdverStatus.loading) {
  //     LoadingDialog.instance.show();
  //     return;
  //   }
  //   if (state.listAdverStatus == ListAdverStatus.failure) {
  //     LoadingDialog.instance.hide();
  //     return;
  //   }
  //   if (state.listAdverStatus == ListAdverStatus.success) {
  //     LoadingDialog.instance.hide();
  //   }
  // }

  final controllerGet = Get.put(SettingFontSize());

  _buildContent(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      bloc: blocMain,
      buildWhen: (previous, current) => current is HomeInitState || current is HomeBannerState,
      builder: (context, state) {
        if (state is HomeInitState) {
          homeInit = state;
        }
        if (state is HomeBannerState) {
          homeBannerState = state;
        }
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: AppColor.white,
            leading: WidgetAnimationClick(
              onTap: () {
                hostApi.cancel();
                // MethodOfferwallChannel.instant.back();
                // Navigator.pop(context);
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
                  child: Assets.icons.logoEums.image(package: 'eums', height: 20),
                  // child: Image.asset(
                  //   Assets.logo_eums.path,
                  //   package: "eums",
                  //   height: 20,
                  // ),
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 14),
                  child: Text('리워드', style: AppStyle.bold.copyWith(color: AppColor.black, fontSize: 4 + controllerGet.fontSizeObx.value)),
                ),
              ],
            ),
            actions: [
              WidgetAnimationClick(
                onTap: () {
                  Routings().navigate(context, const MyPage());
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  // child: Image.asset(Assets.my_page.path, package: "eums", height: 24),
                  child: Assets.icons.myPage.image(height: 24),
                ),
              ),
              const SizedBox(
                width: 25,
              )
            ],
          ),
          // key: globalKey,
          body: WidgetCustomScroll(
            scrollController: controller,
            buildChildren: (BuildContext context, ValueNotifier<bool> showAppBar, ScrollController scrollController) {
              return [
                CustomSliverList(
                  children: [
                    _buildUIShowPoint(point: homeInit?.totalPoint != null ? homeInit?.totalPoint['userPoint'] : 0),
                    Center(
                      child: Row(
                        children: List.generate(
                            uiIconList.length,
                            (index) => Expanded(
                                  child: _buildUiIcon(
                                      onTap: () {
                                        switch (index) {
                                          case 0:
                                            Routings().navigate(context, StatusPointPage(account: homeInit!.account));
                                            break;
                                          case 1:
                                            Routings().navigate(context, const KeepAdverboxScreen());
                                            break;
                                          case 2:
                                            Routings().navigate(context, const ScrapAdverBoxScreen());
                                            break;
                                          case 3:
                                            Routings().navigate(context, const UsingTermScreen());
                                            break;
                                          default:
                                        }
                                      },
                                      urlImage: uiIconList[index]['icon'],
                                      title: uiIconList[index]['title']),
                                )),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildUIBannerImage(dataBanner: homeBannerState?.bannerList),
                  ],
                ),
                CustomSliverAppBar(
                  expandedHeight: 0,
                  toolbarHeight: kToolbarHeight - MediaQuery.of(context).padding.top,
                  header: TabBar(
                    onTap: (value) {
                      // int index = value;
                      // if (_tabController.index == 0) {
                      //   categary = 'participation';
                      // } else {
                      //   categary = 'mission';
                      // }
                      // _fetchData();
                      // setState(() {
                      //   _tabController.index = index;
                      // });
                    },
                    labelPadding: const EdgeInsets.only(bottom: 10, top: 10),
                    controller: _tabController,
                    indicatorColor: HexColor('#f4a43b'),
                    unselectedLabelColor: HexColor('#707070'),
                    unselectedLabelStyle: AppStyle.medium.copyWith(
                      fontSize: controllerGet.fontSizeObx.value,
                      color: HexColor('#707070'),
                    ),
                    labelColor: HexColor('#f4a43b'),
                    labelStyle: AppStyle.bold.copyWith(
                      fontSize: controllerGet.fontSizeObx.value,
                      color: HexColor('#707070'),
                    ),
                    tabs: const [
                      Text(
                        '참여하고 리워드',
                        // style: AppStyle.bold.copyWith(fontSize: controllerGet.fontSizeObx.value),
                      ),
                      Text(
                        '쇼핑하고 리워드',
                        // style: AppStyle.bold.copyWith(fontSize: controllerGet.fontSizeObx.value),
                      ),
                    ],
                  ),
                ),
                CustomSliverList(
                  children: [
                    _buildUIPoint(point: homeInit?.totalPoint != null ? homeInit?.totalPoint['totalPointCanGet'] : 0),
                    // ListViewHome(
                    //   tab: _tabController.index,
                    //   filter: _filterMedia,
                    //   scrollController: controller,
                    // )
                  ],
                ),
                ListViewHome(
                  tab: _tabController.index,
                  onFilter: _filterMedia,
                  category: category,
                  filter: filter,
                  scrollController: scrollController,
                  stateClients: homeListDataOfferWallStates,
                  blocs: blocs,
                ),
              ];
            },
            onRefresh: () {
              _fetchData();
            },
          ),
        );
      },
    );
  }

  _fetchData() async {
    if (_tabController.index == 0) {
      category = 'participation';
    } else {
      category = 'mission';
    }
    // await Future.delayed(const Duration(seconds: 1));
    // globalKey.currentContext?.read<HomeBloc>().add(GetTotalPoint());
    // globalKey.currentContext?.read<HomeBloc>().add(ListOfferWall(
    //       limit: 10,
    //       filter: filter,
    //       category: categary,
    //     ));

    // bloc.add(GetTotalPoint());
    // bloc.add(ListOfferWall(
    //   limit: 10,
    //   filter: filter,
    //   category: category,
    // ));
    blocMain.add(HomeInitEvent());
    blocMain.add(HomeBannerEvent(type: 'main'));
    blocs[_tabController.index]
        .add(HomeListDataOfferWallEvent(filter: filter, category: category, stateClient: homeListDataOfferWallStates[_tabController.index]));
  }

  void _filterMedia(String? value) {
    if (value != '최신순') {
      dynamic media = (DATA_MEDIA.where((element) => element['name'] == value).toList())[0]['media'];
      filter = media;
    } else {
      filter = DATA_MEDIA[2]['media'];
    }
    setState(() {});
    _fetchData();
  }

  _buildUIPoint({int? point}) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: HexColor('#888888').withOpacity(.2), width: 5),
              top: BorderSide(color: HexColor('#888888').withOpacity(.2), width: 5))),
      child: Center(
        child: Wrap(
          spacing: 12,
          direction: Axis.horizontal,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '지금 획득 가능한 포인트',
              style: AppStyle.regular.copyWith(color: HexColor('#888888'), fontSize: controllerGet.fontSizeObx.value),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image.asset(Assets.icon_point_y.path, package: "eums", height: 24),
                Assets.icons.iconPointY.image(height: 24),
                const SizedBox(width: 6),
                Text(
                  Constants.formatMoney(point, suffix: ''),
                  style: AppStyle.bold.copyWith(fontSize: 6 + controllerGet.fontSizeObx.value),
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
      decoration: BoxDecoration(border: Border.all(color: HexColor('#e5e5e5')), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              '현재 적립된 포인트',
              style: AppStyle.regular.copyWith(fontSize: controllerGet.fontSizeObx.value, color: Colors.black),
            ),
          ),
          WidgetAnimationClick(
            onTap: () {
              Routings().navigate(context, StatusPointPage(account: homeInit!.account));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Image.asset(Assets.icon_point_y.path, package: "eums", height: 24),
                  Assets.icons.iconPointY.image(height: 24),
                  const SizedBox(width: 12),
                  Text(Constants.formatMoney(point, suffix: ''), style: AppStyle.bold.copyWith(fontSize: 30, color: Colors.black)),
                  Text('P', style: AppStyle.bold.copyWith(fontSize: 18, color: Colors.black)),
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
              Routings().navigate(context, const InstructAppScreen());
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Image.asset(Assets.err_grey.path, package: "eums", height: 12),
                  Assets.icons.errGrey.image(height: 12),
                  const SizedBox(width: 4),
                  Text(
                    '서비스 이용 안내',
                    style: AppStyle.regular12.copyWith(color: HexColor('#888888'), fontSize: controllerGet.fontSizeObx.value - 2),
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
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 1.5,
                  child: Text(
                    // isStartBackground ? '벌 광고 활성화 중입니다' : '벌 광고 비활성화 중입니다',
                    isStartBackground ? '캐릭터 광고 활성화 중입니다' : '캐릭터 광고 비활성화 중입니다',
                    maxLines: 2,
                    style: AppStyle.medium.copyWith(color: Colors.black, fontSize: controllerGet.fontSizeObx.value),
                  ),
                ),
                const Spacer(),
                WidgetSwipCheckBox(
                  valueDefault: isStartBackground,
                  onChange: (value) async {
                    // setState(() {
                    //   isdisable = !isdisable;
                    // });

                    await LocalStoreService.instant.setSaveAdver(isStartBackground);
                    if (!value) {
                      String? token = await NotificationHandler.instant.getToken();
                      await EumsOfferWallServiceApi().unRegisterTokenNotifi(token: token);
                      // FlutterBackgroundService().invoke("stopService");
                    } else {
                      final checkBackgroundLocation = await _checkPermissionLocationBackground();
                      if (checkBackgroundLocation == true) {
                        // dynamic data = <String, dynamic>{
                        //   'count': 0,
                        //   'date': Constants.formatTime(DateTime.now().toIso8601String()),
                        // };
                        // localStore?.setCountAdvertisement(data);
                        String? token = LocalStoreService.instant.getDeviceToken();
                        await EumsOfferWallServiceApi().createTokenNotifi(token: token);
                        // bool isRunning = await FlutterBackgroundService().isRunning();
                        // if (!isRunning) {
                        //   await FlutterBackgroundService().startService();
                        // }
                      } else {
                        isStartBackground = false;
                        setState(() {});
                        return;
                      }
                    }
                    setState(() {
                      isStartBackground = value;
                    });
                  },
                )
                // WidgetAnimationClick(
                //   onTap: () async {
                //     setState(() {
                //       isdisable = !isdisable;
                //     });
                //     localStore.setSaveAdver(isdisable);
                //     if (isdisable) {
                //       String? token = await FirebaseMessaging.instance.getToken();

                //       await EumsOfferWallServiceApi().unRegisterTokenNotifi(token: token);
                //       FlutterBackgroundService().invoke("stopService");
                //     } else {
                //       dynamic data = <String, dynamic>{
                //         'count': 0,
                //         'date': Constants.formatTime(DateTime.now().toIso8601String()),
                //       };
                //       // localStore?.setCountAdvertisement(data);
                //       String? token = await FirebaseMessaging.instance.getToken();
                //       await EumsOfferWallServiceApi().createTokenNotifi(token: token);
                //       bool isRunning = await FlutterBackgroundService().isRunning();
                //       if (!isRunning) {
                //         FlutterBackgroundService().startService();
                //       }
                //     }
                //   },
                //   child: Container(
                //     padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                //     width: 34,
                //     decoration: BoxDecoration(
                //         color: !isdisable ? AppColor.orange2 : AppColor.white,
                //         borderRadius: BorderRadius.circular(12),
                //         border: Border.all(color: !isdisable ? Colors.transparent : AppColor.color70)),
                //     child: Row(
                //       children: [
                //         isdisable
                //             ? Container(
                //                 decoration: const BoxDecoration(
                //                   shape: BoxShape.circle,
                //                   color: AppColor.color70,
                //                 ),
                //                 padding: const EdgeInsets.all(4),
                //                 child: Image.asset(
                //                   Assets.check.path,
                //                   package: "eums",
                //                   height: 7,
                //                   color: Colors.transparent,
                //                 ),
                //               )
                //             : const SizedBox(),
                //         const Spacer(),
                //         isdisable
                //             ? const SizedBox()
                //             : Container(
                //                 decoration: const BoxDecoration(
                //                   shape: BoxShape.circle,
                //                   color: AppColor.white,
                //                 ),
                //                 padding: const EdgeInsets.all(4),
                //                 child: Image.asset(
                //                   Assets.check.path,
                //                   package: "eums",
                //                   height: 7,
                //                   color: Colors.transparent,
                //                 ),
                //               ),
                //       ],
                //     ),
                //   ),
                // )
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<bool> _checkPermissionLocationBackground() async {
    if (await Permission.locationAlways.status != PermissionStatus.granted) {
      try {
        var status = await Permission.locationWhenInUse.status;
        if (!status.isGranted) {
          var status = await Permission.locationWhenInUse.request();
          if (status.isGranted) {
            var status = await Permission.locationAlways.status;
            if (!status.isGranted) {
              // ignore: use_build_context_synchronously
              await WidgetDialogLocation.show(
                context,
                onAccept: () async {
                  var status = await Permission.locationAlways.request();
                  if (!status.isGranted) {
                    AppAlert.showError("위치 권한이 아직 부여되지 않았습니다.");
                  } else {
                    AppAlert.showSuccess("위치 권한이 부여되었습니다.");
                  }
                },
              );
            }
            if (status.isPermanentlyDenied) {
              await Geolocator.openLocationSettings();
            }
          } else {
            _checkPermissionLocationBackground();
          }
        } else {
          var status = await Permission.locationAlways.status;
          if (!status.isGranted) {
            // ignore: use_build_context_synchronously
            await WidgetDialogLocation.show(
              context,
              onAccept: () async {
                var status = await Permission.locationAlways.request();
                if (status.isPermanentlyDenied) {
                  await Geolocator.openLocationSettings();
                } else {
                  if (!status.isGranted) {
                    AppAlert.showError("위치 권한이 아직 부여되지 않았습니다.");
                  } else {
                    AppAlert.showSuccess("위치 권한이 부여되었습니다.");
                  }
                }
              },
            );
          }
        }
      } catch (e) {
        return false;
      }
      return false;
    } else {
      return true;
    }
  }

  Widget _buildUiIcon({String? title, String? urlImage, Function()? onTap}) {
    return WidgetAnimationClick(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 9),
            decoration: BoxDecoration(shape: BoxShape.circle, color: HexColor('#888888').withOpacity(0.3)),
            child: Image.asset(urlImage ?? '', package: "eums", height: 50),
          ),
          const SizedBox(height: 4),
          Text(
            title ?? '',
            style: AppStyle.regular12.copyWith(color: Colors.black, fontSize: controllerGet.fontSizeObx.value - 2),
          )
        ],
      ),
    );
  }

  _buildUIBannerImage({List? dataBanner}) {
    return ValueListenableBuilder(
        valueListenable: _currentPageNotifier,
        builder: (context, value, child) => Stack(
              children: [
                SizedBox(
                  // height: 164,
                  width: MediaQuery.of(context).size.width,
                  child: CarouselSlider(
                    options: CarouselOptions(
                      autoPlay: true,
                      scrollDirection: Axis.horizontal,
                      enlargeCenterPage: true,
                      viewportFraction: 1,
                      onPageChanged: (int index, CarouselPageChangedReason c) {
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
                                  // height: 164,
                                  width: MediaQuery.of(context).size.width,
                                  fit: BoxFit.cover,
                                  imageUrl: 'https://abee997.co.kr/admin/uploads/banner/${i['img_url']}',
                                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) {
                                    return Image.asset(Assets.logo.path, package: "eums", width: 30, height: 30);
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
                    decoration: BoxDecoration(color: Colors.grey.withOpacity(.5), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text('${_currentPageNotifier.value + 1}/${dataBanner?.length ?? 0}')]),
                  ),
                ),
              ],
            ));
  }
}

List uiIconList = [
  {'title': '포인트 현황', 'icon': Assets.icons.iconPoint.path},
  {
    'title': '광고 보관함',
    'icon': Assets.icons.iconLoudspeaker.path,
  },
  {
    'title': '스크랩 광고',
    'icon': Assets.icons.iconAdvScrap.path,
  },
  {'title': '이용안내', 'icon': Assets.icons.iconInfo.path}
];
