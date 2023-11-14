import 'package:eums/eum_app_offer_wall/widget/toast/toast_bottom_widget.dart';
import 'package:eums/eum_app_offer_wall/widget/toast/toast_widget.dart';

enum AppAlertType {
  bottom,
  top,
}

class AppAlert {
  static void showSuccess(
    String message, {
    AppAlertType? type,
  }) {
    if (type == AppAlertType.bottom) {
      ToastBottomWidget.instance.showToast(message, success: true);
    } else {
      ToastWidget.instance.showToast(message, success: true);
    }
  }

  static void showError(String message) {
    ToastWidget.instance.showToast(message, success: false);
  }

  static void showFeatureWaitingUpdate() {
    ToastWidget.instance.showToast('공사 중인 기능', success: true);
  }
}
