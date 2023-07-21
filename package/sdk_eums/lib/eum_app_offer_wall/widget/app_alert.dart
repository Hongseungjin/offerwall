
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appColor.dart';
import 'package:sdk_eums/eum_app_offer_wall/utils/appStyle.dart';

class AppAlert {
  static void showSuccess(BuildContext context, FToast fToast, String message) {
    fToast.showToast(
        child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 4),
                        blurRadius: 4,
                        spreadRadius: 0,
                        color: Colors.black.withOpacity(0.25),
                      )
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_user_outlined, color: Colors.white),
                      SizedBox(width: 5),
                      Expanded(
                          child: Text(message,
                              style: AppStyle.bold16
                                  .copyWith(color: AppColor.white))),
                    ],
                  )),
            )),
        toastDuration: Duration(milliseconds: 2000),
        positionedToastBuilder: (context, child) {
          return Positioned(
            child: child,
            top: MediaQuery.of(context).padding.top + 15,
            left: 0,
          );
        });
  }

  static void showError(BuildContext context, FToast fToast, String message) {
    fToast.showToast(
        child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 4),
                        blurRadius: 4,
                        spreadRadius: 0,
                        color: Colors.black.withOpacity(0.25),
                      )
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.white),
                      SizedBox(width: 5),
                      Expanded(
                          child: Text(message,
                              style: AppStyle.bold16
                                  .copyWith(color: AppColor.white))),
                    ],
                  )),
            )),
        toastDuration: Duration(seconds: 2),
        positionedToastBuilder: (context, child) {
          return Positioned(
            child: child,
            top: MediaQuery.of(context).padding.top + 15,
            left: 0,
          );
        });
  }
}
