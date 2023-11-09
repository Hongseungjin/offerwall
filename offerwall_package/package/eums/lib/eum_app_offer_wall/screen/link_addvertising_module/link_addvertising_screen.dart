import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:eums/eum_app_offer_wall/utils/appStyle.dart';
import 'package:eums/eum_app_offer_wall/utils/hex_color.dart';
import 'package:eums/eum_app_offer_wall/widget/custom_animation_click.dart';
import 'package:eums/eum_app_offer_wall/widget/setting_fontsize.dart';
import 'package:eums/gen/assets.gen.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkAddvertisingScreen extends StatefulWidget {
  const LinkAddvertisingScreen({Key? key}) : super(key: key);

  @override
  State<LinkAddvertisingScreen> createState() => _LinkAddvertisingScreenState();
}

class _LinkAddvertisingScreenState extends State<LinkAddvertisingScreen> {
  final controllerGet = Get.put(SettingFontSize());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        backgroundColor: AppColor.white,
        elevation: 1,
        centerTitle: true,
        title: Text('제휴 및 광고 문의', style: AppStyle.bold.copyWith(fontSize: 2 + controllerGet.fontSizeObx.value, color: AppColor.black)),
        leading: InkWell(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(Icons.arrow_back_ios_outlined, color: AppColor.dark, size: 25),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  // Image.asset(
                  //   Assets.text.path,
                  //   package: "eums",
                  // ),
                  //  Image.asset(
                  //   Assets.watch_point.path,
                  //   package: "eums",
                  // ),
                  Assets.icons.text.image(),
                  Assets.icons.watchPoint.image(),

                  // Center(
                  //   child: Text(
                  //     '제휴 및 광고 문의',
                  //     style:
                  //         AppStyle.bold.copyWith(color: AppColor.black, fontSize: 32),
                  //   ),
                  // ),
                  const SizedBox(height: 12),
                  // Image.asset(
                  //   Assets.note_text.path,
                  //   package: "eums",
                  // ),
                  Assets.icons.noteText.image(),
                  // Center(
                  //   child: RichText(
                  //       textAlign: TextAlign.center,
                  //       text: TextSpan(
                  //           text: '포인트',
                  //           style: AppStyle.medium
                  //               .copyWith(color: AppColor.red, fontSize: 16),
                  //           children: [
                  //             TextSpan(
                  //               text: '광고주는 를 쌓고광고주는 ',
                  //               style: AppStyle.medium
                  //                   .copyWith(color: AppColor.black, fontSize: 16),
                  //             )
                  //           ])),
                  // ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(color: HexColor('#fdd000').withOpacity(.2), borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        _buidItem(
                            callback: () {},
                            title: '고객센터',
                            widget: SizedBox(
                              width: MediaQuery.of(context).size.width - 150,
                              child: Text(
                                '1833-8590 / abee@abee.co.kr',
                                style: AppStyle.bold.copyWith(color: AppColor.black, fontSize: controllerGet.fontSizeObx.value - 2),
                              ),
                            )),
                        _buidItem(
                            callback: () {},
                            title: '업무시간',
                            widget: SizedBox(
                              width: MediaQuery.of(context).size.width - 150,
                              child: RichText(
                                  text: TextSpan(
                                      text: '09:00 ~ 18:00',
                                      style: AppStyle.bold.copyWith(color: AppColor.black, fontSize: controllerGet.fontSizeObx.value - 2),
                                      children: [
                                    TextSpan(
                                      text: '(점심시간 : 12:00 ~ 13:00)',
                                      style: AppStyle.bold.copyWith(color: AppColor.grey5D, fontSize: controllerGet.fontSizeObx.value - 2),
                                    )
                                  ])),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: WidgetAnimationClick(
              onTap: () {
                _launchURL();
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColor.yellow),
                child: Text(
                  '제휴 및 광고 문의하기',
                  style: AppStyle.bold.copyWith(color: AppColor.black, fontSize: 2 + controllerGet.fontSizeObx.value),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _launchURL() async {
    String? encodeQueryParameters(Map<String, String> params) {
      return params.entries.map((MapEntry<String, String> e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
    }

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'abee@abee.co.kr',
      query: encodeQueryParameters(<String, String>{
        'subject': '제휴 및 광고 문의!',
      }),
    );

    launchUrl(emailLaunchUri);

    // var url = 'mailto:$toMailId?subject=$subject&body=$body';
    // if (await canLaunch(url)) {
    //   await launch(url);
    // } else {
    //   throw 'Could not launch $url';
    // }
  }

  Widget _buidItem({required VoidCallback callback, String? title, Widget? widget}) {
    return InkWell(
      onTap: callback,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        // decoration: BoxDecoration(
        //     color: AppColor.colorF13, borderRadius: BorderRadius.circular(40)),
        child: Row(
          children: [
            Text(
              title ?? '',
              style: AppStyle.bold.copyWith(color: AppColor.black, fontSize: controllerGet.fontSizeObx.value),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              height: 20,
              color: AppColor.colorC9,
              width: 2,
            ),
            widget ?? const SizedBox()
          ],
        ),
      ),
    );
  }
}
