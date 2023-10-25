import 'dart:async';

import 'package:eums/eum_app_offer_wall/widget/images/widget_image_offer_wall.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gif/flutter_gif.dart';
import 'package:get/instance_manager.dart';
import 'package:eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:eums/eum_app_offer_wall/utils/appStyle.dart';
import 'package:eums/eum_app_offer_wall/utils/hex_color.dart';
import 'package:eums/eum_app_offer_wall/widget/custom_circular.dart';
import 'package:eums/eum_app_offer_wall/widget/setting_fontsize.dart';
import 'package:eums/gen/assets.gen.dart';

class CustomWebViewKeep extends StatefulWidget {
  final dynamic urlLink;
  final dynamic uriImage;
  final Widget? bookmark;
  final Widget? report;
  final Function()? mission;
  final String? title;
  const CustomWebViewKeep({Key? key, this.urlLink, this.title, this.bookmark, this.mission, this.report, this.uriImage}) : super(key: key);

  @override
  State<CustomWebViewKeep> createState() => _CustomWebViewKeepState();
}

class _CustomWebViewKeepState extends State<CustomWebViewKeep> with WidgetsBindingObserver, TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  FlutterGifController? gifController;

  // Timer? _timer;
  // final int _startTime = 15;
  Timer? timer5s;
  ValueNotifier<bool> showButton = ValueNotifier(false);
  bool isRunning = true;
  final controllerGet = Get.put(SettingFontSize());
  late LinearTimerController timerController;

  final events = [];
  bool canScroll = true;

  // void startTimeDown() {
  //   _timer?.cancel();

  //   _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //     timerController.start();
  //     if (_startTime == 0) {
  //       _timer?.cancel();
  //     } else {
  //       setState(() {
  //         _startTime--;
  //       });
  //       if (_startTime == 0) {
  //         setState(() {
  //           showButton = true;
  //           gifController?.stop();
  //           _timer?.cancel();
  //         });
  //       }
  //     }
  //   });
  // }

  @override
  void initState() {
    try {
      timerController = LinearTimerController(this);
      gifController = FlutterGifController(vsync: this);

      // ignore: empty_catches
    } catch (e) {}
    // TODO: implement initState
    super.initState();
    // startTimeDown();
    // start5s();
    // gifController?.animateTo(52, duration: Duration(seconds: 1));
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // timerController.start();
      gifController?.repeat(
        min: 0,
        max: 53,
        period: const Duration(milliseconds: 2000),
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    timerController.dispose();
    timer5s?.cancel();
    // _timer?.cancel();
    super.dispose();
  }

  start5s() {
    timer5s?.cancel();
    timer5s = Timer.periodic(const Duration(seconds: 5), (_) {
      // _timer?.cancel();
      isRunning = false;
      timerController.stop();
      // setState(() {});
    });
  }

  _scrollListener() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse ||
        _scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!isRunning) {
        isRunning = true;
        timerController.start();
        // startTimeDown();
        // controller?.forward(from: _startTime.toDouble());
      }
      start5s();
    }
  }

  @override
  Widget build(BuildContext context) {
    // final imageCache = InteractiveViewer(
    //   minScale: 0.1,
    //   maxScale: 2.6,
    //   child: CachedNetworkImage(
    //       width: MediaQuery.of(context).size.width,
    //       fit: BoxFit.cover,
    //       imageUrl: widget.urlLink ?? '',
    //       placeholder: (context, url) => const Padding(
    //             padding: EdgeInsets.symmetric(vertical: 30),
    //             child: Center(
    //                 child: CircularProgressIndicator(
    //               color: Color(0xfffcc900),
    //             )),
    //           ),
    //       imageBuilder: (context, imageProvider) {
    //         if (timerController.value == 0) {
    //           timerController.start();
    //           start5s();
    //         }
    //         return Image(image: imageProvider);
    //       },
    //       errorWidget: (context, url, error) {
    //         return Image.asset(Assets.logo.path, package: "eums", height: 100);
    //       }),
    // );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.white,
        centerTitle: true,
        title: Text(widget.title ?? '', style: AppStyle.bold.copyWith(color: Colors.black, fontSize: 4 + controllerGet.fontSizeObx.value)),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
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
            child: NotificationListener(
                child: WidgetImageOfferWall(
              scrollController: _scrollController,
              urlLink: widget.urlLink ?? '',
              onDone: () {
                if (timerController.value == 0) {
                  timerController.start();
                  start5s();
                }
              },
            )),
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
                    return InkWell(
                      onTap: !showButton.value ? null : widget.mission,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        decoration:
                            BoxDecoration(borderRadius: BorderRadius.circular(4), color: !showButton.value ? HexColor('#cccccc') : AppColor.red),
                        child: Text(
                          '포인트 적립하기',
                          style: AppStyle.medium
                              .copyWith(fontSize: controllerGet.fontSizeObx.value, color: !showButton.value ? AppColor.grey : AppColor.white),
                        ),
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
                      child: LinearTimer(
                        color: AppColor.yellow,
                        backgroundColor: HexColor('#888888').withOpacity(0.3),
                        controller: timerController,
                        duration: const Duration(seconds: 15),
                        onTimerEnd: () {
                          showButton.value = true;
                          // gifController?.stop();
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
                              Assets.coingif.path,
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
    );
  }
}
