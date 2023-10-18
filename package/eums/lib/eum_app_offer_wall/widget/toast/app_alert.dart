import 'package:eums/eum_app_offer_wall/widget/toast/toast_widget.dart';

class AppAlert {
  static void showSuccess(String message) {
    ToastWidget.instance.showToast(message, success: true);
  }

  static void showError(String message) {
    ToastWidget.instance.showToast(message, success: false);
  }

  static void showFeatureWaitingUpdate() {
    ToastWidget.instance.showToast('공사 중인 기능', success: true);
  }
}
