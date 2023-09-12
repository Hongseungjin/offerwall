// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appStyle.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/hex_color.dart';
import 'package:sdk_eums/eum_app_offer_wall/widget/set_date_dialog.dart';

// import 'package:sdk_eums/eum_app_offer_wall/widget/set_date_dialog.dart';

import '../../utils/appColor.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool checkToken = false;
  bool checkTime = false;

  DateTime? startDate;
  DateTime? endDate;

  TimePickerEntryMode entryMode = TimePickerEntryMode.input;
  Orientation? orientation;

  @override
  void initState() {
    startDate = DateTime.now();
    endDate = DateTime.now();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
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
          '설정',
          style: AppStyle.bold.copyWith(color: Colors.black),
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
                  style: AppStyle.regular.copyWith(color: HexColor('#888888')),
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      checkToken = !checkToken;
                    });
                  },
                  child: _buildCheckSetting(
                      checkSetting: checkToken, title: '벌 광고 활성화'),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      checkTime = !checkTime;
                    });
                  },
                  child: _buildCheckSetting(
                      checkSetting: checkTime, title: '광고 시간대 설정'),
                ),
                const SizedBox(height: 7),
                Text(
                  '벌 광고를 받지 않을 시간을 설정합니다.',
                  style: AppStyle.regular.copyWith(color: HexColor('#888888')),
                ),
                const SizedBox(height: 20),
                if (!checkTime) ...{
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
                    Text('정보 수신 동의', style: AppStyle.bold),
                    const Spacer(),
                    Text(
                      '동의',
                      style: AppStyle.bold.copyWith(color: HexColor('#f4a43b')),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 16,
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Text('2018/07/29',
                    style:
                        AppStyle.regular.copyWith(color: HexColor('#888888'))),
                const SizedBox(height: 31),
                Row(
                  children: [
                    Text('버전정보', style: AppStyle.bold),
                    const Spacer(),
                    Text(
                      '최신 버전을 사용 중입니다.',
                      style: AppStyle.bold.copyWith(color: HexColor('#f4a43b')),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Ver 457.000.05',
                    style:
                        AppStyle.regular.copyWith(color: HexColor('#888888'))),
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
  }

  _buildSelectDate({int? dateNumber, String? title}) {
    DateTime date = DateTime.now();
    switch (dateNumber) {
      case 1:
        date = startDate ?? DateTime.now();
        break;
      case 2:
        date = endDate ?? DateTime.now();
        break;

      default:
    }
    return Column(children: [
      GestureDetector(
          onTap: () async {
            _selectDate(
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
                });
          },
          child: dateNumber == 1
              ? _buildViewDate(dateTime: startDate, title: title)
              : _buildViewDate(dateTime: endDate, title: title))
    ]);
  }

  _buildViewDate({DateTime? dateTime, String? title}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title ?? "",
          style: AppStyle.regular.copyWith(color: HexColor('#888888')),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: (MediaQuery.of(context).size.width - 32) / 2,
          child: Row(
            children: [
              Text('${dateTime!.hour < 0 ? 'AM' : 'PM'} '
                  '${dateTime.hour < 10 ? '0${dateTime.hour}' : dateTime.hour}:${dateTime.minute < 10 ? '0${dateTime.minute}' : dateTime.minute}'),
              const Spacer(),
              const Icon(Icons.keyboard_arrow_down_outlined)
            ],
          ),
        ),
      ],
    );
  }

  _selectDate({DateTime? dateTime, Function? callBack}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: 300,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    height: 220,
                    child: CupertinoDatePicker(
                      initialDateTime: dateTime,
                      mode: CupertinoDatePickerMode.time,
                      use24hFormat: false,
                      onDateTimeChanged: (DateTime newTime) {
                        setState(() => dateTime = newTime);
                      },
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                      onTap: () {
                        callBack!(dateTime);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: HexColor('#fdd000')),
                        child: Text(
                          '확인',
                          style: AppStyle.bold.copyWith(),
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

  _buildCheckSetting({bool checkSetting = false, String? title}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title ?? '',
          style: AppStyle.bold.copyWith(fontSize: 14),
        ),
        const Spacer(),
        Container(
          width: 55,
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: checkSetting ? HexColor('#cccccc') : HexColor('#fdd000')),
          child: Row(
            children: [
              checkSetting
                  ? Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.white,
                      ),
                      padding: const EdgeInsets.all(10),
                    )
                  : const SizedBox(),
              const Spacer(),
              checkSetting
                  ? const SizedBox()
                  : Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.white,
                      ),
                      padding: const EdgeInsets.all(10),
                    ),
            ],
          ),
        )
      ],
    );
  }
}
