import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sdk_eums/common/constants.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appStyle.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/hex_color.dart';
import 'package:sdk_eums/gen/assets.gen.dart';

import '../utils/appColor.dart';

class DialogUtils {
  static void showDialogGetPoint(
    BuildContext context, {
    dynamic data,
    dynamic voidCallback,
  }) {
    showDialog(
        context: context,
        builder: (buildContext) {
          ///TODO: handle test
          // Future.delayed(Duration(seconds: 1), () {
          //   Navigator.of(buildContext).pop(true);
          // });
          return Dialog(
            insetPadding: const EdgeInsets.all(0),
            insetAnimationCurve: Curves.bounceIn,
            backgroundColor: Colors.black54,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Navigator.of(buildContext).pop(true);
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(8)),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            Assets.get_point.path,
                            package: "sdk_eums",
                            height: 200,
                            width: 200,
                          ),
                          const SizedBox(height: 40),
                          Text(
                            '지금 획득 가능한 포인트',
                            style: AppStyle.medium.copyWith(fontSize: 18, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                Constants.formatMoney(data != null ? data['totalPointCanGet'] : 0, suffix: ''),
                                style: AppStyle.bold.copyWith(color: HexColor('#fdd000'), fontSize: 40),
                              ),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: HexColor('#fdd000'),
                                ),
                                child: Text(
                                  'P',
                                  style: AppStyle.bold.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        });
  }

