import 'package:dio/dio.dart';
import 'package:eums/common/constants.dart';
import 'package:eums/common/local_store/local_store_service.dart';
import 'package:flutter/material.dart';

class TrueOverlayService {
  // LocalStore localStore = LocalStoreService();

  late Dio dio;
  TrueOverlayService() {
    dio = Dio();
  }

  Future missionOfferWallOutside({advertiseIdx, pointType, token, required String adType}) async {
    // bên ngoài
    dynamic data = <String, dynamic>{"advertise_idx": advertiseIdx, "pointType": pointType};

    if (adType == 'bee') {
      await dio.post('${Constants.baseUrl}point/advertises/mission-complete',
          data: data, options: Options(headers: {"authorization": 'Bearer $token'}));
    } else {
      await dio.post('${Constants.baseUrl}point/region/mission-complete', data: data, options: Options(headers: {"authorization": 'Bearer $token'}));
    }
    return;
  }

  Future<bool> saveKeep({required int advertiseIdx, required String adType}) async {
    try {
      debugPrint("====>api saveKeep");
      await LocalStoreService.instant.preferences.reload();
      final token = LocalStoreService.instant.getAccessToken();
      dynamic data = <String, dynamic>{"advertise_idx": advertiseIdx, 'ad_type': adType};
      final repo = await dio.post('${Constants.baseUrl}advertises/save-keep-advertise',
          data: data, options: Options(headers: {"authorization": 'Bearer $token'}));
      if (repo.statusCode == 201 || repo.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("saveKeep===ERROR===>$e");
      return false;
    }
  }

  Future saveScrap({required int advertiseIdx, required String adType, required String token}) async {
    final data = <String, dynamic>{};
    data["advertise_idx"] = advertiseIdx;
    data["ad_type"] = adType;
    await dio.post('${Constants.baseUrl}advertises/save-scrap-advertise', data: data, options: Options(headers: {"authorization": 'Bearer $token'}));
    return;
  }

  Future deleteScrap({required int advertiseIdx, required String adType, token}) async {
    await dio.delete(
      '${Constants.baseUrl}advertises/delete-crap',
      data: {
        'adsIdx': advertiseIdx,
        'ad_type': adType,
      },
      options: Options(headers: {"authorization": 'Bearer $token'}),
    );
  }
}
