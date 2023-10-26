import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

// import 'local_store.dart';

class LocalStoreService {
  static const PREF_ACCESS_TOKEN = 'PREF_ACCESS_TOKEN';
  static const PREF_LOGGED_ACCOUNT = 'PREF_LOGGED_ACCOUNT';
  static const SAVE_OR_NOT_CREDENTIALS = 'SAVE_OR_NOT_CREDENTIALS';
  static const SAVE_OR_NOT_ADVER = 'SAVE_OR_NOT_ADVER';
  static const SAVE_DATA_SHARE = 'SAVE_DATA_SHARE';
  static const SAVE_DEVICE_TOKEN = 'SAVE_DEVICE_TOKEN';
  static const DEVICE_WIDTH = 'DEVICE_WIDTH';
  // static const COUNT_ADVER = 'COUNT_ADVER';
  static const dataUser = 'dataUser';

  late SharedPreferences preferences;
  LocalStoreService._();

  static LocalStoreService instant = LocalStoreService._();

  Future init() async {
    preferences = await SharedPreferences.getInstance();
  }

  Future<bool> hasAuthenticated() async {
    String accessToken = getAccessToken();
    dynamic account = await getLoggedAccount();
    return accessToken.isNotEmpty && account != null;
  }

  Future setAccessToken(String sessionId) async {
    preferences.setString(PREF_ACCESS_TOKEN, sessionId);
  }

  String getAccessToken() {
    return preferences.getString(PREF_ACCESS_TOKEN) ?? '';
  }

  Future setLoggedAccount(dynamic user) async {
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(PREF_LOGGED_ACCOUNT, jsonEncode(user));
  }

  Future<dynamic> getLoggedAccount() async {
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    return jsonDecode(preferences.getString(PREF_LOGGED_ACCOUNT) ?? '{}');
  }

  Future saveCredentials(String accessToken, dynamic account) async {
    await Future.wait([
      setAccessToken(accessToken),
      setLoggedAccount(account),
    ]);
  }

  Future removeCredentials() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    return Future.wait([
      // prefs.remove(PREF_ACCESS_TOKEN),
      // prefs.remove(PREF_LOGGED_ACCOUNT),
    ]);
  }

  Future updateLoggedAccount(dynamic account) async {
    await setLoggedAccount(account);
  }

  Future<bool> clear() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    await Future.wait([preferences.remove(PREF_ACCESS_TOKEN), preferences.remove(PREF_LOGGED_ACCOUNT)]);
    return true;
  }

  Future<bool> containsKey(String key) async => (await SharedPreferences.getInstance()).containsKey(key);

  Future<bool> removeKey(String key) async => (await SharedPreferences.getInstance()).remove(key);

  Future reload() async => (await SharedPreferences.getInstance()).reload();

  Future<bool> getSaveOrNotCredentials() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(SAVE_OR_NOT_CREDENTIALS) == 'true' ? true : false;
  }

  bool getSaveAdver() {
    // SharedPreferences preferences = await SharedPreferences.getInstance();

    return preferences.getString(SAVE_OR_NOT_ADVER) == 'true' ? true : false;
  }

  Future setSaveAdver(bool status) async {
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(SAVE_OR_NOT_ADVER, status.toString());
  }

  String? getDataShare() {
    return preferences.getString(SAVE_DATA_SHARE);
    // return preferences.getString(SAVE_DATA_SHARE) == 'true' ? true : false;
  }

  Future setDataShare({dynamic dataShare}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(SAVE_DATA_SHARE, jsonEncode(dataShare));
  }

  Future getDeviceToken() async {
    return preferences.getString(SAVE_DEVICE_TOKEN);
  }

  Future setDeviceToken(token) async {
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(SAVE_DEVICE_TOKEN, token);
  }

  String getDeviceWidth() {
    return preferences.getString(DEVICE_WIDTH) ?? '0';
    // return preferences.getString(SAVE_DATA_SHARE) == 'true' ? true : false;
  }

  Future setDeviceWidth(double width) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(DEVICE_WIDTH, jsonEncode(width));
  }

  //
  // Future getCountAdvertisement() async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   return jsonDecode(preferences.getString(COUNT_ADVER) ?? '{}');
  // }

  //
  // Future setCountAdvertisement(dynamic data) async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   await preferences.setString(COUNT_ADVER, jsonEncode(data));
  // }

  dynamic getDataUser() async {
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    return jsonDecode(preferences.getString(dataUser) ?? '{}');
  }

  Future setDataUser(account) async {
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(dataUser, jsonEncode(account));
  }

  bool getBoolTime() {
    return preferences.getString("boolTime") == 'true' ? true : false;
  }

  Future setBoolTime(bool checkBool) async {
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString("boolTime", checkBool.toString());
  }

  String getSizeDevice() {
    return preferences.getString(
          "sizeDevice",
        ) ??
        '0.0';
  }

  Future setSizeDevice(dynamic sizeHeight) async {
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString("sizeDevice", jsonEncode(sizeHeight));
  }

  String getSizeText() {
    return preferences.getString('SetText') ?? '0';
  }

  Future setSizeText(double sizeHeight) async {
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString('SetText', jsonEncode(sizeHeight));
  }
}