  static void showDialogMissingPoint(
    BuildContext context, {
    dynamic data,
    dynamic voidCallback,
  }) {
    showDialog(
        context: context,
        builder: (buildContext) {
          return Dialog(
            insetPadding: const EdgeInsets.all(0),
            insetAnimationCurve: Curves.bounceIn,
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(8)),
                  child: Stack(
                    children: [
                      Center(
                        child: Text('+ $data캐시', style: AppStyle.bold.copyWith(color: AppColor.orange4, fontSize: 24)),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(buildContext);
                            if (voidCallback != null) {
                              voidCallback();
                            }
                          },
                          child: const Icon(Icons.close, color: AppColor.white, size: 24),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        });
  }

  static void showDialogRewardPoint(BuildContext context, {dynamic data, dynamic voidCallback, bool checkImage = false, dynamic point}) {
    dynamic reward;

    switch (checkImage ? point : data['typePoint']) {
      case 'POINT_8':
        reward = 5;
        break;
      case 'POINT_16':
        reward = 10;
        break;
      case 'POINT_32':
        reward = 20;
        break;
      case 'POINT_80':
        reward = 50;
        break;
      case 'POINT_160':
        reward = 100;
        break;

      default:
        break;
    }

    showDialog(
        context: context,
        builder: (buildContext) {
          return Dialog(
            insetPadding: const EdgeInsets.all(16),
            insetAnimationCurve: Curves.bounceIn,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 16),
                        Image.asset(
                          Assets.point_dialog.path,
                          package: "sdk_eums",
                          height: 177,
                        ),
                        // Text('$reward포인트',
                        //     style: AppStyle.medium.copyWith(
                        //         fontSize: 20, color: HexColor('#f4a43b'))),
                        RichText(
                            text: TextSpan(
                                text: '$reward포인트',
                                style: AppStyle.medium.copyWith(fontSize: 20, color: HexColor('#f4a43b')),
                                children: [TextSpan(text: '가', style: AppStyle.medium.copyWith(color: AppColor.black, fontSize: 20))])),
                        Text('적립되었습니다!', style: AppStyle.medium.copyWith(color: AppColor.black, fontSize: 20)),
                        // Center(
                        //   child: RichText(
                        //       text: TextSpan(
                        //           text: '$reward포인트',
                        //           style: AppStyle.medium
                        //               .copyWith(color: HexColor('#f4a43b')),
                        //           children: [
                        //         TextSpan(
                        //             text: '\n가적립되었어요!',
                        //             style: AppStyle.medium
                        //                 .copyWith(color: AppColor.black))
                        //       ])),
                        // ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () {
                            Navigator.pop(buildContext);

                            if (voidCallback != null) {
                              voidCallback();
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColor.yellow,
                            ),
                            child: Text(
                              '확인',
                              style: AppStyle.medium.copyWith(color: AppColor.black),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        });
  }

  static void showDialogSucessPoint(BuildContext context, {dynamic data, dynamic voidCallback, bool checkImage = false, dynamic point}) {
    dynamic reward;

    switch (checkImage ? point : data['typePoint']) {
      case 'POINT_8':
        reward = 5;
        break;
      case 'POINT_16':
        reward = 10;
        break;
      case 'POINT_32':
        reward = 20;
        break;
      case 'POINT_80':
        reward = 50;
        break;
      case 'POINT_160':
        reward = 100;
        break;

      default:
        break;
    }
    showDialog(
        context: context,
        builder: (buildContext) {
          return Dialog(
            insetPadding: const EdgeInsets.all(16),
            insetAnimationCurve: Curves.bounceIn,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              Assets.fireworkLeft.path,
                              package: "sdk_eums",
                              height: 40,
                            ),
                            const SizedBox(width: 10),
                            RichText(
                                text: TextSpan(
                                    text: '$reward포인트',
                                    style: AppStyle.medium.copyWith(color: AppColor.red5),
                                    children: [TextSpan(text: ' 정상 적립 !', style: AppStyle.medium.copyWith(color: AppColor.black))])),
                            const SizedBox(width: 10),
                            Image.asset(
                              Assets.fireworkRight.path,
                              package: "sdk_eums",
                              height: 40,
                            )
                          ],
                        ),
                        const SizedBox(height: 16),
                        CachedNetworkImage(
                            width: MediaQuery.of(context).size.width,
                            height: 300,
                            fit: BoxFit.fill,
                            imageUrl: "${Constants.baseUrlImage}${!checkImage ? data['advertiseSponsor']['sponser_image'] : data['sponser_image']}",
                            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) {
                              return Image.asset(
                                Assets.logo.path,
                                package: "sdk_eums",
                                height: 200,
                              );
                              // Assets.icons.logo.image(height: 200);
                            }),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              // borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.fitWidth,
                                  imageUrl:
                                      "${Constants.baseUrlImage}${!checkImage ? data['advertiseSponsor']['sponser_company_image'] : data['sponser_company_image']}",
                                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) {
                                    return Image.asset(
                                      Assets.logo.path,
                                      package: "sdk_eums",
                                      height: 50,
                                    );
                                    // Assets.icons.logo.image(height: 200);
                                  }),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '중소상공인의 광고를 후원해 주셨습니다.',
                              style: AppStyle.medium.copyWith(color: AppColor.black),
                            ),
                          ],
                        ),
                        CachedNetworkImage(
                            width: MediaQuery.of(context).size.width,
                            height: 70,
                            fit: BoxFit.fill,
                            imageUrl: "${Constants.baseUrlImage}${!checkImage ? data['advertiseSponsor']['image'] : data['image']}",
                            // Constants.baseUrlImage +
                            //     data['advertiseSponsor']['sponser_image'],
                            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) {
                              return Image.asset(
                                Assets.logo.path,
                                package: "sdk_eums",
                                height: 200,
                              );
                              // Assets.icons.logo.image(height: 200);
                            }),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () {
                            Navigator.pop(buildContext);

                            if (voidCallback != null) {
                              voidCallback();
                            }
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColor.yellow,
                            ),
                            child: Text(
                              '확인',
                              style: AppStyle.medium.copyWith(color: AppColor.black),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        });
  }

  static void showDialogSucessPointAndroid(BuildContext context, {dynamic data, VoidCallback? voidCallback, bool checkImage = false, dynamic point}) {
    dynamic reward;

    switch (checkImage ? point : data['typePoint']) {
      case 'POINT_8':
        reward = 5;
        break;
      case 'POINT_16':
        reward = 10;
        break;
      case 'POINT_32':
        reward = 20;
        break;
      case 'POINT_80':
        reward = 50;
        break;
      case 'POINT_160':
        reward = 100;
        break;

      default:
        break;
    }
    showDialog(
        context: context,
        builder: (buildContext) {
          return Dialog(
            insetPadding: const EdgeInsets.all(16),
            insetAnimationCurve: Curves.bounceIn,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              Assets.fireworkLeft.path,
                              package: "sdk_eums",
                              height: 40,
                            ),
                            const SizedBox(width: 10),
                            RichText(
                                text: TextSpan(
                                    text: '$reward포인트',
                                    style: AppStyle.medium.copyWith(color: AppColor.red5),
                                    children: [TextSpan(text: ' 정상 적립 !', style: AppStyle.medium.copyWith(color: AppColor.black))])),
                            const SizedBox(width: 10),
                            Image.asset(
                              Assets.fireworkRight.path,
                              package: "sdk_eums",
                              height: 40,
                            )
                          ],
                        ),
                        const SizedBox(height: 16),
                        CachedNetworkImage(
                            width: MediaQuery.of(context).size.width,
                            height: 300,
                            fit: BoxFit.cover,
                            imageUrl: "${Constants.baseUrlImage}${!checkImage ? data['advertiseSponsor']['sponser_image'] : data['sponser_image']}",
                            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) {
                              return Image.asset(
                                Assets.logo.path,
                                package: "sdk_eums",
                                height: 200,
                              );
                              // Assets.icons.logo.image(height: 200);
                            }),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  imageUrl:
                                      "${Constants.baseUrlImage}${!checkImage ? data['advertiseSponsor']['sponser_company_image'] : data['sponser_company_image']}",
                                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) {
                                    return Image.asset(
                                      Assets.logo.path,
                                      package: "sdk_eums",
                                      height: 50,
                                    );
                                    // Assets.icons.logo.image(height: 200);
                                  }),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '중소상공인의 광고를 후원해 주셨습니다.',
                              style: AppStyle.medium.copyWith(color: AppColor.black),
                            ),
                          ],
                        ),
                        CachedNetworkImage(
                            width: MediaQuery.of(context).size.width,
                            height: 70,
                            fit: BoxFit.cover,
                            imageUrl: "${Constants.baseUrlImage}${!checkImage ? data['advertiseSponsor']['image'] : data['image']}",
                            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) {
                              return Image.asset(
                                Assets.logo.path,
                                package: "sdk_eums",
                                height: 200,
                              );
                            }),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: voidCallback,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColor.yellow,
                            ),
                            child: Text(
                              '확인',
                              style: AppStyle.medium.copyWith(color: AppColor.black),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        });
  }
}
