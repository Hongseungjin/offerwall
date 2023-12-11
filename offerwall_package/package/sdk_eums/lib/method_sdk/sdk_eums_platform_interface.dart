import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'sdk_eums_method_channel.dart';

abstract class SdkEumsPlatform extends PlatformInterface {
  /// Constructs a SdkEumsPlatform.
  SdkEumsPlatform() : super(token: _token);

  static final Object _token = Object();

  static SdkEumsPlatform _instance = MethodChannelSdkEums();

  /// The default instance of [SdkEumsPlatform] to use.
  ///
  /// Defaults to [MethodChannelSdkEums].
  static SdkEumsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SdkEumsPlatform] when
  /// they register themselves.
  static set instance(SdkEumsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }


    Future methodUser({dynamic data});

  /// document adsynk
  /// 파트너 앱(Publisher App) (AndroidMainfest.xml) 설정
  /// 1. <uses-permission android:name="com.google.android.gms.permission.AD_ID"/>
  /// 2.meta-data 설정
  /// <meta-data android:name="partner_id" android:value="파트너 서비스 Id 는 AdSync 가 등록된 어플리케이션들을 식별하기 위하여 사용하는 유일한 ID 값입니다."/>

  Future<dynamic> methodAdsync({dynamic data});

  /// document adpopcorn
  /// 파트너 앱(Publisher App) (AndroidMainfest.xml) 설정
  ///   <meta-data
  //     android:name="adpopcorn_app_key"
  //     android:value="449540558" />
  // <meta-data
  //     android:name="adpopcorn_hash_key"
  //     android:value="4e5c2d2ee6a042ab" />
  Future methodAdpopcorn({dynamic data});

  /// document mafin
  /// 파트너 앱(Publisher App) (AndroidMainfest.xml) 설정
  ///   <meta-data
  // android:name="naswall_app_key"
  // android:value="" />
  Future methodMafin({dynamic data});

  /// document tnk
  /// 파트너 앱(Publisher App) (AndroidMainfest.xml) 설정
  /// <meta-data android:name="tnkad_app_id" android:value="" />
  Future methodTnk({dynamic data});

  /// document iveKorea
  /// 파트너 앱(Publisher App) (AndroidMainfest.xml) 설정
  ///  <meta-data
  //     android:name="ive_sdk_appcode"
  //     android:value="" />
  // <meta-data
  //     android:name="ive_sdk_offerwall_title"
  //     android:value="" />

  Future methodIvekorea({dynamic data});

  /// document appall
  ///

  Future methodAppall({dynamic data});

  /// document ohc
  ///
  Future methodOHC({dynamic data});
}
