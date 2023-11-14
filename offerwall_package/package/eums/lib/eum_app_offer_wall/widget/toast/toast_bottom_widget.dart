import 'dart:async';

import 'package:eums/common/const/values.dart';
import 'package:eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:eums/eum_app_offer_wall/utils/appStyle.dart';
import 'package:flutter/material.dart';

class ToastBottomWidget {
  ToastBottomWidget._();
  static ToastBottomWidget instance = ToastBottomWidget._();
  OverlayEntry? _overlay;
  Timer? lifeTime;
  void showToast(
    String message, {
    int seconds = 4,
    required bool success,
  }) {
    final contextOverlay = globalKeyMainOverlay.currentState?.context;
    final contextMain = navigatorKeyMain.currentState?.context;

    if (_overlay == null && (contextOverlay != null || contextMain != null)) {
      final height = MediaQuery.of(contextMain ?? contextOverlay!).size.height;

      startTimer(seconds: seconds);
      _overlay = OverlayEntry(
        builder: (context) => GestureDetector(
          onTap: () {
            hideToast();
          },
          child: Material(
            type: MaterialType.transparency,
            child: BuildBodyWidget(
              message: message,
              seconds: seconds,
              success: success,
              isMain: contextMain != null,
              height: height,
            ),
          ),
        ),
      );
      Overlay.of((contextMain ?? contextOverlay)!).insert(_overlay!);
    } else {
      hideToast();
      showToast(message, seconds: seconds, success: success);
    }
  }

  void hideToast() {
    _overlay?.remove();
    _overlay = null;
  }

  void startTimer({required int seconds}) {
    lifeTime?.cancel();
    lifeTime = Timer(Duration(seconds: seconds), () {
      hideToast();
    });
  }
}

// ignore: must_be_immutable
class BuildBodyWidget extends StatefulWidget {
  BuildBodyWidget({Key? key, required this.message, this.seconds = 5, required this.success, required this.isMain, required this.height})
      : super(key: key);
  int seconds;
  final String message;

  final bool success;
  final bool isMain;

  final double height;

  @override
  State<BuildBodyWidget> createState() => _BuildBodyWidgetState();
}

class _BuildBodyWidgetState extends State<BuildBodyWidget> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> position;

  late EdgeInsets padding;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      position = Tween<double>(begin: widget.height, end: widget.height - 100 - padding.bottom - kToolbarHeight).animate(controller)
        ..addListener(() {
          setState(() {});
        });
      controller.forward();
      Future.delayed(const Duration(seconds: 3), () {
        controller.reverse();
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint("xxxx: ${position.value}");

    padding = MediaQuery.of(context).padding;
    return SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: position.value,
          ),
          widget.success == true ? _buildSuccess() : _buildError()
        ],
      ),
    );
  }

  _buildSuccess() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 4),
                blurRadius: 4,
                spreadRadius: 0,
                color: Colors.white.withOpacity(0.25),
              )
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Text(
            widget.message,
            style: AppStyle.bold16.copyWith(color: AppColor.white, height: 1.3),
            textAlign: TextAlign.center,
          )),
    );
  }

  _buildError() {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(
          vertical: 6,
          horizontal: 6,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.red,
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 4),
                    blurRadius: 4,
                    spreadRadius: 0,
                    color: Colors.black.withOpacity(0.25),
                  )
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 5),
                  Expanded(child: Text(widget.message, style: AppStyle.bold16.copyWith(color: AppColor.white))),
                ],
              )),
        ));
  }
}
