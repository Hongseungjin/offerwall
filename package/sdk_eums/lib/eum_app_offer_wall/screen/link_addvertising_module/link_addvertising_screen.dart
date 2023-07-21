import 'package:flutter/material.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appStyle.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/app_string.dart';
import 'package:sdk_eums/gen/assets.gen.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkAddvertisingScreen extends StatefulWidget {
  const LinkAddvertisingScreen({Key? key}) : super(key: key);

  @override
  State<LinkAddvertisingScreen> createState() => _LinkAddvertisingScreenState();
}

class _LinkAddvertisingScreenState extends State<LinkAddvertisingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        backgroundColor: AppColor.white,
        elevation: 1,
        centerTitle: true,
        title: Text(AppString.linkAddvertising,
            style: AppStyle.bold.copyWith(fontSize: 16, color: AppColor.black)),
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(Icons.arrow_back_ios_outlined,
              color: AppColor.dark, size: 25),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Center(
              child: Text(
                '제휴 및 광고 문의',
                style:
                    AppStyle.bold.copyWith(color: AppColor.black, fontSize: 32),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      text: '포인트',
                      style: AppStyle.medium
                          .copyWith(color: AppColor.red, fontSize: 16),
                      children: [
                        TextSpan(
                          text: '광고주는 를 쌓고광고주는 ',
                          style: AppStyle.medium
                              .copyWith(color: AppColor.black, fontSize: 16),
                        )
                      ])),
            ),
            const SizedBox(height: 32),
            _buidItem(
                callback: () {},
                title: '고객센터',
                widget: Text(
                  '1833-8590 / abee@abee.co.kr',
                  style: AppStyle.bold
                      .copyWith(color: AppColor.black, fontSize: 12),
                )),
            const SizedBox(height: 16),
            _buidItem(
                callback: () {},
                title: '업무시간',
                widget: RichText(
                    text: TextSpan(
                        text: '09:00 ~ 18:00',
                        style: AppStyle.bold
                            .copyWith(color: AppColor.black, fontSize: 12),
                        children: [
                      TextSpan(
                        text: '(점심시간 : 12:00 ~ 13:00)',
                        style: AppStyle.bold
                            .copyWith(color: AppColor.grey5D, fontSize: 10),
                      )
                    ]))),
            const SizedBox(height: 16),
            Center(
                child: Image.asset(Assets.linkAdvertising.path,
                    package: "sdk_eums",
                    height: MediaQuery.of(context).size.width / 1.5,
                    width: MediaQuery.of(context).size.width)),
            Spacer(),
            GestureDetector(
              onTap: () {
                _launchURL();
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColor.yellow),
                child: Text(
                  '제휴 및 광고 문의하기',
                  style: AppStyle.bold
                      .copyWith(color: AppColor.black, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _launchURL() async {
    String? encodeQueryParameters(Map<String, String> params) {
      return params.entries
          .map((MapEntry<String, String> e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
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

  Widget _buidItem(
      {required VoidCallback callback, String? title, Widget? widget}) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
            color: AppColor.colorF13, borderRadius: BorderRadius.circular(40)),
        child: Row(
          children: [
            Text(
              title ?? '',
              style:
                  AppStyle.bold.copyWith(color: AppColor.black, fontSize: 14),
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
