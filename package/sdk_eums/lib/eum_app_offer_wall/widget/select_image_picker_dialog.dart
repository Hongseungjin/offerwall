
import 'package:flutter/material.dart';

import '../utils/appColor.dart';
import '../utils/appStyle.dart';

class SelectImgPickerDialog extends StatefulWidget {
  const SelectImgPickerDialog({
    Key? key,
    this.openCameraTap,
    this.chooseImgTap,
  });

  final Function? openCameraTap;
  final Function? chooseImgTap;

  static void show(BuildContext context,
      {Function? openCameraTap, Function? chooseImgTap, Function? cancelTap}) {
    showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black.withOpacity(0.7),
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (buildContext, animation, secondaryAnimation) {
          return SelectImgPickerDialog(
            openCameraTap: openCameraTap,
            chooseImgTap: chooseImgTap,
          );
        });
  }

  @override
  _SelectImgPickerDialogState createState() => _SelectImgPickerDialogState();
}

class _SelectImgPickerDialogState extends State<SelectImgPickerDialog> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
            bottom: MediaQuery.of(context).padding.bottom,
            left: 0,
            child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        if (widget.openCameraTap != null) {
                          widget.openCameraTap!();
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(top: 10),
                        width: MediaQuery.of(context).size.width,
                        child: Text('사진촬영', style: AppStyle.bold.copyWith(color: AppColor.black, fontSize: 16),),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        if (widget.chooseImgTap != null) {
                          widget.chooseImgTap!();
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(top: 10),
                        width: MediaQuery.of(context).size.width,
                        child: Text('사진 선택', style: AppStyle.bold.copyWith(color: AppColor.black, fontSize: 16)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(top: 10),
                        width: MediaQuery.of(context).size.width,
                        child: Text('취소', style: AppStyle.bold.copyWith(color: AppColor.black, fontSize: 16)),
                      ),
                    ),
                  ],
                )))
      ],
    );
  }
}

typedef void OnPickImageCallback(
    double? maxWidth, double? maxHeight, int? quality);
