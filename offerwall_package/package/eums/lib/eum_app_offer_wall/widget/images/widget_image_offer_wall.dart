import 'package:cached_network_image/cached_network_image.dart';
import 'package:eums/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WidgetImageOfferWall extends StatefulWidget {
  const WidgetImageOfferWall({super.key, required this.urlLink, required this.onDone, required this.scrollController});
  final String urlLink;
  final Function() onDone;
  final ScrollController scrollController;

  @override
  State<WidgetImageOfferWall> createState() => _WidgetImageOfferWallState();
}

class _WidgetImageOfferWallState extends State<WidgetImageOfferWall> {
  final events = [];
  bool canScroll = true;
  WebViewController? controller;

  @override
  void initState() {
    super.initState();
    if (!widget.urlLink.contains(".png") && !widget.urlLink.contains(".jpg")) {
      final linkWeb = getProperHtml(widget.urlLink);
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              // Update loading bar.
            },
            onPageStarted: (String url) {},
            onPageFinished: (String url) {
              // isRunning = true;
              // timerController.start();
              widget.onDone.call();
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint("onWebResourceError: ${error.description}");
            },
            onNavigationRequest: (NavigationRequest request) {
              // if (request.url.startsWith('https://www.youtube.com/')) {
              //   return NavigationDecision.prevent;
              // }
              // return NavigationDecision.navigate;
              return NavigationDecision.prevent;
            },
          ),
        )
        ..loadRequest(Uri.parse(linkWeb));
    }
  }

  String getProperHtml(String content) {
    // String start1 = 'https:';
    // int startIndex1 = content.indexOf(start1);
    // String iframeTag1 = content.substring(startIndex1 + 6);
    // content = iframeTag1.replaceAll(iframeTag1, "http:$iframeTag1");
    // return content;

    if (content.contains("http")) {
      return content;
    } else {
      return "http://$content";
    }
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint("xxxxxx");
    return controller != null
        ? WebViewWidget(
            controller: controller!,
          )
        : SingleChildScrollView(
            controller: widget.scrollController,
            scrollDirection: Axis.vertical,
            physics: canScroll ? const ScrollPhysics() : const NeverScrollableScrollPhysics(),
            child: Listener(
                onPointerDown: (event) {
                  events.add(event.pointer);
                  // print("new event ${event.pointer}");
                },
                onPointerUp: (event) {
                  events.clear();
                  // debugPrint("events cleared");
                  setState(() {
                    canScroll = true;
                  });
                },
                onPointerMove: (event) {
                  if (events.length == 2) {
                    setState(() {
                      canScroll = false;
                    });
                  }
                },
                child: InteractiveViewer(
                  // child: Image.network(
                  //   widget.urlLink,
                  //   fit: BoxFit.contain,
                  //   width: MediaQuery.of(context).size.width,
                  //   errorBuilder: (context, error, stackTrace) => Image.asset(Assets.logo.path, package: "eums", height: 100),
                  //   loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  //     if (loadingProgress == null) {
                  //       return child;
                  //     }
                  //     final valueProgress = loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!;
                  //     if (valueProgress == 1.0) {
                  //       widget.onDone.call();
                  //     }
                  //     debugPrint('valueProgress: $valueProgress');
                  //     return Padding(
                  //       padding: const EdgeInsets.symmetric(vertical: 30),
                  //       child: Center(
                  //           child: CircularProgressIndicator(
                  //         color: const Color(0xfffcc900),
                  //         value: loadingProgress.expectedTotalBytes != null ? valueProgress : null,
                  //       )),
                  //     );
                  //     // return Center(
                  //     //   child: CircularProgressIndicator(
                  //     //     value: loadingProgress.expectedTotalBytes != null
                  //     //         ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  //     //         : null,
                  //     //   ),
                  //     // );
                  //   },
                  // ),
                  child: CachedNetworkImage(
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.fitHeight,
                      imageUrl: widget.urlLink,
                      placeholder: (context, url) => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 30),
                            child: Center(
                                child: CircularProgressIndicator(
                              color: Color(0xfffcc900),
                            )),
                          ),
                      imageBuilder: (context, imageProvider) {
                        widget.onDone.call();
                        return Image(image: imageProvider);
                      },
                      errorWidget: (context, url, error) {
                        return Image.asset(Assets.logo.path, package: "eums", height: 100);
                      }),
                )),
          );
  }
}
