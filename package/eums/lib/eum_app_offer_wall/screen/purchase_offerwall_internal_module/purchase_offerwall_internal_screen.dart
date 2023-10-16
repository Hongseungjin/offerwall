import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:eums/common/events/rx_events.dart';
import 'package:eums/common/rx_bus.dart';
import 'package:eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:eums/eum_app_offer_wall/utils/loading_dialog.dart';
import 'package:eums/eum_app_offer_wall/widget/custom_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import 'bloc/purchase_offerwall_internal_bloc.dart';

// ignore: must_be_immutable
class PurchaseOfferwallInternalScreen extends StatefulWidget {
  PurchaseOfferwallInternalScreen({Key? key, this.data}) : super(key: key);
  dynamic data;

  @override
  State<PurchaseOfferwallInternalScreen> createState() => _PurchaseOfferwallInternalScreenState();
}

class _PurchaseOfferwallInternalScreenState extends State<PurchaseOfferwallInternalScreen> {
  final GlobalKey<State<StatefulWidget>> globalKey = GlobalKey<State<StatefulWidget>>();
  InAppWebViewController? webView;

  String myurl = "https://indend.welfaredream.com/front/goods/content.asp?guid=216773";

  List? _languages = [];

  Future<void> _getPreferredLanguages() async {
    try {
      final languages = await Devicelocale.preferredLanguages;
      print((languages != null) ? languages : "unable to get preferred languages");
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
    return BlocProvider<PurchaseOfferwallInternalBloc>(
      create: (context) => PurchaseOfferwallInternalBloc(),
      child: MultiBlocListener(listeners: [
        BlocListener<PurchaseOfferwallInternalBloc, PuschaseOffWallState>(
          listenWhen: (previous, current) => previous.puschaseOfferWallInternalStatus != current.puschaseOfferWallInternalStatus,
          listener: _listenFetchData,
        ),
      ], child: _buildContent(context)),
    );
  }

  void _listenFetchData(BuildContext context, PuschaseOffWallState state) {
    if (state.puschaseOfferWallInternalStatus == PuschaseOfferWallInternalStatus.loading) {
      LoadingDialog.instance.show();
      return;
    }
    if (state.puschaseOfferWallInternalStatus == PuschaseOfferWallInternalStatus.failure) {
      LoadingDialog.instance.hide();
      return;
    }
    if (state.puschaseOfferWallInternalStatus == PuschaseOfferWallInternalStatus.success) {
      LoadingDialog.instance.hide();
      RxBus.post(UpdateUser());
      DialogUtils.showDialogMissingPoint(context, data: widget.data['reward'], voidCallback: () {
        Navigator.pop(context);
      });
    }
  }

  Widget _buildContent(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back,
            color: AppColor.black,
          ),
        ),
        backgroundColor: AppColor.white,
      ),
      body: Column(children: [
        Expanded(
            child: InAppWebView(
          onWebViewCreated: (controller) {
            webView = controller;
            webView?.loadUrl(urlRequest: URLRequest(url: Uri.parse(myurl)));
            print("change");
          },
          onLoadStart: (controller, url) {},
          // initialUrlRequest: URLRequest(url: Uri.parse(myurl)),
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            var uri = navigationAction.request.url!;
            if (!["http", "https", "file", "chrome", "data", "javascript", "about"].contains(uri.scheme)) {
              if (await canLaunchUrl(uri)) {
                await launchUrl(
                  uri,
                );
                return NavigationActionPolicy.CANCEL;
              }
            }

            return NavigationActionPolicy.ALLOW;
          },

          onLoadStop: (controller, url) async {
            print("loadStop${url}");
            var html = await webView?.evaluateJavascript(source: "window.document.getElementsByTagName('html')[0].outerHTML;");
            printWrapped("loadStopurl$html");
            try {
              if (html.contains('주문접수가<br>완료되었습니다.')) {
                String lang = '';
                if (_languages?[0] == 'ko-KR') {
                  lang = 'kor';
                } else {
                  lang = 'eng';
                }
                globalKey.currentContext?.read<PurchaseOfferwallInternalBloc>().add(PuschaseOffWall(xId: widget.data['idx'], lang: lang));
                print("success");
                controller.canGoBack();
              } else {
                print("error");
              }
            } catch (ex) {
              print("exex$ex");
            }
          },

          onUpdateVisitedHistory: (controller, url, androidIsReload) async {},
          onConsoleMessage: (controller, consoleMessage) {
            controller.evaluateJavascript(source: '');
            printWrapped("consoleMessage$consoleMessage");
          },
        ))
      ]),
    );
  }

  void printWrapped(String text) {
    final pattern = RegExp('.{1,800}');
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }
}
