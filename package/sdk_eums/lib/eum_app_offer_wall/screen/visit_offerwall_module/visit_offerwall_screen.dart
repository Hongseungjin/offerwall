import 'dart:async';

import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sdk_eums/common/rx_bus.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/visit_offerwall_module/bloc/visit_offerwall_bloc.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:sdk_eums/eum_app_offer_wall/widget/custom_dialog.dart';
import 'package:sdk_eums/eum_app_offer_wall/widget/custom_webview.dart';

import '../../../common/events/rx_events.dart';

class VisitOfferWallScren extends StatefulWidget {
  VisitOfferWallScren({Key? key, this.data, this.voidCallBack})
      : super(key: key);
  dynamic data;
  final Function? voidCallBack;
  @override
  State<VisitOfferWallScren> createState() => _VisitOfferWallScrenState();
}

class _VisitOfferWallScrenState extends State<VisitOfferWallScren> {
  final GlobalKey<State<StatefulWidget>> globalKey =
      GlobalKey<State<StatefulWidget>>();
  Timer? _timer;
  int _start = 15;

  List? _languages = [];

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
    // TODO: implement initState
    // startTimer();
    super.initState();
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
            String lang = '';
            if (_languages?[0] == 'ko-KR') {
              lang = 'kor';
            } else {
              lang = 'eng';
            }
            globalKey.currentContext
                ?.read<VisitOfferwallInternalBloc>()
                .add(VisitOffWall(xId: widget.data['idx'], lang: lang));
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VisitOfferwallInternalBloc>(
      create: (context) => VisitOfferwallInternalBloc(),
      child: MultiBlocListener(listeners: [
        BlocListener<VisitOfferwallInternalBloc, VisitOfferWallInternalState>(
          listenWhen: (previous, current) =>
              previous.visitOfferWallInternalStatus !=
              current.visitOfferWallInternalStatus,
          listener: _listenFetchData,
        ),
      ], child: _buildContent(context)),
    );
  }

  void _listenFetchData(
      BuildContext context, VisitOfferWallInternalState state) {
    if (state.visitOfferWallInternalStatus ==
        VisitOfferWallInternalStatus.loading) {
      return;
    }
    if (state.visitOfferWallInternalStatus ==
        VisitOfferWallInternalStatus.failure) {
      return;
    }
    if (state.visitOfferWallInternalStatus ==
        VisitOfferWallInternalStatus.success) {
      RxBus.post(UpdateUser());
      DialogUtils.showDialogMissingPoint(context, data: widget.data['reward'],
          voidCallback: () {
        Navigator.pop(context);
      });
    }
  }

  _buildContent(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.voidCallBack!();
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        key: globalKey,
        backgroundColor: AppColor.white,
        body: CustomWebView(
            title: '',
            urlLink: widget.data['api'],
            onClose: () {
              widget.voidCallBack!();
              Navigator.pop(context);
            }),
      ),
    );
  }
}
