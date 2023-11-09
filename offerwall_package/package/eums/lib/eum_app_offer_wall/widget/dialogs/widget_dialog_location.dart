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
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancel'),
              onPressed: () {
                onCancel?.call();
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Enable'),
              onPressed: () {
                onAccept.call();
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
}
