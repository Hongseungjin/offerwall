import 'package:cached_network_image/cached_network_image.dart';
import 'package:eums/eum_app_offer_wall/eums_app.dart';
import 'package:eums/eum_app_offer_wall/widget/toast/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/instance_manager.dart';
import 'package:eums/common/events/rx_events.dart';
import 'package:eums/common/rx_bus.dart';
import 'package:eums/eum_app_offer_wall/screen/report_module/bloc/report_bloc.dart';
import 'package:eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:eums/eum_app_offer_wall/utils/appStyle.dart';
import 'package:eums/eum_app_offer_wall/utils/hex_color.dart';
import 'package:eums/eum_app_offer_wall/utils/loading_dialog.dart';
import 'package:eums/eum_app_offer_wall/widget/setting_fontsize.dart';
import 'package:eums/gen/assets.gen.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key, this.data, this.deleteAdver = false, this.paddingTop = 0, this.checkOverlay = false}) : super(key: key);
  final dynamic data;
  final bool deleteAdver;
  final double paddingTop;
  final bool checkOverlay;

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final GlobalKey<State<StatefulWidget>> globalKey = GlobalKey<State<StatefulWidget>>();
  late String valueSelected = '';
  TextEditingController contentCtrl = TextEditingController();

  bool checkContent = false;
  int? indexReport;
  // FToast fToast = FToast();
  final controllerGet = Get.put(SettingFontSize());
  @override
  void initState() {
    // fToast.init(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print(" widget.data${widget.data}");
    return BlocProvider<ReportBloc>(
      create: (context) => ReportBloc(),
      child: MultiBlocListener(
        listeners: [
          BlocListener<ReportBloc, ReportState>(
              listenWhen: (previous, current) => previous.reportStatus != current.reportStatus, listener: _listenReport),
          BlocListener<ReportBloc, ReportState>(
              listenWhen: (previous, current) => previous.deleteKeepStatus != current.deleteKeepStatus, listener: _listenDeleteKeep),
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
      // if (!widget.checkOverlay) {
      // LoadingDialog.instance.show();
      // }
      return;
    }
    if (state.deleteKeepStatus == DeleteKeepStatus.failure) {
      // if (!widget.checkOverlay) {
      // LoadingDialog.instance.hide();
      // }
      return;
    }
    if (state.deleteKeepStatus == DeleteKeepStatus.success) {
      if (!widget.checkOverlay) {
        LoadingDialog.instance.hide();
      }
      // AppAlert.showSuccess(context, fToast, 'Success');

      RxBus.post(RefreshDataKeep());
      // Navigator.pop(context);
      // if (widget.checkOverlay == false) {
      //   Navigator.pop(context);
      // }
    }
  }

  void _listenReport(BuildContext context, ReportState state) async {
    if (state.reportStatus == ReportStatus.loading) {
      // if (!widget.checkOverlay) {
      //   LoadingDialog.instance.show();
      // }
      LoadingDialog.instance.show();

      return;
    }
    if (state.reportStatus == ReportStatus.failure) {
      LoadingDialog.instance.hide();

      // AppAlert.showError(context, fToast, '이 광고를 신고했습니다');
      AppAlert.showError('이 광고를 신고했습니다');
      // if (widget.checkOverlay) {
      //   LoadingDialog.instance.hide();
      // }
      return;
    }
    if (state.reportStatus == ReportStatus.success) {
      Navigator.pop(context, true);
      if (widget.checkOverlay == false) {
        Navigator.pop(context);
      }
      if (widget.deleteAdver) {
        globalKey.currentContext
            ?.read<ReportBloc>()
            // .add(DeleteKeep(advertise_idx: widget.checkOverlay ? widget.data['idx'] : widget.data['advertiseIdx']));
            .add(DeleteKeep(idx: widget.data['idx']));
      }
      if (widget.checkOverlay) {
        // LoadingDialog.instance.hide();
        FlutterBackgroundService().invoke("closeOverlay");
        // await EumsApp.instant.closeOverlay();
        await Future.delayed(const Duration(seconds: 1));
        dynamic dataToast = {};
        dataToast['isToast'] = true;
        dataToast['isWebView'] = null;
        // dataToast['messageToast'] = "광고 보관 완료 후 3일 이내에 받아주세요";
        dataToast['messageToast'] = "Report success";
        FlutterBackgroundService().invoke("showOverlay", {'data': dataToast});
        // await EumsApp.instant.jobQueue({'data': dataToast});
      } else {
        // AppAlert.showSuccess(context, fToast, 'Success');
        AppAlert.showSuccess('Success');
      }
    }
  }

  _buildContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: widget.paddingTop),
      child: Scaffold(
        key: globalKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: InkWell(
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
            style: AppStyle.bold.copyWith(fontSize: 4 + controllerGet.fontSizeObx.value, color: Colors.black),
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
                  style: AppStyle.bold.copyWith(fontSize: controllerGet.fontSizeObx.value),
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
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) {
                            return Image.asset(Assets.logo.path, package: "eums", height: 16);
                          }),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.data['name'] ?? '',
                        style: AppStyle.bold.copyWith(fontSize: 4 + controllerGet.fontSizeObx.value),
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
                        style: AppStyle.bold.copyWith(color: Colors.black, fontSize: controllerGet.fontSizeObx.value),
                        children: [
                      TextSpan(
                          text: '(하나만 선택 가능해요)',
                          style: AppStyle.medium.copyWith(fontSize: controllerGet.fontSizeObx.value - 2, color: HexColor('#888888')))
                    ])),
              ),
              const SizedBox(height: 12),
              Wrap(
                children: List.generate(listReprot.length, (index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        valueSelected = listReprot[index];
                        indexReport = index;
                      });
                    },
                    child: Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      child: Row(
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: valueSelected == listReprot[index] ? Colors.amber : HexColor('#888888'))),
                              child: Container(
                                height: 10,
                                width: 10,
                                decoration: BoxDecoration(
                                    color: valueSelected == listReprot[index] ? Colors.amber : Colors.transparent, shape: BoxShape.circle),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Text(
                              listReprot[index],
                              style: AppStyle.medium.copyWith(
                                  color: valueSelected == listReprot[index] ? Colors.black : HexColor('#888888'),
                                  fontSize: controllerGet.fontSizeObx.value + 2),
                            ),
                            index == 5
                                ? Text(
                                    ' (직접 입력)',
                                    style: AppStyle.medium.copyWith(color: HexColor('#888888'), fontSize: 2 + controllerGet.fontSizeObx.value),
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
                              border: Border.all(color: AppColor.color70.withOpacity(0.7))),
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
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                hintText: '관련 내용이 아니에요',
                                border: InputBorder.none,
                                hintStyle:
                                    AppStyle.bold.copyWith(fontSize: controllerGet.fontSizeObx.value, color: AppColor.color70.withOpacity(0.7))),
                          ),
                        ),
                        !checkContent
                            ? const SizedBox()
                            : Positioned(
                                top: 10,
                                right: 20,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      checkContent = false;
                                      contentCtrl.clear();
                                    });
                                  },
                                  child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(color: HexColor('#888888').withOpacity(0.3), shape: BoxShape.circle),
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
              InkWell(
                onTap: () {
                  if (indexReport != null) {
                    FocusScope.of(context).unfocus();
                    if (valueSelected == listReprot.last) {
                      if (contentCtrl.text == '') {
                        // AppAlert.showError(context, fToast, '신고사유를 적어주세요');
                        AppAlert.showError('신고사유를 적어주세요');
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
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: valueSelected == listReprot[indexReport ?? 0] ? Colors.amber : HexColor('#888888')),
                  child: Text(
                    '신고하기',
                    textAlign: TextAlign.center,
                    style: AppStyle.bold.copyWith(fontSize: controllerGet.fontSizeObx.value),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  confimReport({dynamic reason}) {
    globalKey.currentContext
        ?.read<ReportBloc>()
        .add(ReportAdver(idx: widget.checkOverlay ? widget.data['idx'] : widget.data['advertiseIdx'], reason: reason, type: 'advertise'
            //advertise, offerWall
            ));
  }
}

List<String> listReprot = ['비방, 욕설이 포함됨', '음란, 도박 등 불법성', '청소년 유해 매체', '도배성 컨텐츠', '저작권 등 지적 재산권 침해', '기타'];
