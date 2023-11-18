import 'dart:io';

import 'package:eums/eum_app_offer_wall/widget/widget_animation_click.dart';
import 'package:eums/gen/style_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WidgetDialogCheckVersion {
  static Future show(BuildContext context, ) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          insetAnimationCurve: Curves.bounceIn,
          backgroundColor: Colors.white,
          
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_upload_outlined,
                      color: Colors.orange,
                      size: 30,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Text(
                      'CHECK UPDATE',
                      style: StyleFont.regular().copyWith(height: 1.3),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Text(
                      '계속 사용하려면 애플리케이션을 업데이트하세요.',
                      style: StyleFont.regular().copyWith(height: 1.3),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    WidgetAnimationClick(
                      onTap: () {
                        if (Platform.isAndroid) {
                          SystemNavigator.pop();
                        } else {
                          exit(0);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey)),
                        child: const Text(
                          "Cancel",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
          // title: Text(
          //   'Permission Location Always',
          //   style: StyleFont.bold(),
          // ),
          // content: Text(
          //   '선호하는 것에 따라 광고를 수신하려면 항상 위치 권한을 허용해야 합니다.',
          //   style: StyleFont.regular(),
          // ),
          // actions: <Widget>[
          //   WidgetAnimationClick(
          //     onTap: () {
          //       onCancel?.call();
          //       Navigator.of(context).pop(false);
          //     },
          //     child: const Padding(
          //       padding: EdgeInsets.all(5.0),
          //       child: Text(
          //         "Cancel",
          //         style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w400, fontSize: 16),
          //       ),
          //     ),
          //   ),
          //   WidgetAnimationClick(
          //     onTap: () {
          //       onAccept.call();
          //       Navigator.of(context).pop(true);
          //     },
          //     child: const Padding(
          //       padding: EdgeInsets.all(5.0),
          //       child: Text(
          //         "Enable",
          //         style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w700, fontSize: 16),
          //       ),
          //     ),
          //   ),

          // ],
        );
      },
    );
  }
}
