import 'package:dio/dio.dart';
import 'package:eums/common/api.dart';
import 'package:intl/intl.dart';

import '../constants.dart';

class LoggingInterceptor extends Interceptor {
  @override
  Future<dynamic> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (Constants.loggingInterceptorEnabled) {
      print('--------------- Request (${_format(DateTime.now(), 'mm:ss')}) ---------------');
      print('${options.method} - ${options.baseUrl}${options.path}');
      print('Headers: ${options.headers}');
      print('Content-Type: ${options.contentType}');
      if (options.data is FormData) {
        print('- file: ${(options.data as FormData).files.toString()}');
      } else {
        print('- ${options.data}');
      }
      print('Query parameters ${options.queryParameters}');
      print('---------------------------------------');
    }
    return handler.next(options);
  }

  @override
  Future<dynamic> onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (Constants.loggingInterceptorEnabled) {
      print('--------------- Response (${_format(DateTime.now(), 'mm:ss')}) ---------------');
      // printWrapped('$response');
      print('---------------------------------------');
    }
    return handler.next(response);
  }

  @override
  Future<dynamic> onError(DioError error, ErrorInterceptorHandler handler) async {
    if (Constants.loggingInterceptorEnabled) {
      print('--------------- Error (${_format(DateTime.now(), 'mm:ss')}) ---------------');
      print('type: ${error.type}');
      print('error: ${error.error}');
      print('path: ${error.requestOptions.path}');
      print('header: ${error.requestOptions.headers}');
      print('---------------------------------------');
      if (error.type == DioExceptionType.connectionTimeout) {
        Dio api = BaseApi().buildDio();
        final opts = Options(method: error.requestOptions.method, headers: error.requestOptions.headers);
        final cloneReq = await api.request(error.requestOptions.path,
            options: opts, data: error.requestOptions.data, queryParameters: error.requestOptions.queryParameters);
        return handler.resolve(cloneReq);
      }
    }
    return handler.next(error);
  }

  static String _format(DateTime dateTime, String formatPattern) {
    DateFormat dateFormat = DateFormat(formatPattern);
    return dateFormat.format(dateTime);
  }

  void printWrapped(String text) {
    final pattern = RegExp('.{1,800}');
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }
}
