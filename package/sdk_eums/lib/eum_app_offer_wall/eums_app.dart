import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:sdk_eums/common/local_store/local_store.dart';
import 'package:sdk_eums/common/routing.dart';
import 'package:sdk_eums/sdk_eums_library.dart';

import '../common/local_store/local_store_service.dart';

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
    localStore.setAccessToken(data['token']);
    if (await localStore.getAccessToken() != null) {
      openAppSkd(context);
    }
  }

  @override
  openAppSkd(BuildContext context,
      {String? memId, String? memGen, String? memRegion, String? memBirth}) {
    Routing().navigate(context, MyHomeScreen());
  }
}
