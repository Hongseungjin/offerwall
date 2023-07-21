import 'package:dio/dio.dart';

import '../local_store/local_store.dart';

class AccessTokenInterceptor extends Interceptor {
  AccessTokenInterceptor({required this.localStore});

  final LocalStore localStore;

  @override
  Future<dynamic> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    String token = await localStore.getAccessToken();
    if (token.isNotEmpty) {
      options.headers['authorization'] = 'Bearer $token';
      options.queryParameters.addAll(<String, dynamic>{'access_token': 'Bearer $token'});
    }
    return super.onRequest(options, handler);
  }
}
