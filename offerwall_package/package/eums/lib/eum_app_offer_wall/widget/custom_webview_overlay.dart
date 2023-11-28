import 'dart:async';

import 'package:eums/eum_app_offer_wall/widget/images/widget_image_offer_wall.dart';
import 'package:eums/eum_app_offer_wall/widget/widget_animation_click_v2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gif/flutter_gif.dart';
import 'package:eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:eums/eum_app_offer_wall/utils/hex_color.dart';
import 'package:eums/gen/assets.gen.dart';
import '../utils/appStyle.dart';
import 'animation/widget_linear_timer.dart';

class CustomWebViewOverlay extends StatefulWidget {
  final dynamic urlLink;
  final dynamic title;
  final Function()? onSave;
  final Function()? mission;
  final Function onClose;
  // final bool showMission;
  final Color color;
  final Color colorIconBack;
  final Widget? actions;
  final Widget? bookmark;
  final bool showImage;
  // final double deviceWidth;
  final double paddingTop;
  const CustomWebViewOverlay(
      {Key? key,
      this.urlLink,
      this.title,
      this.onSave,
      this.mission,
      required this.onClose,
      // this.showMission = false,
      this.colorIconBack = AppColor.black,
      this.color = AppColor.white,
      this.actions,
      this.bookmark,
      // this.deviceWidth = 0,
      this.paddingTop = 100,
      this.showImage = false})
      : super(key: key);

  @override
  State<CustomWebViewOverlay> createState() => _CustomWebViewOverlayState();
}

class _CustomWebViewOverlayState extends State<CustomWebViewOverlay> with WidgetsBindingObserver, TickerProviderStateMixin {
  // late WebViewController _controller;
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();
  FlutterGifController? gifController;
  late LinearTimerController timerController;

  // Timer? _timeDown;
  // int _startTime = 15;
  Timer? timer5s;
  ValueNotifier<bool> showButton = ValueNotifier(false);
  bool isRunning = true;

  String getProperHtml(String content) {
    String start1 = 'https:';
    int startIndex1 = content.indexOf(start1);
    String iframeTag1 = content.substring(startIndex1 + 6);
    content = iframeTag1.replaceAll(iframeTag1, "http:$iframeTag1");
    return content;
  }

  // void startTimeDown() {
  //   _timeDown?.cancel();
  //   _timeDown = Timer.periodic(const Duration(seconds: 1), (timer) {
  //     timerController.start();
  //     if (_startTime == 0) {
  //       _timeDown?.cancel();
  //     } else {
  //       setState(() {
  //         _startTime--;
  //       });
  //       if (_startTime == 0) {
  //         showButton.value = true;
  //         gifController?.stop();
  //         _timeDown?.cancel();
  //       }
  //     }
  //   });
  // }

  start5s() {
    timer5s?.cancel();
    timer5s = Timer.periodic(const Duration(seconds: 5), (_) {
      // _timeDown?.cancel();
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
      }
      start5s();
    }
  }

