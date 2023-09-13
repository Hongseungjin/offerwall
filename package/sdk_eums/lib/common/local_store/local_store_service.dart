import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'local_store.dart';

class LocalStoreService extends LocalStore {
  static const PREF_ACCESS_TOKEN = 'PREF_ACCESS_TOKEN';
  static const PREF_LOGGED_ACCOUNT = 'PREF_LOGGED_ACCOUNT';
  static const SAVE_OR_NOT_CREDENTIALS = 'SAVE_OR_NOT_CREDENTIALS';
  static const SAVE_OR_NOT_ADVER = 'SAVE_OR_NOT_ADVER';
  static const SAVE_DATA_SHARE = 'SAVE_DATA_SHARE';
  static const SAVE_DEVICE_TOKEN = 'SAVE_DEVICE_TOKEN';
  static const DEVICE_WIDTH = 'DEVICE_WIDTH';
  static const COUNT_ADVER = 'COUNT_ADVER';
  static const dataUser = 'dataUser';

  @override
  Future<bool> hasAuthenticated() async {
    String accessToken = await getAccessToken();
    dynamic account = await getLoggedAccount();
    return accessToken.isNotEmpty && account != null;
  }

  @override
  Future setAccessToken(String sessionId) async {
    (await SharedPreferences.getInstance())
        .setString(PREF_ACCESS_TOKEN, sessionId);
  }

  @override
  Future<String> getAccessToken() async {
    return (await SharedPreferences.getInstance())
            .getString(PREF_ACCESS_TOKEN) ??
        '';
  }

  @override
  Future setLoggedAccount(dynamic user) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(PREF_LOGGED_ACCOUNT, jsonEncode(user));
  }

  @override
  Future<dynamic> getLoggedAccount() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return jsonDecode(preferences.getString(PREF_LOGGED_ACCOUNT) ?? '{}');
  }

  @override
  Future saveCredentials(String accessToken, dynamic account) async {
    await Future.wait([
      setAccessToken(accessToken),
      setLoggedAccount(account),
    ]);
  }

  @override
  Future removeCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return Future.wait([
      // prefs.remove(PREF_ACCESS_TOKEN),
      // prefs.remove(PREF_LOGGED_ACCOUNT),
    ]);
  }

  @override
  Future updateLoggedAccount(dynamic account) async {
    await setLoggedAccount(account);
  }

  @override
  Future<bool> clear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await Future.wait(
        [prefs.remove(PREF_ACCESS_TOKEN), prefs.remove(PREF_LOGGED_ACCOUNT)]);
    return true;
  }

  @override
  Future<bool> containsKey(String key) async =>
      (await SharedPreferences.getInstance()).containsKey(key);

  @override
  Future<bool> removeKey(String key) async =>
      (await SharedPreferences.getInstance()).remove(key);

  @override
  Future reload() async => (await SharedPreferences.getInstance()).reload();

  @override
  Future<bool> getSaveOrNotCredentials() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(SAVE_OR_NOT_CREDENTIALS) == 'true'
        ? true
        : false;
  }

  @override
  Future<bool> getSaveAdver() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(SAVE_OR_NOT_ADVER) == 'true' ? true : false;
  }

  @override
  Future setSaveAdver(bool status) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(SAVE_OR_NOT_ADVER, status.toString());
  }

  @override
  Future<String?> getDataShare() async {
    return (await SharedPreferences.getInstance()).getString(SAVE_DATA_SHARE);
    // return preferences.getString(SAVE_DATA_SHARE) == 'true' ? true : false;
  }

  @override
  Future setDataShare({dynamic dataShare}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(SAVE_DATA_SHARE, jsonEncode(dataShare));
  }

  @override
  Future getDeviceToken() async {
    return (await SharedPreferences.getInstance()).getString(SAVE_DEVICE_TOKEN);
  }

  @override
  Future setDeviceToken(token) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(SAVE_DEVICE_TOKEN, token);
  }

  @override
  Future<String> getDeviceWidth() async {
    return (await SharedPreferences.getInstance()).getString(DEVICE_WIDTH) ??
        '0';
    // return preferences.getString(SAVE_DATA_SHARE) == 'true' ? true : false;
  }

  @override
  Future setDeviceWidth(double width) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(DEVICE_WIDTH, jsonEncode(width));
  }

  @override
  Future getCountAdvertisement() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return jsonDecode(preferences.getString(COUNT_ADVER) ?? '{}');
  }

  @override
  Future setCountAdvertisement(dynamic data) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(COUNT_ADVER, jsonEncode(data));
  }

  @override
  Future getDataUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return jsonDecode(preferences.getString(dataUser) ?? '{}');
  }

  @override
  Future setDataUser(account) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(dataUser, jsonEncode(account));
  }

  @override
  Future getBoolTime() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString("boolTime") == 'true' ? true : false;
  }

  @override
  Future setBoolTime(bool checkBool) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString("boolTime", checkBool.toString());
  }
}
