import 'package:eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:eums/eum_app_offer_wall/widget/widget_animation_click.dart';
import 'package:eums/gen/assets.gen.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class WidgetSwipCheckBox extends StatefulWidget {
  WidgetSwipCheckBox({super.key, required this.valueDefault, required this.onChange});
  bool valueDefault;
  final Function(bool value) onChange;

  @override
  State<WidgetSwipCheckBox> createState() => _WidgetSwipCheckBoxState();
}

class _WidgetSwipCheckBoxState extends State<WidgetSwipCheckBox> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetAnimationClick(
      onTap: () async {
        setState(() {
          widget.valueDefault = !widget.valueDefault;
        });
        widget.onChange.call(widget.valueDefault);

        // setState(() {
        //   isdisable = !isdisable;
        // });
        // localStore.setSaveAdver(isdisable);
        // if (isdisable) {
        //   String? token = await FirebaseMessaging.instance.getToken();

        //   await EumsOfferWallServiceApi().unRegisterTokenNotifi(token: token);
        //   FlutterBackgroundService().invoke("stopService");
        // } else {
        //   dynamic data = <String, dynamic>{
        //     'count': 0,
        //     'date': Constants.formatTime(DateTime.now().toIso8601String()),
        //   };
        //   // localStore?.setCountAdvertisement(data);
        //   String? token = await FirebaseMessaging.instance.getToken();
        //   await EumsOfferWallServiceApi().createTokenNotifi(token: token);
        //   bool isRunning = await FlutterBackgroundService().isRunning();
        //   if (!isRunning) {
        //     FlutterBackgroundService().startService();
        //   }
        // }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
        width: 34,
        decoration: BoxDecoration(
            color: widget.valueDefault ? AppColor.orange2 : AppColor.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: widget.valueDefault ? Colors.transparent : AppColor.color70)),
        child: Row(
          children: [
            widget.valueDefault
                ? const SizedBox()
                : Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.color70,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Assets.icons.check.image(height: 7, color: Colors.transparent),
                    // child: Image.asset(
                    //   Assets.check.path,
                    //   package: "eums",
                    //   height: 7,
                    //   color: Colors.transparent,
                    // ),
                  ),
            const Spacer(),
            widget.valueDefault
                ? Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.white,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Assets.icons.check.image(height: 7, color: Colors.transparent),
                    // child: Image.asset(
                    //   Assets.check.path,
                    //   package: "eums",
                    //   height: 7,
                    //   color: Colors.transparent,
                    // ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
