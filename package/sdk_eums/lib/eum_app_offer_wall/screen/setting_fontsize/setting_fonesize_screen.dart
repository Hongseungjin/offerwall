import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sdk_eums/common/local_store/local_store.dart';
import 'package:sdk_eums/common/local_store/local_store_service.dart';
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

  final SfRangeValues _dataValues = const SfRangeValues(1, 4);
  LocalStore localStore = LocalStoreService();

  double _value = 1;
  @override
  void initState() {
    getSize();
    // TODO: implement initState
    super.initState();
  }

  getSize() async {
    switch ((double.parse(await localStore.getSizeText())).toInt()) {
      case 14:
        _value = 1;
        break;
      case 16:
        _value = 2;
        break;
      case 18:
        _value = 3;
        break;
      case 20:
        _value = 4;
        break;
      default:
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          appBar: AppBar(),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  "마케팅 알림${controller.fontSizeObx.value}",
                  style: AppStyle.medium.copyWith(fontSize: 14),
                ),
                Text(
                  "마케팅 알림$_value",
                  style: AppStyle.medium
                      .copyWith(fontSize: controller.fontSizeObx.value),
                ),
                SizedBox(height: 19),
                SfSlider(
                  min: 1.0,
                  max: 4.0,
                  value: _value,
                  interval: 1,
                  stepSize: 1,
                  showTicks: true,
                  showLabels: true,
                  onChanged: (dynamic value) {
                    setState(() {
                      _value = value;
                    });
                    controller.increaseSize(_value);
                  },
                ),
              ],
            ),
          ),
        ));
  }
}
