import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:sdk_eums/gen/assets.gen.dart';
import 'package:sdk_eums/method_sdk/sdk_eums_platform_interface.dart';

import '../../utils/appStyle.dart';
import '../../utils/app_string.dart';

class ChargingStationScreen extends StatefulWidget {
  ChargingStationScreen(
      {Key? key, required this.tab, required this.callBack, this.dataAccount})
      : super(key: key);
  final int tab;
  dynamic dataAccount;
  Function(dynamic value) callBack;

  @override
  State<ChargingStationScreen> createState() => _ChargingStationScreenState();
}

class _ChargingStationScreenState extends State<ChargingStationScreen> {
  FToast fToast = FToast();
  @override
  void initState() {
    
    fToast.init(context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {}
  }

  @override
  Widget build(BuildContext context) {
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
          title: Text(AppString.chargingStation,
              style:
                  AppStyle.bold.copyWith(fontSize: 16, color: AppColor.black)),
          leading: GestureDetector(
            onTap: () {
              widget.callBack(widget.tab);
              // Routing().popToRoot(context);
              //  Routing().popToRoot(context);
              Navigator.of(context).pop();
              // RxBus.post(
              //   BackToTab(tab: widget.tab),
              // );
            },
            child: const Icon(Icons.arrow_back_ios_outlined,
                color: AppColor.dark, size: 25),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  Assets.bannerStation.path,
                  package: "sdk_eums",
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  direction: Axis.horizontal,
                  children: [
                    _buildItem(
                        voidCallBack: () {
                          SdkEumsPlatform.instance
                              .methodAdsync(data: widget.dataAccount['memId']);
                        },
                        title: '애드싱크',
                        urlImage: Assets.adSync.path),
                    _buildItem(
                        voidCallBack: () {
                     
                          SdkEumsPlatform.instance.methodAdpopcorn(
                              data: widget.dataAccount['memId']);
                        },
                        title: '애드팝콘',
                        urlImage: Assets.adpopcorn.path),
                    _buildItem(
                        voidCallBack: () {
                          SdkEumsPlatform.instance
                              .methodMafin(data: widget.dataAccount['memId']);
                        },
                        title: 'NAS',
                        urlImage: Assets.mafin.path),
                    _buildItem(
                        voidCallBack: () {
                          SdkEumsPlatform.instance
                              .methodTnk(data: widget.dataAccount['memId']);
                        },
                        title: 'THK',
                        urlImage: Assets.tnk.path),
                    // _buildItem(
                    //     voidCallBack: () {
                    //       SdkEumsPlatform.instance.methodOHC();
                    //     },
                    //     title: 'OHC',
                    //     urlImage: Assets.ohc.path),
                    _buildItem(
                        voidCallBack: () {
                          SdkEumsPlatform.instance.methodIvekorea(
                              data: widget.dataAccount['memId']);
                        },
                        title: '아이브코리아',
                        urlImage: Assets.mekorea.path),
                    _buildItem(
                        voidCallBack: () {
                          SdkEumsPlatform.instance
                              .methodAppall(data: widget.dataAccount['memId']);
                        },
                        title: '앱올',
                        urlImage: Assets.appall.path),
                    // _buildItem(
                    //     voidCallBack: () {},
                    //     title: 'GPA',
                    //     urlImage: Assets.GPAKorea.path),
                  ],
                ),
                const SizedBox(height: 16),
                _buildNote(
                    title: '※ 미적립건은,',
                    title1: '각 송전소 내부에 있는 문의하기',
                    title2: '를 이용해주세요.'),
                const SizedBox(height: 8),
                _buildNote(
                    title: '※ 이미 참여한 광고는', title1: '중복참여가 불가', title2: '합니다.'),
                const SizedBox(height: 8),
                _buildNote(
                    title: '※ 추가로',
                    title1: '문의가 필요할 경우 더보기> 내문의내역(1:1문의 게시판)을 이용',
                    title2: '해주세요.')
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildItem({String? urlImage, String? title, Function()? voidCallBack}) {
    return GestureDetector(
      onTap: voidCallBack,
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.white,
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
        width: (MediaQuery.of(context).size.width - 50) / 2,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  urlImage ?? '',
                  package: "sdk_eums",
                  height: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  '$title',
                  style: AppStyle.medium.copyWith(fontSize: 12),
                )
              ],
            ),
            const Spacer(),
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
        text: TextSpan(
            text: title,
            style:
                AppStyle.regular.copyWith(color: AppColor.grey1, fontSize: 14),
            children: [
          TextSpan(
            text: title1,
            style:
                AppStyle.regular.copyWith(color: AppColor.red6, fontSize: 14),
          ),
          TextSpan(
            text: title2,
            style:
                AppStyle.regular.copyWith(color: AppColor.grey1, fontSize: 14),
          )
        ]));
  }
}
