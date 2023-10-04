import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appStyle.dart';
import 'package:sdk_eums/eum_app_offer_wall/widget/setting_fontsize.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class SettingFontSizeScreen extends StatefulWidget {
  const SettingFontSizeScreen({Key? key}) : super(key: key);

  @override
  State<SettingFontSizeScreen> createState() => _SettingFontSizeScreenState();
}

class _SettingFontSizeScreenState extends State<SettingFontSizeScreen> {
  final controller = Get.put(SettingFontSize());

  final SfRangeValues _dataValues = const SfRangeValues(1, 5);

  double _value = 1;
  double _valueStart = 0;
  double _valueEnd = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          appBar: AppBar(),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  "마케팅 알림",
                  style: AppStyle.medium.copyWith(fontSize: 14),
                ),
                Text(
                  "마케팅 알림",
                  style: AppStyle.medium
                      .copyWith(fontSize: 14 + controller.fontSizeObx!.value),
                ),
                SizedBox(height: 19),
                SfSlider(
                  min: 1.0,
                  max: 5.0,
                  value: _value,
                  interval: 1,
                  stepSize: 1,
                  showTicks: true,
                  showLabels: true,
                  // enableTooltip: true,
                  // shouldAlwaysShowTooltip: true,
                  onChangeStart: (value) {
                    setState(() {
                      _valueStart = value;
                    });
                  },
                  onChangeEnd: (value) {
                    setState(() {
                      _valueEnd = value;
                    });
                  },
                  onChanged: (dynamic value) {
                    setState(() {
                      _value = value;
                    });

                    if (_value < _valueStart) {
                      controller.decreaseSize(_valueStart);
                    } else {
                      controller.increaseSize(_value);
                    }
                  },
                ),
              ],
            ),
          ),
        ));
  }
}
