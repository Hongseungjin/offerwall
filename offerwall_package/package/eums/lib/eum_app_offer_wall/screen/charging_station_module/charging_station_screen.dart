import 'package:eums/eum_app_offer_wall/lifecycale_event_handle.dart';
import 'package:eums/eum_app_offer_wall/utils/loading_dialog.dart';
import 'package:eums/eum_app_offer_wall/widget/widget_animation_click_v2.dart';
import 'package:flutter/material.dart';
import 'package:eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:eums/gen/assets.gen.dart';
import 'package:sdk_eums/method_sdk/sdk_eums_platform_interface.dart';
import 'package:flutter_component/flutter_component.dart';

import '../../utils/appStyle.dart';
import '../../utils/app_string.dart';

class ChargingStationScreen extends StatefulWidget {
  ChargingStationScreen({Key? key, required this.tab, required this.callBack, this.dataAccount}) : super(key: key);
  final int tab;
  dynamic dataAccount;
  Function(dynamic value) callBack;

  @override
  State<ChargingStationScreen> createState() => _ChargingStationScreenState();
}

class _ChargingStationScreenState extends State<ChargingStationScreen> {
  @override
  void initState() {
    SdkEumsPlatform.instance.methodUser(data: widget.dataAccount['memId']);

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {});
    WidgetsBinding.instance.addObserver(LifecycleEventHandler(
      resumeCallBack: () async {
        LoadingDialog.instance.hide();
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> listData = [
      _buildItem(
          voidCallBack: () async {
            try {
              LoadingDialog.instance.show();
              await SdkEumsPlatform.instance.methodAdsync(data: widget.dataAccount['memId']);
              await Future.delayed(const Duration(seconds: 1));
              LoadingDialog.instance.hide();
            } catch (e) {
              LoadingDialog.instance.hide();
            }
          },
          title: '애드싱크',
          urlImage: Assets.icons.adSync.path),
      _buildItem(
          voidCallBack: () async {
            try {
              LoadingDialog.instance.show();
              await SdkEumsPlatform.instance.methodAdpopcorn(data: widget.dataAccount['memId']);
              LoadingDialog.instance.hide();
            } catch (e) {
              LoadingDialog.instance.hide();
            }
          },
          title: '애드팝콘',
          urlImage: Assets.icons.adpopcorn.path),
      _buildItem(
          voidCallBack: () async {
            try {
              LoadingDialog.instance.show();
              Future.delayed(
                const Duration(seconds: 3),
                () {
                  LoadingDialog.instance.hide();
                },
              );
              await SdkEumsPlatform.instance.methodMafin(data: widget.dataAccount['memId']);
              LoadingDialog.instance.hide();
            } catch (e) {
              LoadingDialog.instance.hide();
            }
          },
          title: 'NAS',
          urlImage: Assets.icons.mafin.path),
      _buildItem(
          voidCallBack: () async {
            try {
              LoadingDialog.instance.show();
              await SdkEumsPlatform.instance.methodTnk(data: widget.dataAccount['memId']);
              await Future.delayed(const Duration(seconds: 1));
              LoadingDialog.instance.hide();
            } catch (e) {
              LoadingDialog.instance.hide();
            }
          },
          title: 'TNK',
          urlImage: Assets.icons.tnk.path),
      // _buildItem(
      //     voidCallBack: () {
      //       SdkEumsPlatform.instance.methodOHC();
      //     },
      //     title: 'OHC',
      //     urlImage: Assets.ohc.path),
      _buildItem(
          voidCallBack: () async {
            try {
              LoadingDialog.instance.show();

              await SdkEumsPlatform.instance.methodIvekorea(data: widget.dataAccount['memId']);
              LoadingDialog.instance.hide();
            } catch (e) {
              LoadingDialog.instance.hide();
            }
          },
          title: '아이브코리아',
          urlImage: Assets.icons.mekorea.path),
      _buildItem(
          voidCallBack: () async {
            try {
              LoadingDialog.instance.show();
              Future.delayed(
                const Duration(seconds: 3),
                () {
                  LoadingDialog.instance.hide();
                },
              );
              await SdkEumsPlatform.instance.methodAppall(data: widget.dataAccount['memId']);
              LoadingDialog.instance.hide();
            } catch (e) {
              LoadingDialog.instance.hide();
            }
          },
          title: '앱올',
          urlImage: Assets.icons.appall.path),
      // _buildItem(
      //     voidCallBack: () {},
      //     title: 'GPA',
      //     urlImage: Assets.GPAKorea.path),
    ];

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        widget.callBack(widget.tab);
        // RxBus.post(
        //   BackToTab(tab: widget.tab),
        // );
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColor.white,
        appBar: AppBar(
          backgroundColor: AppColor.white,
          elevation: 1,
          centerTitle: true,
          title: Text(AppString.chargingStation, style: AppStyle.bold.copyWith(fontSize: 16, color: AppColor.black)),
          leading: InkWell(
            onTap: () {
              widget.callBack(widget.tab);

              Navigator.of(context).pop();
            },
            child: const Icon(Icons.arrow_back_ios_outlined, color: AppColor.dark, size: 25),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  // Assets.bannerStation.path,
                  Assets.icons.bannerStation.path,
                  package: "eums",
                ),
                const SizedBox(height: 16),

                ...ListComponent.instant.buildBodyWrap<Widget>(
                  context: context,
                  vertical: 10,
                  horizontal: 10,
                  countRow: 2,
                  data: listData,
                  buildItem: (index) {
                    return listData[index];
                  },
                ),

                // Wrap(
                //   spacing: 12,
                //   runSpacing: 12,
                //   direction: Axis.horizontal,
                //   children: [
                //     _buildItem(
                //         voidCallBack: () {
                //           SdkEumsPlatform.instance.methodAdsync(data: widget.dataAccount['memId']);
                //         },
                //         title: '애드싱크',
                //         urlImage: Assets.icons.adSync.path),
                //     _buildItem(
                //         voidCallBack: () {
                //           SdkEumsPlatform.instance.methodAdpopcorn(data: widget.dataAccount['memId']);
                //         },
                //         title: '애드팝콘',
                //         urlImage: Assets.icons.adpopcorn.path),
                //     _buildItem(
                //         voidCallBack: () {
                //           SdkEumsPlatform.instance.methodMafin(data: widget.dataAccount['memId']);
                //         },
                //         title: 'NAS',
                //         urlImage: Assets.icons.mafin.path),
                //     _buildItem(
                //         voidCallBack: () {
                //           SdkEumsPlatform.instance.methodTnk(data: widget.dataAccount['memId']);
                //         },
                //         title: 'TNK',
                //         urlImage: Assets.icons.tnk.path),
                //     // _buildItem(
                //     //     voidCallBack: () {
                //     //       SdkEumsPlatform.instance.methodOHC();
                //     //     },
                //     //     title: 'OHC',
                //     //     urlImage: Assets.ohc.path),
                //     _buildItem(
                //         voidCallBack: () {
                //           SdkEumsPlatform.instance.methodIvekorea(data: widget.dataAccount['memId']);
                //         },
                //         title: '아이브코리아',
                //         urlImage: Assets.icons.mekorea.path),
                //     _buildItem(
                //         voidCallBack: () {
                //           SdkEumsPlatform.instance.methodAppall(data: widget.dataAccount['memId']);
                //         },
                //         title: '앱올',
                //         urlImage: Assets.icons.appall.path),
                //     // _buildItem(
                //     //     voidCallBack: () {},
                //     //     title: 'GPA',
                //     //     urlImage: Assets.GPAKorea.path),
                //   ],
                // ),
                const SizedBox(height: 16),
                _buildNote(title: '※ 미적립건은,', title1: '각 송전소 내부에 있는 문의하기', title2: '를 이용해주세요.'),
                const SizedBox(height: 8),
                _buildNote(title: '※ 이미 참여한 광고는', title1: '중복참여가 불가', title2: '합니다.'),
                const SizedBox(height: 8),
                _buildNote(title: '※ 추가로', title1: '문의가 필요할 경우 더보기> 내문의내역(1:1문의 게시판)을 이용', title2: '해주세요.')
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem({String? urlImage, String? title, Function()? voidCallBack}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: WidgetAnimationClickV2(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        onTap: voidCallBack,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    urlImage ?? '',
                    package: "eums",
                    height: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$title',
                    style: AppStyle.medium.copyWith(fontSize: 12),
                  )
                ],
              ),
            ),
            // const Spacer(),
            const Icon(
              Icons.arrow_forward_ios_outlined,
              size: 16,
            )
          ],
        ),
      ),
    );
  }

  _buildNote({String? title, String? title1, String? title2}) {
    return RichText(
        text: TextSpan(text: title, style: AppStyle.regular.copyWith(color: AppColor.grey1, fontSize: 14), children: [
      TextSpan(
        text: title1,
        style: AppStyle.regular.copyWith(color: AppColor.red6, fontSize: 14),
      ),
      TextSpan(
        text: title2,
        style: AppStyle.regular.copyWith(color: AppColor.grey1, fontSize: 14),
      )
    ]));
  }
}
