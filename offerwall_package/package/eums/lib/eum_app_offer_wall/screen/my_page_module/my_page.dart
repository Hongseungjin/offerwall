import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:eums/eum_app_offer_wall/widget/widget_animation_click_v2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:eums/common/constants.dart';
import 'package:eums/common/local_store/local_store_service.dart';
import 'package:eums/common/routing.dart';
import 'package:eums/eum_app_offer_wall/screen/asked_question_module/asked_question_screen.dart';
import 'package:eums/eum_app_offer_wall/screen/keep_adverbox_module/keep_adverbox_module.dart';
import 'package:eums/eum_app_offer_wall/screen/link_addvertising_module/link_addvertising_screen.dart';
import 'package:eums/eum_app_offer_wall/screen/notifi_module/notifi_screen.dart';
import 'package:eums/eum_app_offer_wall/screen/request_module/request_screen.dart';
import 'package:eums/eum_app_offer_wall/screen/scrap_adverbox_module/scrap_adverbox_screen.dart';
import 'package:eums/eum_app_offer_wall/screen/setting_fontsize/setting_fonesize_screen.dart';
import 'package:eums/eum_app_offer_wall/screen/setting_module/setting_screen.dart';
import 'package:eums/eum_app_offer_wall/screen/status_point_module/status_point_page.dart';
import 'package:eums/eum_app_offer_wall/screen/using_term_module/using_term_screen.dart';
import 'package:eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:eums/eum_app_offer_wall/utils/appStyle.dart';
import 'package:eums/eum_app_offer_wall/utils/hex_color.dart';
import 'package:eums/eum_app_offer_wall/utils/loading_dialog.dart';
import 'package:eums/eum_app_offer_wall/widget/widget_animation_click.dart';
import 'package:eums/eum_app_offer_wall/widget/setting_fontsize.dart';
import 'package:eums/gen/assets.gen.dart';

import '../../../common/rx_bus.dart';
import 'bloc/my_page_bloc.dart';
import 'instruct_page.dart';

class MyPage extends StatefulWidget {
  const MyPage({
    Key? key,
  }) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final _currentPageNotifier = ValueNotifier<int>(0);
  dynamic dataUser;
  // LocalStore? localStore = LocalStoreService();
  final controllerGet = Get.put(SettingFontSize());

  @override
  void initState() {
    getUser();
    _registerEventBus();
    super.initState();
  }

  getUser() async {
    dataUser = await LocalStoreService.instant.getDataUser();
    setState(() {});
  }

  Future<void> _registerEventBus() async {}

  void _unregisterEventBus() {
    RxBus.destroy();
  }

  @override
  void dispose() {
    _unregisterEventBus();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MyPageBloc>(
      create: (context) => MyPageBloc()
      // ..add(ListBanner(type: 'setting'))
      ,
      child: MultiBlocListener(
        listeners: [
          BlocListener<MyPageBloc, MyPageState>(
            listener: _listenListAdver,
          ),
        ],
        child: _buildContent(context),
      ),
    );
  }

  void _listenListAdver(BuildContext context, MyPageState state) {
    if (state.loadBannerStatus == LoadBannerStatus.loading) {
      LoadingDialog.instance.show();
      return;
    }
    if (state.loadBannerStatus == LoadBannerStatus.failure) {
      LoadingDialog.instance.hide();
      return;
    }
    if (state.loadBannerStatus == LoadBannerStatus.success) {
      LoadingDialog.instance.hide();
    }
  }

  _buildItem() {
    List<String> dataAreaName = (listItemMy.map((item) => item['area'].toString())).toSet().toList();
    return Wrap(
      children: List.generate(
          dataAreaName.length, (index) => _buildAreaItem(data: listItemMy.where((element) => element['area'] == dataAreaName[index]).toList())),
    );
  }

