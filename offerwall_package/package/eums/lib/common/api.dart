import 'package:dio/dio.dart';
import 'constants.dart';
import 'interceptors/interceptors.dart';

class BaseApi {
  // LocalStore localStore = LocalStoreService();

  

  Dio? dio;

  BaseApi()
      : dio = Dio(BaseOptions(
          baseUrl: Constants.baseUrl,
          headers: {
            'Connection': 'keep-alive',
            'Accept': '*/*',
          },
          connectTimeout: const Duration(milliseconds: Constants.connectTimeout),
          receiveTimeout: const Duration(milliseconds: Constants.receiveTimeout),
        )) {
    dio?.interceptors.addAll([
      // AccessTokenInterceptor(localStore: localStore),
      AccessTokenInterceptor(),
      LoggingInterceptor(),
      UnauthorizedInterceptor(),
    ]);
  }

  buildDio() {
    // (dio?.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
    //     (client) {
    //   client.badCertificateCallback =
    //       (X509Certificate cert, String host, int port) => true;
    //   return client;
    // };
    return dio;
  }
}
