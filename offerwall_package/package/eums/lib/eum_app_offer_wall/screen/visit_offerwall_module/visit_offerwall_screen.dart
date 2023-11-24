import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eums/common/rx_bus.dart';
import 'package:eums/eum_app_offer_wall/screen/visit_offerwall_module/bloc/visit_offerwall_bloc.dart';
import 'package:eums/eum_app_offer_wall/utils/loading_dialog.dart';
import 'package:eums/eum_app_offer_wall/widget/custom_dialog.dart';
import 'package:eums/eum_app_offer_wall/widget/custom_inappweb.dart';
import 'package:flutter_component/events/event_static_component.dart';

import '../../../common/events/rx_events.dart';

class VisitOfferWallScren extends StatefulWidget {
  VisitOfferWallScren({Key? key, this.data, this.voidCallBack}) : super(key: key);
  dynamic data;
  final Function? voidCallBack;
  @override
  State<VisitOfferWallScren> createState() => _VisitOfferWallScrenState();
}

class _VisitOfferWallScrenState extends State<VisitOfferWallScren> {
  final GlobalKey<State<StatefulWidget>> globalKey = GlobalKey<State<StatefulWidget>>();

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
          listenWhen: (previous, current) => previous.visitOfferWallInternalStatus != current.visitOfferWallInternalStatus,
          listener: _listenFetchData,
        ),
      ], child: _buildContent(context)),
    );
  }

  void _listenFetchData(BuildContext context, VisitOfferWallInternalState state) {
    if (state.visitOfferWallInternalStatus == VisitOfferWallInternalStatus.loading) {
      LoadingDialog.instance.show();
      return;
    }
    if (state.visitOfferWallInternalStatus == VisitOfferWallInternalStatus.failure) {
      LoadingDialog.instance.hide();
      return;
    }
    if (state.visitOfferWallInternalStatus == VisitOfferWallInternalStatus.success) {
      EventStaticComponent.instance.call(key: "UpdateUser");
      // RxBus.post(UpdateUser());
      LoadingDialog.instance.hide();
      DialogUtils.showDialogMissingPoint(context, data: widget.data['reward'], voidCallback: () {
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
        child: CustomInappWebView(
          onClose: () {
            widget.voidCallBack!();
          },
          urlLink: widget.data['api'],
        ));
  }
}
