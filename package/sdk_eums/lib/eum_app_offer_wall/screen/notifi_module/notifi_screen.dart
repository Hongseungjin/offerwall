import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sdk_eums/common/constants.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appStyle.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/hex_color.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/loading_dialog.dart';

import 'bloc/notifi_bloc.dart';

class NotifiScreen extends StatefulWidget {
  const NotifiScreen({Key? key}) : super(key: key);

  @override
  State<NotifiScreen> createState() => _NotifiScreenState();
}

class _NotifiScreenState extends State<NotifiScreen> {
  final GlobalKey<State<StatefulWidget>> globalKey =
      GlobalKey<State<StatefulWidget>>();
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  final Set<dynamic> _saved = Set<dynamic>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotifiBloc>(
      create: (context) => NotifiBloc()..add(ListNotifi(limit: 10)),
      child: MultiBlocListener(
        listeners: [
          BlocListener<NotifiBloc, NotifiState>(
            listenWhen: (previous, current) =>
                previous.listNotifiStatus != current.listNotifiStatus,
            listener: _listenListNotifi,
          ),
          BlocListener<NotifiBloc, NotifiState>(
            listenWhen: (previous, current) =>
                previous.loaMoreListNotifiStatus !=
                current.loaMoreListNotifiStatus,
            listener: _listenLoaMoreListNotif,
          ),
        ],
        child: WillPopScope(
            onWillPop: () async {
              return true;
            },
            child: _buildContent(context)),
      ),
    );
  }

  _buildContent(BuildContext context) {
    return BlocBuilder<NotifiBloc, NotifiState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          key: globalKey,
          appBar: AppBar(
            backgroundColor: AppColor.white,
            elevation: 0,
            centerTitle: true,
            title: Text('공지사항',
                style: AppStyle.bold
                    .copyWith(fontSize: 16, color: AppColor.black)),
            leading: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Icon(Icons.arrow_back_ios_outlined,
                  color: AppColor.dark, size: 25),
            ),
          ),
          body: SmartRefresher(
            controller: refreshController,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            header: CustomHeader(
              builder: (BuildContext context, RefreshStatus? mode) {
                return const Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.black)));
              },
            ),
            footer: CustomFooter(
              builder: (BuildContext context, LoadStatus? mode) {
                return mode == LoadStatus.loading
                    ? Center(
                        child: Column(
                        children: [
                          Text(' '),
                          CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.black)),
                        ],
                      ))
                    : const SizedBox();
              },
            ),
            enablePullDown: true,
            enablePullUp: true,
            child: state.dataNotifi != null
                ? Wrap(
                    children: List.generate(
                        state.dataNotifi?.length ?? 0,
                        (index) => Container(
                              child: _buildItem(data: state.dataNotifi[index]),
                            )),
                  )
                : SizedBox(),
          ),
        );
      },
    );
  }

  _buildItem({dynamic data}) {
    bool isShowDes = _saved.contains(data);
    return Column(
      children: [
        InkWell(
          onTap: () {
            if (isShowDes) {
              setState(() {
                _saved.remove(data);
              });
            } else {
              setState(() {
                _saved.add(data);
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: HexColor('#fdd000')),
                  child: Text(
                    '공지',
                    style: AppStyle.bold
                        .copyWith(fontSize: 12, color: AppColor.black),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${data['title']}',
                      style: AppStyle.bold
                          .copyWith(color: Colors.black, fontSize: 14),
                    ),
                    Text(
                      Constants.formatTime(data['registDate']),
                      style: AppStyle.regular
                          .copyWith(color: HexColor('#888888'), fontSize: 12),
                    )
                  ],
                ),
                Spacer(),
                Icon(
                  !isShowDes
                      ? Icons.keyboard_arrow_down_outlined
                      : Icons.keyboard_arrow_up_outlined,
                  size: 16,
                )
              ],
            ),
          ),
        ),
        if (isShowDes) ...{
          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: HexColor('#f9f9f9'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '적립 방법',
                  style: AppStyle.bold
                      .copyWith(fontSize: 18, color: AppColor.black),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: buidlHtml(html: data != null ? data['content'] : ''),
                ),
              ],
            ),
          ),
          const Divider(
            height: 0,
          )
        } else ...{
          const Divider(
            height: 0,
          )
        }
      ],
    );
  }

  buidlHtml({String? html}) {
    return HtmlWidget(
      html ?? '',
      customStylesBuilder: (e) {
        if (e.classes.contains('ql-align-center')) {
          return {'text-align': 'center'};
        }

        return null;
      },
    );
  }

  void _onRefresh() async {
    await Future.delayed(const Duration(seconds: 0));
    refreshController.refreshCompleted();
    setState(() {});
    globalKey.currentContext?.read<NotifiBloc>().add(ListNotifi(limit: 10));
  }

  void _onLoading() async {
    await Future.delayed(const Duration(seconds: 0));
    refreshController.loadComplete();
    List<dynamic>? dataCampaign =
        globalKey.currentContext?.read<NotifiBloc>().state.dataNotifi;
    if (dataCampaign != null) {
      globalKey.currentContext
          ?.read<NotifiBloc>()
          .add(LoadMoreListNotifi(limit: 10, offset: dataCampaign.length));
    }
  }

  void _listenListNotifi(BuildContext context, NotifiState state) {
    if (state.listNotifiStatus == ListNotifiStatus.loading) {
      LoadingDialog.instance.show();
      return;
    }
    if (state.listNotifiStatus == ListNotifiStatus.failure) {
      LoadingDialog.instance.hide();
      return;
    }
    if (state.listNotifiStatus == ListNotifiStatus.success) {
      LoadingDialog.instance.hide();
    }
  }

  void _listenLoaMoreListNotif(BuildContext context, NotifiState state) {
    if (state.loaMoreListNotifiStatus == LoaMoreListNotifiStatus.loading) {
      return;
    }
    if (state.loaMoreListNotifiStatus == LoaMoreListNotifiStatus.failure) {
      return;
    }
    if (state.loaMoreListNotifiStatus == LoaMoreListNotifiStatus.success) {}
  }
}
