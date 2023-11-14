import 'package:dio/dio.dart';
import 'package:eums/common/constants.dart';

class TrueOverlayService {
  // LocalStore localStore = LocalStoreService();

  Dio dio = Dio();
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

  Future saveKeep({required int advertiseIdx, required String adType, required String token}) async {
    dynamic data = <String, dynamic>{"advertise_idx": advertiseIdx, 'ad_type': adType};
    return await dio.post('${Constants.baseUrl}advertises/save-keep-advertise',
        data: data, options: Options(headers: {"authorization": 'Bearer $token'}));
  }

  Future saveScrap({required int advertiseIdx, required String adType, required String token}) async {
    final data = <String, dynamic>{};
    data["advertise_idx"] = advertiseIdx;
    data["ad_type"] = adType;
    await dio.post('${Constants.baseUrl}advertises/save-scrap-advertise', data: data, options: Options(headers: {"authorization": 'Bearer $token'}));
    return;
  }

  Future deleteScrap({advertiseIdx, token}) async {
    await dio.delete('${Constants.baseUrl}advertises/delete-crap/$advertiseIdx', options: Options(headers: {"authorization": 'Bearer $token'}));
  }
}
