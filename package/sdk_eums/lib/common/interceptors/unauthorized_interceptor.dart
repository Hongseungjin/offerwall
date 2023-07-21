import 'package:dio/dio.dart';

class UnauthorizedInterceptor extends Interceptor {
  UnauthorizedInterceptor();

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {}
    super.onError(err, handler);
  }
}
