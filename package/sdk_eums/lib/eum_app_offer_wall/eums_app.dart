import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:sdk_eums/common/local_store/local_store.dart';
import 'package:sdk_eums/common/routing.dart';
import 'package:sdk_eums/sdk_eums_library.dart';

import '../api_eums_offer_wall/eums_offer_wall_service_api.dart';
import '../common/local_store/local_store_service.dart';
import 'eums_app_i.dart';

class EumsAppOfferWall extends EumsAppOfferWallService {
  LocalStore localStore = LocalStoreService();
  @override
  Future openSdk(BuildContext context,
      {String? memId,
      String? memGen,
      String? memRegion,
      String? memBirth}) async {
    dynamic data = await EumsOfferWallService.instance.authConnect(
        memBirth: memBirth, memGen: memGen, memRegion: memRegion, memId: memId);
    // await Future.delayed(const Duration(milliseconds: 350));

    await localStore.setAccessToken(data['token']);

    if (await localStore.getAccessToken() != null) {
      openAppSkd(context);
      String? token = await FirebaseMessaging.instance.getToken();
      await EumsOfferWallServiceApi().createTokenNotifi(token: token);
      print("tokentokentokennotifile ${token}");
    }
  }

  @override
  openAppSkd(BuildContext context,
      {String? memId, String? memGen, String? memRegion, String? memBirth}) {
    Routing().navigate(context, MyHomeScreen());
  }
}
