import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:sdk_eums/common/api.dart';
import 'package:sdk_eums/common/local_store/local_store.dart';
import 'package:sdk_eums/common/local_store/local_store_service.dart';

import 'eums_offer_wall_service.dart';

class EumsOfferWallServiceApi extends EumsOfferWallService {
  Dio api = BaseApi().buildDio();
  LocalStore localStore = LocalStoreService();

  @override
  Future authConnect(
      {String? memId,
      String? memGen,
      String? memRegion,
      String? memBirth}) async {
    dynamic data = <String, dynamic>{
      "memId": memId,
      "memGen": memGen,
      "memRegion": memRegion,
      "memBirth": memBirth
    };
    localStore.setLoggedAccount(data);
    Response result = await api.post('auth/connect', data: data);
    return result.data;
  }

  @override
  Future userInfo() async {
    Response result = await api.get('auth/profile');
    return result.data;
  }

  @override
  Future createTokenNotifi({token}) async {
    dynamic data = <String, dynamic>{"deviceToken": token};
    await api.post('device-token', data: data);
    return;
  }

  @override
  Future unRegisterTokenNotifi({token}) async {
    dynamic data = <String, dynamic>{"deviceToken": token};
    await api.delete('device-token', data: data);
    return;
  }

  @override
  Future createInquire(
      {type,
      content,
      deviceManufacturer,
      deviceModelName,
      deviceOsVersion,
      deviceSdkVersion,
      title,
      deviceAppVersion}) async {
    dynamic data = <String, dynamic>{
      "type_fl": type,
      "contents": content,
      "device_manufacturer": deviceManufacturer,
      "device_model_name": deviceModelName,
      "device_os_version": deviceOsVersion,
      "device_sdk_version": deviceSdkVersion,
      "device_app_version": deviceAppVersion,
      "title": title
    };
    await api.post('inquire', data: data);
    return;
  }

  @override
  Future deleteKeep({advertiseIdx}) async {
    await api.delete(
      'advertises/delete-keep/$advertiseIdx',
    );
  }

  @override
  Future deleteScrap({advertiseIdx}) async {
    await api.delete(
      'advertises/delete-crap/$advertiseIdx',
    );
  }

  @override
  Future getDetailOffWall({xId}) async {
    Response result = await api.get(
      'offerwall/$xId',
    );
    return result.data;
  }

  @override
  Future getListInquire({limit, offset}) async {
    var params = {};
    if (limit != null) {
      params['limit'] = limit;
    }
    if (offset != null) {
      params['offset'] = offset;
    }
    Map<String, dynamic> dataParams = jsonDecode(jsonEncode(params));
    Response result = await api.get('inquire', queryParameters: dataParams);
    return result.data['data'];
  }

  @override
  Future getListKeep({limit, offset}) async {
    var params = {};
    if (limit != null) {
      params['limit'] = limit;
    }
    if (offset != null) {
      params['offset'] = offset;
    }
    Map<String, dynamic> dataParams = jsonDecode(jsonEncode(params));
    Response result = await api.get('advertises/get-keep-advertise',
        queryParameters: dataParams);
    return result.data['data'];
  }

  @override
  Future getListOfferWall({limit, offset, category, filter}) async {
    var params = {};
    if (limit != null) {
      params['limit'] = limit;
    }
    if (offset != null) {
      params['offset'] = offset;
    }
    if (category != null) {
      params['category'] = category;
    }
    if (filter != null) {
      params['sort'] = filter;
    }
    Map<String, dynamic> dataParams = jsonDecode(jsonEncode(params));

    Response result = await api.get('offerwall', queryParameters: dataParams);
    return result.data['data'];
  }

  @override
  Future getListScrap({limit, offset, sort}) async {
    var params = {};
    if (limit != null) {
      params['limit'] = limit;
    }
    if (offset != null) {
      params['offset'] = offset;
    }
    if (sort != null) {
      params['sort'] = sort;
    }

    Map<String, dynamic> dataParams = jsonDecode(jsonEncode(params));
    Response result = await api.get('advertises/get-scrap-advertise',
        queryParameters: dataParams);
    return result.data['data'];
  }

  @override
  Future getPointEum({limit, offset, month, year}) async {
    var params = {};

    params['limit'] = limit;

    params['offset'] = offset;

    params['month'] = month;
    params['year'] = year;

    Map<String, dynamic> dataParams = jsonDecode(jsonEncode(params));

    Response result = await api.get('point/e-um', queryParameters: dataParams);
    return result.data['data'];
  }

