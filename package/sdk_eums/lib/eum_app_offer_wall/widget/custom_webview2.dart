import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:sdk_eums/gen/assets.gen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../utils/appStyle.dart';

class CustomWebView2 extends StatefulWidget {
  final dynamic urlLink;
  final dynamic title;
  final Function()? onSave;
  final Function()? mission;
  final Function onClose;
  final bool showMission;
  final Color color;
  final Color colorIconBack;
  final Widget? actions;
  final Widget? bookmark;
  final showImage;
  final double deviceWidth;
  const CustomWebView2(
      {Key? key,
      this.urlLink,
      this.title,
      this.onSave,
      this.mission,
      required this.onClose,
      this.showMission = false,
      this.colorIconBack = AppColor.black,
      this.color = AppColor.white,
      this.actions,
      this.bookmark,
      this.deviceWidth = 0,
      this.showImage = false})
      : super(key: key);

  @override
  State<CustomWebView2> createState() => _CustomWebView2State();
}

class _CustomWebView2State extends State<CustomWebView2> {
  late final WebViewController _controller;
  bool isLoading = true;
  ScrollController _scrollController = ScrollController();

  Timer? _timeDown;
  int _startTime = 15;
  Timer? timer5s;
  bool showButton = false;
  bool isRunning = true;

  String getProperHtml(String content) {
    String start1 = 'https:';
    int startIndex1 = content.indexOf(start1);
    String iframeTag1 = content.substring(startIndex1 + 6);
    content = iframeTag1.replaceAll("$iframeTag1", "http:${iframeTag1}");
    return content;
  }

  void startTimeDown() {
    _timeDown?.cancel();
    _timeDown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startTime == 0) {
        _timeDown?.cancel();
      } else {
        setState(() {
          _startTime--;
        });
        if (_startTime == 0) {
          setState(() {
            showButton = true;
            _timeDown?.cancel();
          });
        }
      }
    });
  }

  start5s() {
    timer5s?.cancel();
    timer5s = Timer.periodic(const Duration(seconds: 5), (_) {
      _timeDown?.cancel();
      isRunning = false;
    });
  }

  _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
            ScrollDirection.reverse ||
        _scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
      if (!isRunning) {
        isRunning = true;
        startTimeDown();
      }
      start5s();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    if (widget.showMission) {
      startTimeDown();
      start5s();
    }
    super.initState();
    _scrollController.addListener(_scrollListener);

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    controller
      ..setJavaScriptMode(JavaScriptMode.disabled)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onUrlChange: (change) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith((widget.urlLink))) {
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse(getProperHtml(widget.urlLink ?? '')));
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    _controller = controller;
  }

  void _updateLocation(PointerEvent details) {}

  @override
  void dispose() {
    _timeDown?.cancel();
    timer5s?.cancel();
    _scrollController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 80),
      child: Scaffold(
        backgroundColor: AppColor.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: GestureDetector(
            onTap: () {
              widget.onClose();
            },
            child: Container(
                padding: EdgeInsets.all(16),
                child: Icon(Icons.arrow_back, color: Colors.black, size: 24)),
          ),
          actions: [widget.actions ?? const SizedBox()],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  CachedNetworkImage(
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                      imageUrl: widget.urlLink,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) {
                        return Image.asset(Assets.logo.path,
                            package: "sdk_eums", height: 16);
                      }),
                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom + 70,
                  )
                ],
              ),
            ),
            !widget.showMission
                ? const SizedBox()
                : Positioned(
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.only(
                          top: 5,
                          bottom: MediaQuery.of(context).padding.bottom + 20),
                      width: widget.deviceWidth > 0
                          ? widget.deviceWidth
                          : MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          widget.bookmark ?? SizedBox(),
                          // GestureDetector(
                          //     onTap: widget.onSave,
                          //     child: Image.asset(Assets.bookmark.path,
                          //         package: "sdk_eums",
                          //         height: 27,
                          //         color: AppColor.black)),
                          GestureDetector(
                            onTap: !showButton ? null : widget.mission,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: !showButton
                                      ? AppColor.grey.withOpacity(0.5)
                                      : AppColor.red),
                              child: Text(
                                '포인트 적립하기',
                                style: AppStyle.medium.copyWith(
                                    color: !showButton
                                        ? AppColor.grey
                                        : AppColor.white),
                              ),
                            ),
                          ),
                          Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: AppColor.grey.withOpacity(0.5),
                                  shape: BoxShape.circle),
                              child: Text(
                                _startTime.toString(),
                                style: AppStyle.medium.copyWith(fontSize: 16),
                              ))
                        ],
                      ),
                    ))
          ],
        ),
      ),
    );
  }
}
