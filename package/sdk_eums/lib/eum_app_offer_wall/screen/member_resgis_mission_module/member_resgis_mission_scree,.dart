import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class MemberResgisMissionScreen extends StatefulWidget {
  const MemberResgisMissionScreen({Key? key}) : super(key: key);

  @override
  State<MemberResgisMissionScreen> createState() =>
      _MemberResgisMissionScreenState();
}

class _MemberResgisMissionScreenState extends State<MemberResgisMissionScreen> {
  InAppWebViewController? webView;
  String myurl = "https://www.facebook.com/";
  

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(children: [
        Expanded(
            child: InAppWebView(
          onWebViewCreated: (controller) {},
          onLoadStart: (controller, url) {},
          initialUrlRequest: URLRequest(url: Uri.parse(myurl)),
         shouldOverrideUrlLoading: (controller, navigationAction) async{
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
                        // Launch the App
                        await launchUrl(
                          uri,
                        );
                        // and cancel the request
                        return NavigationActionPolicy.CANCEL;
                      }
                    }

                    return NavigationActionPolicy.ALLOW;
         },
          
          onLoadStop: (controller, url) async {
            print("concaccc" +url.toString());
            if (url!.authority.contains('/recon?')) {
              // if JavaScript is enabled, you can use
              var html = await controller.evaluateJavascript(
                  source:
                      "window.document.getElementsByTagName('html')[0].outerHTML;");
              log("htmlhtmlhtml$html");
              print("htmlhtmlhtml$html");
            }
          },
          onUpdateVisitedHistory: (controller, url, androidIsReload) {
            print("urlurlurl$url");
          },
        
          onConsoleMessage: (controller, consoleMessage) {
            print("consoleMessage$consoleMessage");
          },
        ))
      ]),
    );
  }
}
