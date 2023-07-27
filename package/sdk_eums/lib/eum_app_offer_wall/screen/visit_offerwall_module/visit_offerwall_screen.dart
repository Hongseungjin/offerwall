import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sdk_eums/common/rx_bus.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/visit_offerwall_module/bloc/visit_offerwall_bloc.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
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
      child: CustomWebView(
            title: '',
            urlLink: widget.data['api'],
            onClose: () {
              widget.voidCallBack!();
              Navigator.pop(context);
            }),
    );
  }
}
