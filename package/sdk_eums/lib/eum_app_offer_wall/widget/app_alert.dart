import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appStyle.dart';

class AppAlert {
  static void showSuccess(BuildContext context, FToast fToast, String message) {

    fToast.showToast(
        child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 10),
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
                      Expanded(child: Text(message, style: AppStyle.bold16.copyWith(color: AppColor.white))),
                    ],
                  )),
            )),
        toastDuration: const Duration(milliseconds: 2000),
        positionedToastBuilder: (context, child) {
          return Positioned(
            top: MediaQuery.of(context).padding.top + 15,
            left: 0,
            child: child,
          );
        });
  }

  static void showError(BuildContext context, FToast fToast, String message, {bool checkOver = false}) {
    fToast.showToast(
        child: Container(
            width: MediaQuery.of(context).size.width,
            padding: checkOver ? const EdgeInsets.only(top: 100) : const EdgeInsets.symmetric(horizontal: 10),
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
                      Expanded(child: Text(message, style: AppStyle.bold16.copyWith(color: AppColor.white))),
                    ],
                  )),
            )),
        toastDuration: const Duration(seconds: 2),
        positionedToastBuilder: (context, child) {
          return Positioned(
            top: MediaQuery.of(context).padding.top + 15,
            left: 0,
            child: child,
          );
        });
  }
}
