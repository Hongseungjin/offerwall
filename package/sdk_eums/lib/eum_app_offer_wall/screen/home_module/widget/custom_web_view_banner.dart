import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomWebViewBanner extends StatefulWidget {
  const CustomWebViewBanner({
    Key? key,
    this.urlLink,
  }) : super(key: key);
  final dynamic urlLink;

  @override
  State<CustomWebViewBanner> createState() => _CustomWebViewBannerState();
}

class _CustomWebViewBannerState extends State<CustomWebViewBanner> {
  InAppWebViewController? webView;

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
          useShouldOverrideUrlLoading: true,
          mediaPlaybackRequiresUserGesture: false),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  String getProperHtml(String content) {
    String start1 = 'https:';
    int startIndex1 = content.indexOf(start1);
    String iframeTag1 = content.substring(startIndex1 + 6);
    content = iframeTag1.replaceAll("$iframeTag1", "https:${iframeTag1}");
    return content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColor.white,
          centerTitle: true,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back,
              color: AppColor.black,
            ),
          ),
          actions: [],
        ),
        body: InAppWebView(
          initialOptions: options,
          onWebViewCreated: (controller) {
            webView = controller;
            print("change");
          },
          androidOnPermissionRequest: (controller, origin, resources) async {
            return PermissionRequestResponse(
                resources: resources,
                action: PermissionRequestResponseAction.GRANT);
          },
          onLoadStart: (controller, url) {},
          initialUrlRequest:
              URLRequest(url: Uri.parse(getProperHtml(widget.urlLink))),
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            var uri = navigationAction.request.url!;
            if (![
              "http",
              "https",
              "file",
              "chrome",
              "data",
              "javascript",
              "about"
            ].contains(uri.scheme)) {
              if (await canLaunchUrl(uri)) {
                return NavigationActionPolicy.CANCEL;
              }
            }

            return NavigationActionPolicy.ALLOW;
          },
          onLoadStop: (controller, url) async {},
          onUpdateVisitedHistory: (controller, url, androidIsReload) async {},
          onConsoleMessage: (controller, consoleMessage) {
            controller.evaluateJavascript(source: '');
          },
        ));
  }
}
