import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sdk_eums/common/rx_bus.dart';
import 'package:sdk_eums/eum_app_offer_wall/screen/report_module/bloc/report_bloc.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appStyle.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/hex_color.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/loading_dialog.dart';
import 'package:sdk_eums/eum_app_offer_wall/widget/app_alert.dart';
import 'package:sdk_eums/gen/assets.gen.dart';

import '../../../common/events/events.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key, this.data, this.deleteAdver = false})
      : super(key: key);
  final dynamic data;
  final bool deleteAdver;

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final GlobalKey<State<StatefulWidget>> globalKey =
      GlobalKey<State<StatefulWidget>>();
  late String valueSelected = '';
  TextEditingController contentCtrl = TextEditingController();

  bool checkContent = false;
  int? indexReport;
  FToast fToast = FToast();
  @override
  void initState() {
    fToast.init(context);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(" widget.data${widget.data}");
    return BlocProvider<ReportBloc>(
      create: (context) => ReportBloc(),
      child: MultiBlocListener(
        listeners: [
          BlocListener<ReportBloc, ReportState>(
              listenWhen: (previous, current) =>
                  previous.reportStatus != current.reportStatus,
              listener: _listenReport),
          BlocListener<ReportBloc, ReportState>(
              listenWhen: (previous, current) =>
                  previous.deleteKeepStatus != current.deleteKeepStatus,
              listener: _listenDeleteKeep),
        ],
        child: WillPopScope(
            onWillPop: () async {
              return true;
            },
            child: _buildContent(context)),
      ),
    );
  }

  void _listenDeleteKeep(BuildContext context, ReportState state) {
    if (state.deleteKeepStatus == DeleteKeepStatus.loading) {
      LoadingDialog.instance.show();
      return;
    }
    if (state.deleteKeepStatus == DeleteKeepStatus.failure) {
      LoadingDialog.instance.hide();
      return;
    }
    if (state.deleteKeepStatus == DeleteKeepStatus.success) {
      LoadingDialog.instance.hide();
      AppAlert.showSuccess(context, fToast, 'Success');
      RxBus.post(RefreshDataKeep());
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }

  void _listenReport(BuildContext context, ReportState state) {
    if (state.reportStatus == ReportStatus.loading) {
      LoadingDialog.instance.show();
      return;
    }
    if (state.reportStatus == ReportStatus.failure) {
      AppAlert.showError(context, fToast, '이 광고를 신고했습니다');
      LoadingDialog.instance.hide();
      return;
    }
    if (state.reportStatus == ReportStatus.success) {
      LoadingDialog.instance.hide();
      if (widget.deleteAdver) {
        globalKey.currentContext
            ?.read<ReportBloc>()
            .add(DeleteKeep(advertise_idx: widget.data['advertiseIdx']));
      }
    }
  }

  _buildContent(BuildContext context) {
    return Scaffold(
      key: globalKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        title: Text(
          '신고하기',
          style: AppStyle.bold.copyWith(fontSize: 18, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '신고할 광고 정보',
                style: AppStyle.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                        width: 60,
                        height: 60,
                        fit: BoxFit.fitWidth,
                        imageUrl: widget.data['url_link'],
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) {
                          return Image.asset(Assets.logo.path,
                              package: "sdk_eums", height: 16);
                        }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.data['name'] ?? '',
                      style: AppStyle.bold.copyWith(fontSize: 18),
                    ),
                  )
                ],
              ),
            ),
            const Divider(
              thickness: 5,
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: RichText(
                  text: TextSpan(
                      text: '신고 사유 선택',
                      style: AppStyle.bold.copyWith(color: Colors.black),
                      children: [
                    TextSpan(
                        text: '(하나만 선택 가능해요)',
                        style: AppStyle.medium
                            .copyWith(fontSize: 12, color: HexColor('#888888')))
                  ])),
            ),
            const SizedBox(height: 12),
            Wrap(
              children: List.generate(listReprot.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      valueSelected = listReprot[index];
                      indexReport = index;
                    });
                  },
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    child: Row(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color:
                                            valueSelected == listReprot[index]
                                                ? Colors.amber
                                                : HexColor('#888888'))),
                                child: Container(
                                  height: 10,
                                  width: 10,
                                  decoration: BoxDecoration(
                                      color: valueSelected == listReprot[index]
                                          ? Colors.amber
                                          : Colors.transparent,
                                      shape: BoxShape.circle),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Text(
                                listReprot[index],
                                style: AppStyle.medium.copyWith(
                                    color: valueSelected == listReprot[index]
                                        ? Colors.black
                                        : HexColor('#888888'),
                                    fontSize: 16),
                              ),
                              index == 5
                                  ? Text(
                                      ' (직접 입력)',
                                      style: AppStyle.medium.copyWith(
                                          color: HexColor('#888888'),
                                          fontSize: 16),
                                    )
                                  : const SizedBox()
                            ]),
                      ],
                    ),
                  ),
                );
              }),
            ),
            valueSelected == listReprot.last
                ? Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                            color: AppColor.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: AppColor.color70.withOpacity(0.7))),
                        child: TextFormField(
                          controller: contentCtrl,
                          onChanged: (value) {
                            if (value != '') {
                              setState(() {
                                checkContent = true;
                              });
                            } else {
                              checkContent = false;
                            }
                            setState(() {});
                          },
                          maxLines: 5,
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              hintText: '관련 내용이 아니에요',
                              border: InputBorder.none,
                              hintStyle: AppStyle.bold.copyWith(
                                  color: AppColor.color70.withOpacity(0.7))),
                        ),
                      ),
                      !checkContent
                          ? const SizedBox()
                          : Positioned(
                              top: 10,
                              right: 20,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    checkContent = false;
                                    contentCtrl.clear();
                                  });
                                },
                                child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color: HexColor('#888888')
                                            .withOpacity(0.3),
                                        shape: BoxShape.circle),
                                    child: const Icon(
                                      Icons.close,
                                      size: 15,
                                      color: Colors.white,
                                    )),
                              ),
                            )
                    ],
                  )
                : const SizedBox(),
            GestureDetector(
              onTap: () {
                if (indexReport != null) {
                  FocusScope.of(context).unfocus();
                  if (valueSelected == listReprot.last) {
                    if (contentCtrl.text == '') {
                      AppAlert.showError(context, fToast, '신고사유를 적어주세요');
                    } else {
                      confimReport(reason: contentCtrl.text);
                    }
                    print(contentCtrl.text);
                  } else {
                    confimReport(reason: valueSelected);
                  }
                }
              },
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: valueSelected == listReprot[indexReport ?? 0]
                        ? Colors.amber
                        : HexColor('#888888')),
                child: Text(
                  '신고하기',
                  textAlign: TextAlign.center,
                  style: AppStyle.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  confimReport({dynamic reason}) {
    globalKey.currentContext?.read<ReportBloc>().add(ReportAdver(
        idx: widget.data['advertiseIdx'], reason: reason, type: 'advertise'
        //advertise, offerWall
        ));
  }
}

List<String> listReprot = [
  '비방, 욕설이 포함됨',
  '음란, 도박 등 불법성',
  '청소년 유해 매체',
  '도배성 컨텐츠',
  '저작권 등 지적 재산권 침해',
  '기타'
];
