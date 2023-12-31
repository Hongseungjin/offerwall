import 'package:cached_network_image/cached_network_image.dart';
import 'package:eums/gen/assets.gen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class WidgetImageOfferWall extends StatefulWidget {
  const WidgetImageOfferWall({super.key, required this.urlLink, required this.onDone, required this.scrollController, required this.onScrollWebView});
  final String urlLink;
  final Function() onDone;
  final Function() onScrollWebView;
  final ScrollController scrollController;

  @override
  State<WidgetImageOfferWall> createState() => _WidgetImageOfferWallState();
}

class _WidgetImageOfferWallState extends State<WidgetImageOfferWall> {
  final events = [];
  bool canScroll = true;
  WebViewController? controller;

  String? linkWeb;

  ValueNotifier<double> progress = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    if (!widget.urlLink.contains(".png") && !widget.urlLink.contains(".jpg")) {
      linkWeb = getProperHtml(widget.urlLink);

      try {
        // #docregion platform_features
        late final PlatformWebViewControllerCreationParams params;
        if (WebViewPlatform.instance is WebKitWebViewPlatform) {
          params = WebKitWebViewControllerCreationParams(
            allowsInlineMediaPlayback: true,
            mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
          );
        } else {
          params = const PlatformWebViewControllerCreationParams();
        }

        controller = WebViewController.fromPlatformCreationParams(params);
        // #enddocregion platform_features

        controller!
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                debugPrint('WebView is loading (progress : $progress%)');
                if (progress == 0) {
                  this.progress.value = 1;
                } else {
                  this.progress.value = progress / 100;
                }
              },
              onPageStarted: (String url) {
                debugPrint('Page started loading: $url');
              },
              onPageFinished: (String url) {
                debugPrint('Page finished loading: $url');
                try {
                  if (url != linkWeb && linkWeb!.contains("://m") == false) {
                    linkWeb = url;
                    controller?.loadRequest(Uri.parse(url));
                  }
                } catch (e) {}
                widget.onDone.call();
              },
              onWebResourceError: (WebResourceError error) {
                debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
              },
              onNavigationRequest: (NavigationRequest request) {
                if (request.url.startsWith('https://www.youtube.com/')) {
                  debugPrint('blocking navigation to ${request.url}');
                  return NavigationDecision.prevent;
                }
                debugPrint('allowing navigation to ${request.url}');
                return NavigationDecision.navigate;
              },
              onUrlChange: (UrlChange change) {
                debugPrint('url change to ${change.url}');
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
          ..loadRequest(Uri.parse(linkWeb!));

        // #docregion platform_features
        if (controller!.platform is AndroidWebViewController) {
          AndroidWebViewController.enableDebugging(true);
          (controller!.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
        }
        // #enddocregion platform_features
      } catch (e) {
        rethrow;
      }

      // controller = WebViewController()
      //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
      //   ..setBackgroundColor(const Color(0x00000000))
      //   ..setNavigationDelegate(
      //     NavigationDelegate(
      //       onProgress: (int progress) {
      //         // Update loading bar.
      //         if (progress == 0) {
      //           this.progress.value = 1;
      //         } else {
      //           this.progress.value = progress / 100;
      //         }
      //       },
      //       onPageStarted: (String url) {
      //         progress.value = 10;
      //       },
      //       onPageFinished: (String url) {
      //         // isRunning = true;
      //         // timerController.start();
      //         if (url != linkWeb) {
      //           linkWeb = url;
      //           controller?.loadRequest(Uri.parse(url));
      //         }
      //         widget.onDone.call();
      //       },
      //       onWebResourceError: (WebResourceError error) {
      //         debugPrint("onWebResourceError: ${error.description}");
      //       },
      //       onNavigationRequest: (NavigationRequest request) {
      //         // if (request.url.startsWith('https://www.youtube.com/')) {
      //         //   return NavigationDecision.prevent;
      //         // }
      //         // return NavigationDecision.navigate;
      //         return NavigationDecision.prevent;
      //       },
      //     ),
      //   );

      // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      //   controller?.loadRequest(Uri.parse(linkWeb!));
      //   setState(() {});
      // });
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
  void dispose() {
    // controller?.clearCache();
    // controller?.clearLocalStorage();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // debugPrint("xxxxxx");
    return controller != null
        ? Stack(
            children: [
              WebViewWidget(
                controller: controller!,
                gestureRecognizers: {
                  Factory<VerticalDragGestureRecognizer>(
                    () => VerticalDragGestureRecognizer()
                      ..onDown = (_) {
                        // debugPrint("xxxx");
                        widget.onScrollWebView.call();
                      }
                      ..onEnd = (details) {
                        // debugPrint("yyyy");
                      },
                  ),
                },
              ),
              ValueListenableBuilder<double>(
                valueListenable: progress,
                builder: (context, value, child) {
                  if (value < 1.0) {
                    return Container(
                      color: Colors.black.withOpacity(.1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Center(
                            child: CircularProgressIndicator(
                          value: progress.value,
                          color: const Color(0xfffcc900),
                        )),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              )
            ],
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
                        return Image(
                          image: imageProvider,
                          fit: BoxFit.fill,
                          width: width,
                        );
                      },
                      errorWidget: (context, url, error) {
                        return Image.asset(Assets.logo.path, package: "eums", height: 100);
                      }),
                )),
          );
  }
}