  @override
  void initState() {
    try {
      timerController = LinearTimerController(this);
      gifController = FlutterGifController(vsync: this);
    } catch (e) {
      rethrow;
    }
    // TODO: implement initState
    // if (widget.showMission) {
    //   // startTimeDown();
    //   // start5s();
    // }

    super.initState();
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // timerController.start();
      gifController?.repeat(
        min: 0,
        max: 53,
        period: const Duration(milliseconds: 2000),
      );
    });

    // late final PlatformWebViewControllerCreationParams params;
    // if (WebViewPlatform.instance is WebKitWebViewPlatform) {
    //   params = WebKitWebViewControllerCreationParams(
    //     allowsInlineMediaPlayback: true,
    //     mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
    //   );
    // } else {
    //   params = const PlatformWebViewControllerCreationParams();
    // }

    // final WebViewController controller = WebViewController.fromPlatformCreationParams(params);
    // controller
    //   ..setJavaScriptMode(JavaScriptMode.disabled)
    //   ..setBackgroundColor(const Color(0x00000000))
    //   ..setNavigationDelegate(
    //     NavigationDelegate(
    //       onProgress: (int progress) {},
    //       onPageStarted: (String url) {},
    //       onPageFinished: (String url) {
    //         setState(() {
    //           isLoading = false;
    //         });
    //       },
    //       onUrlChange: (change) {},
    //       onWebResourceError: (WebResourceError error) {},
    //       onNavigationRequest: (NavigationRequest request) {
    //         if (request.url.startsWith((widget.urlLink))) {
    //           return NavigationDecision.prevent;
    //         }

    //         return NavigationDecision.navigate;
    //       },
    //     ),
    //   )
    //   ..addJavaScriptChannel(
    //     'Toaster',
    //     onMessageReceived: (JavaScriptMessage message) {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(content: Text(message.message)),
    //       );
    //     },
    //   )
    //   // ..loadRequest(Uri.parse(getProperHtml(widget.urlLink ?? '')));
    //   ..loadRequest(Uri.parse(getProperHtml('https://abee.co.kr/')));
    // if (controller.platform is AndroidWebViewController) {
    //   AndroidWebViewController.enableDebugging(true);
    //   (controller.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
    // }
    // _controller = controller;
  }

  // void _updateLocation(PointerEvent details) {}

  @override
  void dispose() {
    // _timeDown?.cancel();
    try {
      timer5s?.cancel();
      gifController?.dispose();
      _scrollController.dispose();
    } catch (e) {}
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return Container(
    //   // color: AppColor.white,
    //   // padding: EdgeInsets.only(top: widget.paddingTop),
    //   child: );
    // final heightMargin = kToolbarHeight - MediaQuery.of(context).padding.bottom;
    final top = MediaQuery.of(context).padding.top;
    // final bottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
        backgroundColor: Colors.blue,
        appBar: AppBar(
          backgroundColor: Colors.grey.shade500,
          toolbarHeight: 0,
        ),
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: top),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  WidgetAnimationClickV2(
                      padding: const EdgeInsets.all(16),
                      onTap: () {
                        widget.onClose();
                      },
                      child: const Icon(Icons.arrow_back, color: Colors.black, size: 24)),
                  Flexible(
                    child: Text(
                      widget.title ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyle.bold.copyWith(color: Colors.black, fontSize: 18),
                    ),
                  ),
                  widget.actions ??
                      const SizedBox(
                        width: 32,
                      )
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: WidgetImageOfferWall(
                  scrollController: _scrollController,
                  onScrollWebView: () {
                    if (!isRunning) {
                      isRunning = true;
                      timerController.start();
                    }
                    start5s();
                  },
                  urlLink: widget.urlLink ?? '',
                  onDone: () {
                    if (timerController.value == 0) {
                      try {
                        timerController.start();
                        start5s();
                      } catch (e) {
                        rethrow;
                      }
                    }
                  },
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 10, bottom: 16),
              width:
                  // widget.deviceWidth > 0
                  //     ? widget.deviceWidth
                  //     :
                  MediaQuery.of(context).size.width,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  widget.bookmark ?? const SizedBox(),
                  // InkWell(
                  //     onTap: widget.onSave,
                  //     child: Image.asset(Assets.bookmark.path,
                  //         package: "eums",
                  //         height: 27,
                  //         color: AppColor.black)),
                  ValueListenableBuilder(
                    valueListenable: showButton,
                    builder: (context, value, child) => WidgetAnimationClickV2(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      borderRadius: BorderRadius.circular(4),
                      color: !showButton.value ? Colors.grey.shade300 : AppColor.red,
                      onTap: !showButton.value ? null : widget.mission,
                      child: Text(
                        '포인트 적립하기',
                        style: AppStyle.medium.copyWith(color: !showButton.value ? AppColor.black : AppColor.white),
                      ),
                    ),
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
        ));
  }

  // _buildButtonBack() {
  //   Container(padding: const EdgeInsets.all(16), child: const Icon(Icons.arrow_back, color: Colors.black, size: 24));
  // }
}
