// import 'package:flutter/cupertino.dart';

import 'package:eums/eum_app_offer_wall/widget/check_box/widget_swip_check_box.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/instance_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:eums/common/local_store/local_store.dart';
import 'package:eums/common/local_store/local_store_service.dart';
import 'package:eums/eum_app_offer_wall/utils/appStyle.dart';
import 'package:eums/eum_app_offer_wall/utils/hex_color.dart';
import 'package:eums/eum_app_offer_wall/utils/loading_dialog.dart';
import 'package:eums/eum_app_offer_wall/widget/set_date_dialog.dart';
import 'package:eums/eum_app_offer_wall/widget/setting_fontsize.dart';

// import 'package:eums/eum_app_offer_wall/widget/set_date_dialog.dart';

import 'bloc/setting_bloc.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final GlobalKey<State<StatefulWidget>> globalKey = GlobalKey<State<StatefulWidget>>();
  bool checkToken = false;
  bool checkTime = false;

  // LocalStore? localStore;
  DateTime? startDate;
  DateTime? endDate;

  TimePickerEntryMode entryMode = TimePickerEntryMode.input;
  Orientation? orientation;
  String? version;
  final controllerGet = Get.put(SettingFontSize());

  @override
  void initState() {
    // localStore = LocalStoreService();
    startDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    endDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59);
    checkBoolTime();
    checkVersionApp();

    super.initState();
  }

  checkBoolTime() async {
    checkTime = await LocalStoreService.instant.getBoolTime();
    checkToken =  LocalStoreService.instant.getSaveAdver();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingBloc>(
      create: (context) => SettingBloc()..add(GetSettingTime())
      // ..add(GetTotalPoint())
      // ..add(ListBanner(type: 'main'))
      // ..add(ListOfferWall(category: categary, filter: filter))
      ,
      child: MultiBlocListener(
        listeners: [
          BlocListener<SettingBloc, SettingState>(
            listenWhen: (previous, current) => previous.settingStatus != current.settingStatus,
            listener: _listenSettingTime,
          ),
          BlocListener<SettingBloc, SettingState>(
            listenWhen: (previous, current) => previous.updateSettingStatus != current.updateSettingStatus,
            listener: _listenUpdateSettingStatus,
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

  void _listenUpdateSettingStatus(BuildContext context, SettingState state) {
    if (state.updateSettingStatus == UpdateSettingStatus.loading) {
      LoadingDialog.instance.show();
      return;
    }
    if (state.updateSettingStatus == UpdateSettingStatus.failure) {
      LoadingDialog.instance.hide();
      return;
    }
    if (state.updateSettingStatus == UpdateSettingStatus.success) {
      LoadingDialog.instance.hide();
      globalKey.currentContext?.read<SettingBloc>().add(GetSettingTime());
    }
  }

  void _listenSettingTime(BuildContext context, SettingState state) {}

  checkVersionApp() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
  }

  _buildContent(BuildContext context) {
    return BlocBuilder<SettingBloc, SettingState>(
      builder: (context, state) {
        try {
          // startDate = state.dataSetting != null ? DateTime.tryParse(state.dataSetting['startTimeCron']) : startDate;
          // endDate = state.dataSetting != null ? DateTime.tryParse(state.dataSetting['endTimeCron']) : endDate;
          if (state.dataSetting != null) {
            final startData = state.dataSetting['startTime'];
            final endData = state.dataSetting['endTime'];
            startDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, startData['hours'], startData['minutes']);
            endDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, endData['hours'], endData['minutes']);
          }
        } catch (ex) {}

        return Scaffold(
          key: globalKey,
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
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
              '설정',
              style: AppStyle.bold.copyWith(color: Colors.black, fontSize: 4 + controllerGet.fontSizeObx.value),
            ),
          ),
          body: Column(
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '마케팅 알림',
                      style: AppStyle.regular.copyWith(color: HexColor('#888888'), fontSize: controllerGet.fontSizeObx.value),
                    ),
                    const SizedBox(height: 15),
                    _buildCheckSetting(
                      checkSetting: checkToken,
                      title: '벌 광고 활성화',
                      onChange: (value) async {
                        setState(() {
                          checkToken = value;
                        });
                        await LocalStoreService.instant.setSaveAdver(checkToken);

                        if (!checkToken) {
                          String? token = await FirebaseMessaging.instance.getToken();

                          await EumsOfferWallServiceApi().unRegisterTokenNotifi(token: token);
                          FlutterBackgroundService().invoke("stopService");
                        } else {
                          // dynamic data = <String, dynamic>{
                          //   'count': 0,
                          //   'date': Constants.formatTime(
                          //       DateTime.now().toIso8601String()),
                          // };
                          // localStore?.setCountAdvertisement(data);
                          String? token = await FirebaseMessaging.instance.getToken();
                          await EumsOfferWallServiceApi().createTokenNotifi(token: token);
                          bool isRunning = await FlutterBackgroundService().isRunning();
                          if (!isRunning) {
                            FlutterBackgroundService().startService();
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 30),
                    _buildCheckSetting(
                      checkSetting: checkTime,
                      title: '광고 시간대 설정',
                      onChange: (value) async{
                        setState(() {
                          checkTime = value;
                        });
                        await LocalStoreService.instant.setBoolTime(checkTime);

                        globalKey.currentContext?.read<SettingBloc>().add(EnableOrDisbleSetting(enableOrDisble: checkTime));
                      },
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '벌 광고를 받지 않을 시간을 설정합니다.',
                      style: AppStyle.regular.copyWith(color: HexColor('#888888'), fontSize: controllerGet.fontSizeObx.value),
                    ),
                    const SizedBox(height: 20),
                    if (checkTime) ...{
                      Row(
                        children: [
                          _buildSelectDate(dateNumber: 1, title: '시작 시간'),
                          _buildSelectDate(dateNumber: 2, title: '종료 시간'),
                        ],
                      ),
                    }
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Divider(
                thickness: 5,
                height: 0,
                color: HexColor('#e5e5e5'),
              ),
              Divider(
                height: 1,
                thickness: 5,
                color: HexColor('#f4f4f4'),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('정보 수신 동의', style: AppStyle.bold.copyWith(fontSize: controllerGet.fontSizeObx.value)),
                        const Spacer(),
                        Text(
                          '동의',
                          style: AppStyle.bold.copyWith(color: HexColor('#f4a43b'), fontSize: controllerGet.fontSizeObx.value),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_outlined,
                          size: 16,
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('2018/07/29', style: AppStyle.regular.copyWith(color: HexColor('#888888'), fontSize: controllerGet.fontSizeObx.value)),
                    const SizedBox(height: 31),
                    Row(
                      children: [
                        Text('버전정보', style: AppStyle.bold.copyWith(fontSize: controllerGet.fontSizeObx.value)),
                        const Spacer(),
                        Text(
                          '최신 버전을 사용 중입니다.',
                          style: AppStyle.bold.copyWith(color: HexColor('#f4a43b'), fontSize: controllerGet.fontSizeObx.value),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Ver ${version ?? ''}',
                        style: AppStyle.regular.copyWith(color: HexColor('#888888'), fontSize: controllerGet.fontSizeObx.value)),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Divider(
                thickness: 5,
                height: 0,
                color: HexColor('#e5e5e5'),
              ),
              Divider(
                height: 1,
                thickness: 5,
                color: HexColor('#f4f4f4'),
              ),
            ],
          ),
        );
      },
    );
  }

  _buildSelectDate({required int dateNumber, String? title}) {
    DateTime date = DateTime.now();
    switch (dateNumber) {
      case 1:
        date = startDate!;
        break;
      case 2:
        date = endDate!;
        break;

      default:
    }
    return Column(children: [
      InkWell(
          onTap: () async {
            _selectDate(
                index: dateNumber,
                dateTime: date,
                callBack: (value) {
                  switch (dateNumber) {
                    case 1:
                      startDate = value;
                      break;
                    case 2:
                      endDate = value;
                      break;
                    default:
                  }
                  setState(() {});
                  createOrUpdateSettingTime(startTime: startDate, endTime: endDate);
                });
          },
          child: dateNumber == 1 ? _buildViewDate(dateTime: startDate, title: title) : _buildViewDate(dateTime: endDate, title: title))
    ]);
  }

  createOrUpdateSettingTime({DateTime? startTime, DateTime? endTime}) {
    try {
      globalKey.currentContext?.read<SettingBloc>().add(SettingTime(startTime: startTime, endTime: endTime));
    } catch (ex) {}
  }

  _buildViewDate({DateTime? dateTime, String? title}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title ?? "",
          style: AppStyle.regular.copyWith(color: HexColor('#888888'), fontSize: controllerGet.fontSizeObx.value),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: (MediaQuery.of(context).size.width - 32) / 2,
          child: Row(
            children: [
              Text(
                // '${dateTime!.hour < 10 ? 'AM' : 'PM'} '
                '${dateTime!.hour < 10 ? '0${dateTime.hour}' : dateTime.hour}:${dateTime.minute < 10 ? '0${dateTime.minute}' : dateTime.minute}',
                style: AppStyle.regular.copyWith(fontSize: controllerGet.fontSizeObx.value),
              ),
              const Spacer(),
              const Icon(Icons.keyboard_arrow_down_outlined)
            ],
          ),
        ),
      ],
    );
  }

  _selectDate({required int index, DateTime? dateTime, Function? callBack}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        // final timeEnd = endDate?.add(const Duration(days: -1));
        // final timeStart = startDate?.add(const Duration(days: 1));
        final timeEnd = endDate;
        final timeStart = startDate;
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 150,
                    child: CupertinoDatePicker(
                      initialDateTime: dateTime,
                      minimumDate: index == 2 && timeStart != null ? timeStart : null,
                      maximumDate: index == 1 && timeEnd != null ? timeEnd : null,
                      mode: CupertinoDatePickerMode.time,
                      use24hFormat: true,
                      onDateTimeChanged: (DateTime newTime) {
                        setState(() => dateTime = newTime);
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  InkWell(
                      onTap: () {
                        callBack!(dateTime);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: HexColor('#fdd000')),
                        child: Text(
                          '확인',
                          style: AppStyle.bold.copyWith(fontSize: controllerGet.fontSizeObx.value),
                          textAlign: TextAlign.center,
                        ),
                      ))
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _buildCheckSetting({bool checkSetting = false, String? title, required Function(bool value) onChange}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Text(
            title ?? '',
            style: AppStyle.bold.copyWith(fontSize: controllerGet.fontSizeObx.value),
          ),
        ),
        const SizedBox(
          width: 10,
        ),

        WidgetSwipCheckBox(
          valueDefault: checkSetting,
          onChange: (value) async {
            onChange.call(value);
          },
        ),

        // Container(
        //   width: 55,
        //   padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
        //   decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: !checkSetting ? HexColor('#cccccc') : HexColor('#fdd000')),
        //   child: Row(
        //     children: [
        //       !checkSetting
        //           ? Container(
        //               decoration: const BoxDecoration(
        //                 shape: BoxShape.circle,
        //                 color: AppColor.white,
        //               ),
        //               padding: const EdgeInsets.all(10),
        //             )
        //           : const SizedBox(),
        //       const Spacer(),
        //       !checkSetting
        //           ? const SizedBox()
        //           : Container(
        //               decoration: const BoxDecoration(
        //                 shape: BoxShape.circle,
        //                 color: AppColor.white,
        //               ),
        //               padding: const EdgeInsets.all(10),
        //             ),
        //     ],
        //   ),
        // )
      ],
    );
  }
}
