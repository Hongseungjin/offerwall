import 'dart:async';

import 'package:eums/eum_app_offer_wall/widget/widget_animation_click.dart';
import 'package:eums/eum_app_offer_wall/widget/widget_animation_click_v2.dart';
import 'package:eums/gen/style_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gif/flutter_gif.dart';
import 'package:get/instance_manager.dart';
import 'package:eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:eums/eum_app_offer_wall/utils/appStyle.dart';
import 'package:eums/eum_app_offer_wall/utils/hex_color.dart';
import 'package:eums/eum_app_offer_wall/widget/setting_fontsize.dart';
import 'package:eums/gen/assets.gen.dart';

import 'animation/widget_linear_timer.dart';
import 'images/widget_image_offer_wall.dart';

class CustomWebViewKeep extends StatefulWidget {
  final String urlLink;
  // final dynamic uriImage;
  final Widget? bookmark;
  final Widget? report;
  final Function()? mission;
  final String? title;
  const CustomWebViewKeep({
    Key? key,
    required this.urlLink,
    this.title,
    this.bookmark,
    this.mission,
    this.report,
  }) : super(key: key);

  @override
  State<CustomWebViewKeep> createState() => _CustomWebViewKeepState();
}

class _CustomWebViewKeepState extends State<CustomWebViewKeep> with WidgetsBindingObserver, TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  FlutterGifController? gifController;

  Timer? timer5s;
  ValueNotifier<bool> showButton = ValueNotifier(false);
  bool isRunning = true;
  final controllerGet = Get.put(SettingFontSize());
  late LinearTimerController timerController;

  final events = [];
  bool canScroll = true;
  @override
  void initState() {
    try {
      timerController = LinearTimerController(this);
      gifController = FlutterGifController(vsync: this);
      // ignore: empty_catches
    } catch (e) {}
    super.initState();

    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      gifController?.repeat(
        min: 0,
        max: 53,
        period: const Duration(milliseconds: 2000),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();

    _scrollController.dispose();
    timerController.dispose();
    timer5s?.cancel();
  }

  start5s() {
    timer5s?.cancel();
    timer5s = Timer.periodic(const Duration(seconds: 5), (_) {
      isRunning = false;
      timerController.stop();
    });
  }

  _scrollListener() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse ||
        _scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!isRunning) {
        isRunning = true;
        timerController.start();
      }
      start5s();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _eventBack();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColor.white,
          centerTitle: true,
          title: Text(widget.title ?? '', style: AppStyle.bold.copyWith(color: Colors.black, fontSize: 4 + controllerGet.fontSizeObx.value)),
          leading: InkWell(
            onTap: () {
              _eventBack();
            },
            child: const Icon(
              Icons.arrow_back,
              color: AppColor.black,
            ),
          ),
          actions: [widget.report ?? const SizedBox()],
        ),
        body: Column(
          children: [
            Expanded(
              child: WidgetImageOfferWall(
                scrollController: _scrollController,
                onScrollWebView: () {
                  if (!isRunning) {
                    isRunning = true;
                    timerController.start();
                  }
                  start5s();
                },
                urlLink: widget.urlLink,
                // urlLink: "https://m.daum.net/",
                // urlLink: "https://m.naver.com/",
                // urlLink: "https://m.coupang.com/nm/",
                onDone: () {
                  if (timerController.value == 0) {
                    timerController.start();
                    start5s();
                  }
                },
              ),
              // child: WidgetImageOfferWall(
              //   scrollController: _scrollController,
              //   urlLink: widget.urlLink ?? '',
              //   onDone: () {
              //     if (timerController.value == 0) {
              //       timerController.start();
              //       start5s();
              //     }
              //   },
              // ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10, bottom: MediaQuery.of(context).padding.bottom + 20),
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  widget.bookmark ?? const SizedBox(),
                  ValueListenableBuilder(
                    valueListenable: showButton,
                    builder: (context, value, child) {
                      return WidgetAnimationClickV2(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        borderRadius: BorderRadius.circular(4),
                        color: !showButton.value ? Colors.grey.shade300 : AppColor.red,
                        onTap: !showButton.value ? null : widget.mission,
                        child: Text(
                          '포인트 적립하기',
                          style: AppStyle.medium
                              .copyWith(fontSize: controllerGet.fontSizeObx.value, color: !showButton.value ? AppColor.black : AppColor.white),
                        ),
                      );
                    },
                  ),
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        height: 50,
                        width: 50,
                        child: WidgetLinearTimer(
                          color: AppColor.yellow,
                          backgroundColor: HexColor('#888888').withOpacity(0.3),
                          controller: timerController,
                          duration: const Duration(seconds: 15),
                          onTimerEnd: () {
                            showButton.value = true;
                            gifController?.stop();
                          },
                        ),
                      ),
                      Positioned(
                          right: 0,
                          left: 0,
                          top: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: GifImage(
                              height: 30,
                              width: 30,
                              fit: BoxFit.fill,
                              controller: gifController!,
                              image: AssetImage(
                                package: "eums",
                                // Assets.coingif.path,
                                Assets.icons.coinLoding.path,
                              ),
                            ),
                          ))
                    ],
                  ),
                  // Container(
                  //     padding: const EdgeInsets.all(10),
                  //     decoration: BoxDecoration(
                  //         color: AppColor.grey.withOpacity(0.5),
                  //         shape: BoxShape.circle),
                  //     child: Text(
                  //       _startTime.toString(),
                  //       style: AppStyle.medium.copyWith(fontSize: 16),
                  //     ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _eventBack() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          insetAnimationCurve: Curves.bounceIn,
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '광고 종료',
                        style: StyleFont.bold().copyWith(height: 1.3),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      child: Text(
                        '광고를 닫으시면 포인트가 적립되지 않습니다.\n실행 중인 광고를 종료하시겠습니까?',
                        style: StyleFont.regular().copyWith(height: 1.5, color: Colors.grey.shade600),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border(
                              top: BorderSide(color: Colors.grey.shade400),
                            )),
                            child: WidgetAnimationClickV2(
                              radius: 0,
                              borderRadius: BorderRadius.zero,
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                              child: Text(
                                "네",
                                textAlign: TextAlign.center,
                                style: StyleFont.bold(),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border(top: BorderSide(color: Colors.grey.shade400), left: BorderSide(color: Colors.grey.shade400))),
                            child: WidgetAnimationClickV2(
                              radius: 0,
                              borderRadius: BorderRadius.zero,
                              onTap: () {
                                Navigator.pop(context);
                              },
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                              child: Text(
                                "아니오",
                                textAlign: TextAlign.center,
                                style: StyleFont.medium(),
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
