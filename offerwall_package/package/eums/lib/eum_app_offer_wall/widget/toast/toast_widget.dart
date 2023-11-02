import 'dart:async';

import 'package:eums/common/const/values.dart';
import 'package:eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:eums/eum_app_offer_wall/utils/appStyle.dart';
import 'package:flutter/material.dart';

class ToastWidget {
  ToastWidget._();
  static ToastWidget instance = ToastWidget._();
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
      startTimer(seconds: seconds);
      _overlay = OverlayEntry(
        builder: (context) => GestureDetector(
          onTap: () {
            hideToast();
          },
          child: Material(
            type: MaterialType.transparency,
            child: BuildBodyWidget(message: message, seconds: seconds, success: success, isMain: contextMain != null),
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
  BuildBodyWidget({Key? key, required this.message, this.seconds = 5, required this.success, required this.isMain}) : super(key: key);
  int seconds;
  final String message;

  final bool success;
  final bool isMain;
  @override
  State<BuildBodyWidget> createState() => _BuildBodyWidgetState();
}

class _BuildBodyWidgetState extends State<BuildBodyWidget> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> position;
  Timer? lifeTime;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    position = Tween<Offset>(begin: const Offset(0.0, -0.5), end: Offset.zero).animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));
    controller.forward();
    Future.delayed(const Duration(seconds: 1), () {
      startTimer(seconds: widget.seconds - 2);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void startTimer({required int seconds}) {
    lifeTime?.cancel();
    lifeTime = Timer(Duration(seconds: seconds), () {
      try {
        controller.reverse();
        // ignore: empty_catches
      } catch (e) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SlideTransition(
        position: position,
        child: Column(
          children: [
            SizedBox(
              height: widget.isMain == true ? 16 : kToolbarHeight + MediaQuery.of(context).padding.top,
            ),
            widget.success == true ? _buildSuccess() : _buildError()
          ],
        ),
      ),
    );
  }

  _buildSuccess() {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(
          vertical: 6,
          horizontal: 6,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Container(
              decoration: BoxDecoration(
                color: Colors.green,
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 4),
                    blurRadius: 4,
                    spreadRadius: 0,
                    color: Colors.black.withOpacity(0.25),
                  )
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.verified_user_outlined, color: Colors.white),
                  const SizedBox(width: 5),
                  Expanded(child: Text(widget.message, style: AppStyle.bold16.copyWith(color: AppColor.white))),
                ],
              )),
        ));
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
