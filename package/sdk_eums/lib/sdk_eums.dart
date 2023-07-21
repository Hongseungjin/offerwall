import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sdk_eums/sdk_eums_permission.dart';

class SdkEums {
  SdkEums._();

  static final SdkEums instant = SdkEums._();

  SdkEumsPermission permission = SdkEumsPermission.instant;

  void init({required Function() onRun}) async {
    WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: 'AIzaSyBkj46lMsOL6WABO5FzeTXTlppVognezoM',
            appId: '1:739452302790:android:9fe699ead424427640aec7',
            messagingSenderId: '739452302790',
            projectId: 'e-ums-24291'));
    onRun.call();
  }
}
