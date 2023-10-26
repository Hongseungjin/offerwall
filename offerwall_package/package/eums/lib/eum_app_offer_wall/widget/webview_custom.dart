import 'dart:async';

import 'package:flutter/material.dart';
import 'package:eums/common/local_store/local_store_service.dart';
import 'package:eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:eums/gen/assets.gen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../utils/appStyle.dart';

class CustomWebViewScreen extends StatefulWidget {
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
  const CustomWebViewScreen(
      {Key? key,
      this.urlLink,
      this.title,
      this.onSave,
      this.mission,
      this.showMission = false,
      this.colorIconBack = AppColor.black,
      this.color = AppColor.white,
      this.actions,
      required this.onClose,
      this.bookmark})
      : super(key: key);

  @override
  State<CustomWebViewScreen> createState() => _CustomWebViewScreenState();
}

class _CustomWebViewScreenState extends State<CustomWebViewScreen> {
  late final WebViewController _controller;
  bool isLoading = true;

  Timer? _timer;
  Timer? _timerHanlder;
  int _start = 15;
  int _startHanlder = 5;
  bool showButton = false;

  String getProperHtml(String content) {
    String start1 = 'https:';
    int startIndex1 = content.indexOf(start1);
    String iframeTag1 = content.substring(startIndex1 + 6);
    content = iframeTag1.replaceAll("$iframeTag1", "http:${iframeTag1}");
    print("contentcontent$content");
    return content;
  }

  void startHanlde() {
    if (_startHanlder == 0) {
      _start = 15;
    }

    const oneSec = Duration(seconds: 1);
    _timerHanlder = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_startHanlder == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _startHanlder--;
          });
          if (_startHanlder == 0) {
            _start = 15;
            _timer?.cancel();
            print("vao day nhe");
          }
        }
      },
    );
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
          if (_start == 0) {
            setState(() {
              showButton = true;
            });
          }
        }
      },
    );
  }

  double deviceWith = 0;
  getDeviceWidth() async {
    deviceWith = double.parse(LocalStoreService.instant.getDeviceWidth());
    print('deviceWithdeviceWith $deviceWith');
  }

  @override
  void initState() {
    // TODO: implement initState
    if (widget.showMission) {
      startTimer();
    }
    super.initState();
    getDeviceWidth();

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);
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
      ..loadRequest(Uri.parse((getProperHtml('https://www.youtube.com/watch?v=rICj8z9AO-4&ab_channel=Th%E1%BA%B1ngKh%E1%BB%9D')
          // widget.urlLink ?? ''
          )));
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
    }
    _controller = controller;
  }

  @override
  void dispose() {
    _timer?.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  int _upCounter = 0;
  int _downCounter = 0;
  double x = 0.0;
  double y = 0.0;

  void _incrementUp(PointerEvent details) {
    // _updateLocation(details);
    _upCounter = 0;
    setState(() {
      _upCounter++;
    });
    if (_upCounter == 1) {
      _startHanlder = 5;
      if (0 < _start && _start < 5) {
        startHanlde();
      }
    }
    print("_incrementUp$_upCounter");
  }

  void _incrementDown(PointerEvent details) {
    _downCounter = 0;
    setState(() {
      _downCounter++;
    });
    if (_downCounter == 1) {
      showButton = false;
      _timerHanlder?.cancel();
      startTimer();
    }
    print("_incrementDown$_downCounter");
  }

  void _updateLocation(PointerEvent details) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        backgroundColor: widget.color,
        title: Text(widget.title, style: AppStyle.bold.copyWith(fontSize: 16)),
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            if (widget.colorIconBack == AppColor.white) {
              Navigator.of(context).pop();
            } else {
              widget.onClose();
            }
          },
          child: Icon(Icons.arrow_back, color: widget.colorIconBack, size: 24),
        ),
        actions: [widget.actions ?? const SizedBox()],
      ),
      body: Stack(
        children: [
          Listener(
              onPointerDown: _incrementDown,
              onPointerUp: _incrementUp,
              onPointerMove: _updateLocation,
              child: WebViewWidget(controller: _controller)),
          Visibility(
            visible: isLoading,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          !widget.showMission
              ? const SizedBox()
              : Positioned(
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).padding.bottom + 20),
                    width: deviceWith > 0 ? deviceWith : MediaQuery.of(context).size.width,
                    color: AppColor.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        widget.bookmark ??
                            InkWell(
                                onTap: widget.onSave, child: Image.asset(Assets.deleteKeep.path, package: "eums", height: 27, color: AppColor.black)),
                        InkWell(
                          onTap: !showButton ? null : widget.mission,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4), color: !showButton ? AppColor.grey.withOpacity(0.5) : AppColor.red),
                            child: Text(
                              '포인트 적립하기',
                              style: AppStyle.medium.copyWith(color: !showButton ? AppColor.grey : AppColor.white),
                            ),
                          ),
                        ),
                        Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: AppColor.grey.withOpacity(0.5), shape: BoxShape.circle),
                            child: Text(
                              _start.toString(),
                              style: AppStyle.medium.copyWith(fontSize: 16),
                            ))
                      ],
                    ),
                  ))
        ],
      ),
    );
  }
}
