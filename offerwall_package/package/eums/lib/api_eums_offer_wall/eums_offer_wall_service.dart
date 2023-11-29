import 'dart:io';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'eums_offer_wall_service_api.dart';

abstract class EumsOfferWallService extends PlatformInterface {
  /// Constructs a EumsOfferWallService.
  EumsOfferWallService() : super(token: _token);

  static final Object _token = Object();

  static EumsOfferWallService _instance = EumsOfferWallServiceApi();

  /// The default instance of [EumsOfferWallService] to use.
  ///
  /// Defaults to [EumsOfferWallServiceApi].
  static EumsOfferWallService get instance => _instance;

  static set instance(EumsOfferWallService instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// [menId] 아이디입력
  /// [memGen] 성별입력
  ///[memRegion] 주소입력
  ///[memBirth] 생년월일 입력 양식 "2023-06-02T06:51:17.205Z"
  /// sdk연동하기 시작할 때 호출
  Future<dynamic> authConnect({String? memId, String? memGen, String? memRegion, String? memBirth, String? firebaseKey});

  /// 유저 정보
  Future<dynamic> userInfo();

  ///[token] 장치 토큰 입력
  /// on/off 광고 알림 받기
  Future<dynamic> createTokenNotification({String? token});

  Future<dynamic> unRegisterTokenNotification({String? token});

  /// 이용약관
  Future<dynamic> getUsingTerm();

  ///질문 리스트
  Future<dynamic> getQuestion({int? limit, int? offset, String? search});

  /// 1:1문의하기
  ///[type] enum{포인트 = [point], 문의 = [inquire]}
  ///[content] 내용
  Future<dynamic> createInquire(
      {String? type,
      String? content,
      String? title,
      String? deviceManufacturer,
      String? deviceModelName,
      String? deviceOsVersion,
      String? deviceSdkVersion,
      String? deviceAppVersion});

  /// 1:1 질문 리스트
  Future<dynamic> getListInquire({int? limit, int? offset});

  /// 내부 오퍼월 광고 리스트
  /// [category] enum{전체 = [null], 미션형 = [mission] ,참여형 = [participation]}
  /// [filter] enum{캐시높은 순 = [highest_reward], 캐시적은 순 = [lowest_reward] ,최신순 = [lastest]}
  Future<dynamic> getListOfferWall({int? limit, int? offset, String? category, String? filter});

  ///[xId] 광고 아이디
  /// 내부 오퍼월 광고 정보 보기
  Future<dynamic> getDetailOffWall({int? xId});

  /// 외부 오퍼월 포인트 리스트
  Future<dynamic> getPointOffWall({int? month, int? year});

  /// eums 포인트 리스트
  Future<dynamic> getPointEum({int? limit, int? offset, int? month, int? year});

  /// KEEP광고 리스트
  Future<dynamic> getListKeep({int? limit, int? offset});

  /// KEEP광고 저장
  ///[advertiseIdx]광고 아이디
  Future<bool> saveKeep({required int advertiseIdx, required String adType});

  ///KEEP광고 삭제
  ///[advertiseIdx] 광고 아이디
  Future<dynamic> deleteKeep({required int idx});

  /// 스크랩 광고 리스트
  /// [sort] enum{날짜 오름차순 = [DATE_ASC], 날짜 내림차순 = [DATE_DESC] ,좋아요 = [LIKE]}
  Future<dynamic> getListScrap({int? limit, int? offset, String? sort});

  ///스크랩 광고 저장
  ///[advertiseIdx]광고 아이디
  Future<dynamic> saveScrap({required int advertiseIdx, required String adType});

  ///스크랩 광고 삭제
  ///[advertiseIdx] 광고 아이디
  Future<dynamic> deleteScrap({required int adsIdx, required String adType});

  /// 내부 오퍼월 미션
  ///  [offerWallIdx] 광고 아이디
  ///  [urlImage] api에서 가져오기 [uploadImageOfferWallInternal]
  Future<dynamic> missionOfferWallInternal({int? offerWallIdx, File? urlImage, String? lang, String? html});

  /// 미션완료후에 사진 업로드
  /// api를 호출후에 [missionOfferWallInternal]
  Future<dynamic> uploadImageOfferWallInternal({List<File>? files});

  ///외부 오퍼월 미션
  ///[advertiseIdx]광고 아이디
  ///[pointType] 광고 아이디  enum POINT_ADS_EUM {POINT_8 = 'POINT_8', POINT_16 = 'POINT_16', POINT_32 = 'POINT_32', POINT_80 = 'POINT_80', POINT_160 = 'POINT_160'

  Future<dynamic> missionOfferWallOutside({int? advertiseIdx, String? pointType});
  Future<dynamic> regionOfferWallOutside({int? advertiseIdx, String? pointType});

  /// GetAdvertiseSponsor
  Future<dynamic> getAdvertiseSponsor();

  Future<dynamic> getBanner({dynamic type});

  Future<dynamic> getTotalPoint();

  Future<dynamic> reportAdver({required int adsIdx, required String reason, dynamic type});

  Future<dynamic> createOrUpdateSettingTime({DateTime? startTime, DateTime? endTime});

  Future<dynamic> getSettingTime();

  Future<dynamic> enableOrDisebleSettingTime({bool? enable});

  Future<dynamic> getListNotifi({int? limit, int? offset});

  Future<dynamic> getPointEarmed();

  Future<dynamic> updateLocation({dynamic lat, dynamic log});
  startBackgroundFirebaseMessage();
}
