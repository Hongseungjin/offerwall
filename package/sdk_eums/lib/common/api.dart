import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'constants.dart';
import 'interceptors/interceptors.dart';
import 'local_store/local_store.dart';
import 'local_store/local_store_service.dart';

class BaseApi {
  LocalStore localStore = LocalStoreService();
  Dio? dio;

  BaseApi()
      : dio = Dio(BaseOptions(
          baseUrl: Constants.baseUrl,
          connectTimeout: const Duration(milliseconds: Constants.connectTimeout),
          receiveTimeout: const Duration(milliseconds: Constants.receiveTimeout),
        )) {
    dio?.interceptors.addAll([
      AccessTokenInterceptor(localStore: localStore),
      LoggingInterceptor(),
      UnauthorizedInterceptor(),
    ]);
  }

  buildDio() {
    (dio?.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
    return dio;
  }
}