  _buildContent(BuildContext context) {
    return BlocBuilder<MyPageBloc, MyPageState>(
      builder: (context, state) {
        return Obx(() => Scaffold(
              backgroundColor: AppColor.white,
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                centerTitle: true,
                leading: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
                title: Text(
                  // '설정',
                  '마이페이지',
                  style: AppStyle.bold.copyWith(color: Colors.black, fontSize: 4 + controllerGet.fontSizeObx.value),
                ),
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          // Image.asset(
                          //   Assets.user.path,
                          //   package: "eums",
                          //   height: 50,
                          //   width: 50,
                          // ),
                          Assets.icons.user.image(
                            height: 50,
                            width: 50,
                          ),
                          const SizedBox(width: 20),
                          Text(
                            dataUser != null ? dataUser['memId'] : '',
                            style: AppStyle.bold.copyWith(fontSize: 4 + controllerGet.fontSizeObx.value),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: WidgetAnimationClickV2(
                        color: HexColor('#fdd000'),
                        borderRadius: BorderRadius.circular(10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        onTap: () {
                          Routings().navigate(context, StatusPointPage(account: dataUser));
                        },
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                'P',
                                style: AppStyle.bold.copyWith(color: Colors.black),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              dataUser != null ? Constants.formatMoney(dataUser['memPoint'] ?? 0, suffix: 'P') : '',
                              style: AppStyle.bold.copyWith(fontSize: controllerGet.fontSizeObx.value),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.arrow_forward_ios_sharp,
                              size: 22,
                            )
                          ],
                        ),
                      ),
                    ),
                    // _buildUIBannerImage(dataBanner: state.listBanner),
                    _buildItem(),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                      decoration: const BoxDecoration(color: Color(0xfff9f9f9)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "(주)더 아비",
                            style: AppStyle.bold.copyWith(fontSize: controllerGet.fontSizeObx.value, color: const Color(0xff666666)),
                          ),
                          const SizedBox(height: 10),
                          _buildRowText("대표이사", "공병기"),
                          _buildRowText("사업자 등록번호", "468-88-01692"),
                          _buildRowText("통신판매업신고", "2022-인천남동구-1729"),
                          _buildRowText("주소", "인천 남동구 구월동 1134-12 태양빌딩 5층"),
                          const SizedBox(height: 10),
                          Text(
                            "© Copyright THE A-BEE. All Rights Reserved",
                            style: AppStyle.medium.copyWith(fontSize: controllerGet.fontSizeObx.value, color: const Color(0xff666666)),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ));
      },
    );
  }

  Widget _buildRowText(String title, String body) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              title,
              style: AppStyle.medium.copyWith(fontSize: controllerGet.fontSizeObx.value, color: const Color(0xff666666)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              body,
              style: AppStyle.medium.copyWith(fontSize: controllerGet.fontSizeObx.value, color: const Color(0xff666666)),
            ),
          ),
        ],
      ),
    );
  }
  // _buildUIBannerImage({List? dataBanner}) {
  //   return Stack(
  //     children: [
  //       CarouselSlider(
  //         options: CarouselOptions(
  //           autoPlay: true,
  //           scrollDirection: Axis.horizontal,
  //           enlargeCenterPage: true,
  //           viewportFraction: 1,
  //           onPageChanged: (int index, CarouselPageChangedReason c) {
  //             setState(() {});
  //             _currentPageNotifier.value = index;
  //           },
  //         ),
  //         items: (dataBanner ?? []).map((i) {
  //           return Builder(
  //             builder: (BuildContext context) {
  //               return ClipRRect(
  //                 borderRadius: BorderRadius.circular(8),
  //                 child: CachedNetworkImage(
  //                     width: MediaQuery.of(context).size.width,
  //                     height: 200,
  //                     fit: BoxFit.cover,
  //                     imageUrl: 'https://abee997.co.kr/admin/uploads/banner/${i['img_url']}',
  //                     placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
  //                     errorWidget: (context, url, error) {
  //                       return Image.asset(Assets.logo.path, package: "eums", width: 30, height: 30);
  //                     }),
  //               );
  //             },
  //           );
  //         }).toList(),
  //       ),
  //       Positioned(
  //         top: 12,
  //         right: 16,
  //         child: Container(
  //           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  //           decoration: BoxDecoration(color: Colors.grey.withOpacity(.5), borderRadius: BorderRadius.circular(12)),
  //           child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('${_currentPageNotifier.value + 1}/${dataBanner?.length ?? 0}')]),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  _buildAreaItem({dynamic data}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(color: HexColor('#f4f4f4')),
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
            child: Text(
              data[0]['area'],
              style: AppStyle.bold.copyWith(fontSize: controllerGet.fontSizeObx.value),
            )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            direction: Axis.horizontal,
            children: List.generate(
                data.length,
                (index) => WidgetAnimationClickV2(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: Border.all(color: HexColor('#e5e5e5')),
                      borderRadius: BorderRadius.circular(5),
                      onTap: () {
                        switch (data[index]['id']) {
                          case 1:
                            Routings().navigate(
                                context,
                                StatusPointPage(
                                  account: dataUser,
                                  tabCount: 0,
                                ));
                            break;
                          case 2:
                            Routings().navigate(
                                context,
                                StatusPointPage(
                                  account: dataUser,
                                  tabCount: 1,
                                ));
                            break;
                          case 3:
                            Routings().navigate(context, const KeepAdverboxScreen());
                            break;
                          case 4:
                            Routings().navigate(context, const ScrapAdverBoxScreen());
                            break;
                          case 5:
                            Routings().navigate(context, const NotifiScreen());
                            break;
                          case 6:
                            Routings().navigate(context, const RequestScreen());
                            break;
                          case 7:
                            Routings().navigate(context, const AskedQuestionScreen());
                            break;
                          case 8:
                            Routings().navigate(context, const LinkAddvertisingScreen());
                            // Routing().navigate(
                            //     context,
                            //     ChargingStationScreen(
                            //       tab: 1,
                            //       dataAccount: dataUser,
                            //       callBack: (value) {
                            //         // _tabController.animateTo(0);
                            //       },
                            //     ));
                            break;
                          case 9:

                            // Routings().navigate(context, const SettingFontSizeScreen());
                            Routings().navigate(context, const InstructPage());

                            break;

                          case 10:
                            Routings().navigate(context, const UsingTermScreen());
                            break;
                          case 11:
                            Routings().navigate(context, const SettingScreen());
                            break;

                          default:
                        }
                      },
                      child: SizedBox(
                        width: (MediaQuery.of(context).size.width / 2 - 32 - 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                data[index]['subArea'],
                                maxLines: 2,
                                style: AppStyle.medium.copyWith(fontSize: controllerGet.fontSizeObx.value - 2),
                              ),
                            ),
                            Image.asset(
                              data[index]['urlImage'],
                              package: "eums",
                              height: 24,
                            )
                          ],
                        ),
                      ),
                    )),
          ),
        )
      ],
    );
  }
}

