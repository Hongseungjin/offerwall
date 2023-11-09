import 'package:eums/eum_app_offer_wall/widget/custom_animation_click.dart';
import 'package:eums/gen/style_font.dart';
import 'package:flutter/material.dart';

class WidgetDialogLocation {
  static Future show(BuildContext context, {required Function() onAccept, Function()? onCancel}) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Permission Location Always',
            style: StyleFont.bold(),
          ),
          content: Text(
            '선호하는 것에 따라 광고를 수신하려면 항상 위치 권한을 허용해야 합니다.',
            style: StyleFont.regular(),
          ),
          actions: <Widget>[
            WidgetAnimationClick(
              onTap: () {
                onCancel?.call();
                Navigator.of(context).pop(false);
              },
              child: const Padding(
                padding: EdgeInsets.all(5.0),
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w400, fontSize: 16),
                ),
              ),
            ),
            WidgetAnimationClick(
              onTap: () {
                onAccept.call();
                Navigator.of(context).pop(true);
              },
              child: const Padding(
                padding: EdgeInsets.all(5.0),
                child: Text(
                  "Enable",
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
