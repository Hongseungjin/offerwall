import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sdk_eums/common/events/events.dart';
import 'package:sdk_eums/common/rx_bus.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:sdk_eums/eum_app_offer_wall/widget/custom_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import 'bloc/join_offerwall_bloc.dart';

class JoinOfferWallScreen extends StatefulWidget {
  JoinOfferWallScreen({Key? key, this.data, this.onCallBack}) : super(key: key);
  dynamic data;
  final Function? onCallBack;

  @override
  State<JoinOfferWallScreen> createState() => _JoinOfferWallScreenState();
}

class _JoinOfferWallScreenState extends State<JoinOfferWallScreen> {
  InAppWebViewController? webView;
  final GlobalKey<State<StatefulWidget>> globalKey =
      GlobalKey<State<StatefulWidget>>();

  String myUrl = '';
  //     'https://abee997.co.kr/stat/index.php/Login/get__post_register_test';

  bool checkJoin = false;
  List? _languages = [];
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
          useShouldOverrideUrlLoading: true,
          mediaPlaybackRequiresUserGesture: false),
      android: AndroidInAppWebViewOptions(
          useHybridComposition: true, useShouldInterceptRequest: true),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  ContextMenu? contextMenu;
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
    myUrl = widget.data['api'] ?? '';
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _listenFetchData(BuildContext context, JoinOffWallState state) {
    if (state.joinOfferWallStatus == JoinOfferWallStatus.loading) {
      return;
    }
    if (state.joinOfferWallStatus == JoinOfferWallStatus.failure) {
      return;
    }
    if (state.joinOfferWallStatus == JoinOfferWallStatus.success) {
      RxBus.post(UpdateUser());
      DialogUtils.showDialogMissingPoint(context, data: widget.data['reward'],
          voidCallback: () {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<JoinOfferwallInternalBloc>(
      create: (context) => JoinOfferwallInternalBloc(),
      child: MultiBlocListener(listeners: [
        BlocListener<JoinOfferwallInternalBloc, JoinOffWallState>(
          listenWhen: (previous, current) =>
              previous.joinOfferWallStatus != current.joinOfferWallStatus,
          listener: _listenFetchData,
        ),
      ], child: _buildContent(context)),
    );
    ;
  }

  _buildContent(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: AppBar(
        backgroundColor: AppColor.white,
        leading: GestureDetector(
          onTap: () {
            widget.onCallBack!(checkJoin);
            Navigator.of(context).pop();
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
              webView?.loadUrl(urlRequest: URLRequest(url: Uri.parse(myUrl)));

              print("chang12312312e");
            },
            onLoadStart: (controller, url) {},
            iosOnDidReceiveServerRedirectForProvisionalNavigation:
                (controller) {},
            iosOnNavigationResponse: (controller, navigationResponse) async {
              print("iosOnNavigationResponse$navigationResponse");
              return;
            },
            iosOnWebContentProcessDidTerminate: (controller) {},

            iosShouldAllowDeprecatedTLS: (controller, challenge) async {
              print("iosShouldAllowDeprecatedTLS$challenge");
              return;
            },
            shouldInterceptFetchRequest: (controller, fetchRequest) async {
              print("shouldInterceptFetchRequest$fetchRequest");
              return;
            },
            

            androidShouldInterceptRequest: (controller, request) async {
              print("requestrequestrequest$request");

              ////stat/index.php/Login/post__register
              if (request.url.toString() ==
                  'https://abee997.co.kr/stat/index.php/Login/post__register_test') {
                setState(() {
                  checkJoin = true;
                });

                print("ahihi123123");

                // globalKey.currentContext
                //     ?.read<JoinOfferwallInternalBloc>()
                //     .add(JoinOffWall(xId: widget.data['idx'], lang: lang));
              } else {
                print("ahihi");
              }
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              var uri = navigationAction.request.url!;

              print("uriuriuriuri$uri");
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
                  await launchUrl(
                    uri,
                  );

                  return NavigationActionPolicy.CANCEL;
                }
              }

              return NavigationActionPolicy.ALLOW;
            },
            shouldInterceptAjaxRequest: (controller, ajaxRequest) async {
              printWrapped("ajaxRequest${ajaxRequest}");
              return ajaxRequest;
            },

            onLoadStop: (controller, url) async {
              var html = await webView?.evaluateJavascript(
                  source:
                      "window.document.getElementsByTagName('html')[0].outerHTML;");

              // printWrapped("loadStopurl $html");
              if (html.contains('승인은 영업일 기준 3일 이내에 완료되며, 문자 메시지로 통보애 드립니다.')) {
                webView?.canGoBack().then((value) {
                  print("valuevalue123 $value");
                  if (value) {}
                });
              } else {
                print("err");
              }
            },

            // ignore: prefer_collection_literals
            gestureRecognizers: Set()
              ..add(Factory<TapGestureRecognizer>(() => TapGestureRecognizer()
                ..onTap = () {
                  print("This one prints");
                })),

            onUpdateVisitedHistory: (controller, url, androidIsReload) async {},
            onConsoleMessage: (controller, consoleMessage) {
              printWrapped("consoleMessage$consoleMessage");
            },
          ))
        ],
      ),
    );
  }

  void printWrapped(String text) {
    final pattern = RegExp('.{4,800}');
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }
}