List listItemMy = [
  {"id": 1, "area": "포인트/광고 관련", "subArea": "포인트 적립 내역", "urlImage": Assets.icons.historyPoint.path},
  {"id": 2, "area": "포인트/광고 관련", "subArea": "포인트 전환", "urlImage": Assets.icons.pointConversion.path},
  {"id": 3, "area": "포인트/광고 관련", "subArea": "광고 보관함", "urlImage": Assets.icons.adarchive.path},
  {"id": 4, "area": "포인트/광고 관련", "subArea": "광고 스크랩", "urlImage": Assets.icons.adscrap.path},
  {"id": 5, "area": "기타", "subArea": "공지사항", "urlImage": Assets.icons.notifi.path},
  {"id": 6, "area": "기타", "subArea": "1:1 문의", "urlImage": Assets.icons.inquiry1.path},
  {"id": 7, "area": "기타", "subArea": "자주 묻는 질문", "urlImage": Assets.icons.frequentlyAQ.path},
  {"id": 8, "area": "서비스 이용 관련", "subArea": "제휴 및 광고 문의", "urlImage": Assets.icons.frequentluasq.path},
  {"id": 9, "area": "서비스 이용 관련", "subArea": "서비스 이용 안내", "urlImage": Assets.icons.serviceInfo.path},
  {"id": 10, "area": "서비스 이용 관련", "subArea": "이용약관", "urlImage": Assets.icons.termofuser.path},
  {"id": 11, "area": "서비스 이용 관련", "subArea": "설정", "urlImage": Assets.icons.setting.path}
];
