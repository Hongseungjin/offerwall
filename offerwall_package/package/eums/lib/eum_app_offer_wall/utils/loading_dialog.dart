import 'package:flutter/material.dart';
import 'package:eums/common/const/values.dart';
import 'package:eums/eum_app_offer_wall/utils/widget_loading_animated.dart';

class LoadingDialog {
  LoadingDialog._();
  static LoadingDialog instance = LoadingDialog._();
  OverlayEntry? _overlay;

  void show({BuildContext? context}) {
    try {
      if (_overlay == null) {
        _overlay = OverlayEntry(
          builder: (context) => ColoredBox(
            color: Colors.black.withOpacity(.3),
            child: const Center(
              child: WidgetLoadingAnimated(),
            ),
          ),
        );
        Overlay.of(context ?? navigatorKeyMain.currentContext!).insert(_overlay!);
      }
    } catch (e) {
      rethrow;
    }
  }

  void hide() {
    _overlay?.remove();
    _overlay = null;
  }
}
