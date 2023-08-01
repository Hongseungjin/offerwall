import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomInappWebView extends StatefulWidget {
  const CustomInappWebView({Key? key, this.urlLink, this.onClose})
      : super(key: key);
  final dynamic urlLink;
  final Function? onClose;

  @override
  State<CustomInappWebView> createState() => _CustomInappWebViewState();
}

class _CustomInappWebViewState extends State<CustomInappWebView> {
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

  List? _languages = [];
  var html;

  Future<void> _getPreferredLanguages() async {
    try {
      final languages = await Devicelocale.preferredLanguages;
      print((languages != null)
          ? languages
          : "unable to get preferred languages");
      setState(() => _languages = languages);
      print("_languages$_languages");
    } on PlatformException {
      print("Error obtaining preferred languages");
    }
  }



  @override
  void initState() {

    _getPreferredLanguages();
    super.initState();
    // webView?.loadUrl(urlRequest: URLRequest(url: Uri.parse(myurl)));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.white,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
           
          },
          child: const Icon(
            Icons.arrow_back,
            color: AppColor.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: InAppWebView(
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
                  // await launchUrl(
                  //   uri,
                  // );
                  return NavigationActionPolicy.CANCEL;
                }
              }

              return NavigationActionPolicy.ALLOW;
            },
            onLoadStop: (controller, url) async {
              // html = await webView?.evaluateJavascript(
              //     source:
              //         "window.document.getElementsByTagName('html')[0].outerHTML;");
              // setState(() {});
              // printWrapped("loadStopurl  ${html}");
            },
            onUpdateVisitedHistory: (controller, url, androidIsReload) async {},
            onConsoleMessage: (controller, consoleMessage) {
              controller.evaluateJavascript(source: '');
              // printWrapped("consoleMessage$consoleMessage");
            },
          )),
        ],
      ),
    );
  }

  String getProperHtml(String content) {
    String start1 = 'https:';
    int startIndex1 = content.indexOf(start1);
    String iframeTag1 = content.substring(startIndex1 + 6);
    content = iframeTag1.replaceAll("$iframeTag1", "https:${iframeTag1}");
    return content;
  }

  void printWrapped(String text) {
    final pattern = RegExp('.{1,800}');
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }
}