  @override
  Future getPointOffWall({month, year}) async {
    var params = {};
    params['month'] = month;
    params['year'] = year;

    Map<String, dynamic> dataParams = jsonDecode(jsonEncode(params));
    Response result =
        await api.get('offerwall-log', queryParameters: dataParams);
    return result.data;
  }

  @override
  Future getQuestion({limit, offset, search}) async {
    var params = {};
    if (limit != null) {
      params['limit'] = limit;
    }
    if (offset != null) {
      params['offset'] = offset;
    }
    if (search != null) {
      params['search'] = search;
    }
    Map<String, dynamic> dataParams = jsonDecode(jsonEncode(params));
    Response result = await api.get('faq', queryParameters: dataParams);
    return result.data['data'];
  }

  @override
  Future getUsingTerm() async {
    Response result = await api.get('term');
    return result.data['data'];
  }

  @override
  Future missionOfferWallInternal({offerWallIdx, urlImage, lang, html}) async {
    // nội bộ
    FormData formData = FormData.fromMap({
      'image': urlImage != null
          ? await MultipartFile.fromFile(
              urlImage.path,
            )
          : null,
      'offerwall_idx': offerWallIdx,
      'lang': lang,
      'html': html
    });
    await api.post('point/offerwall/mission-complete', data: formData);
    return;
  }

  @override
  Future missionOfferWallOutside({advertiseIdx, pointType}) async {
    // bên ngoài
    dynamic data = <String, dynamic>{
      "advertise_idx": advertiseIdx,
      "pointType": pointType
    };
    await api.post('point/advertises/mission-complete', data: data);
    return;
  }

  @override
  Future saveKeep({advertiseIdx}) async {
    dynamic data = <String, dynamic>{"advertise_idx": advertiseIdx};
    await api.post('advertises/save-keep-advertise', data: data);
    return;
  }

  @override
  Future saveScrap({advertiseIdx}) async {
    dynamic data = <String, dynamic>{"advertise_idx": advertiseIdx};
    await api.post('advertises/save-scrap-advertise', data: data);
    return;
  }

  @override
  Future uploadImageOfferWallInternal({List<File>? files}) async {
    dynamic multiFiles = files
        ?.map((item) async => await MultipartFile.fromFile(
              item.path,
              // contentType:  MediaType('image', 'jpeg')
            ))
        .toList();

    FormData formData =
        FormData.fromMap({"image": await Future.wait(multiFiles)});
    Response result = await api.post('upload', data: formData);
    return result.data;
  }

  @override
  Future getAdvertiseSponsor() async {
    Response result = await api.get('advertises/get-advertise-sponsor');
    return result.data;
  }

  @override
  Future getBanner({type}) async {
    var params = {};
    if (type != null) {
      params['type'] = type;
    }
    Map<String, dynamic> dataParams = jsonDecode(jsonEncode(params));
    Response result = await api.get('banner', queryParameters: dataParams);
    return result.data;
  }

  @override
  Future getTotalPoint() async {
    Response result = await api.get('point/total');
    return result.data;
  }

  @override
  Future reportAdver({adsIdx, reason, type}) async {
    dynamic data = <String, dynamic>{
      "adsIdx": adsIdx,
      "reason": reason,
      "type": type
    };
    await api.post('report-ads', data: data);
  }

  @override
  Future createOrUpdateSettingTime({startTime, endTime}) async {
    try {
      dynamic data = <String, dynamic>{
        "startTime": {"hours": startTime?.hour, "minutes": startTime?.minute},
        "endTime": {"hours": endTime?.hour, "minutes": endTime?.minute},
      };
      await api.post('setting-time', data: data);
    } catch (ex) {}
  }

  @override
  Future enableOrDisebleSettingTime({enable}) async {
    dynamic data = <String, dynamic>{
      "enable": enable,
    };
    await api.put('setting-time', data: data);
  }

  @override
  Future getSettingTime() async {
    Response result = await api.get('setting-time');
    return result.data;
  }

  @override
  Future getListNotifi({int? limit, int? offset}) async {
    var params = {};
    if (limit != null) {
      params['limit'] = limit;
    }
    if (offset != null) {
      params['offset'] = offset;
    }
    Map<String, dynamic> dataParams = jsonDecode(jsonEncode(params));
    Response result = await api.get('notice', queryParameters: dataParams);
    return result.data['data'];
  }

  @override
  Future getPointEarmed() async {
    Response result = await api.get(
      '/point/earned',
    );
    return result.data;
  }
}
