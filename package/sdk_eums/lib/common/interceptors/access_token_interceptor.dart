import 'package:dio/dio.dart';

import '../../api_eums_offer_wall/eums_offer_wall_service.dart';
import '../local_store/local_store.dart';
import '../local_store/local_store_service.dart';

class AccessTokenInterceptor extends Interceptor {
  AccessTokenInterceptor({required this.localStore});

  final LocalStore localStore;

  @override
  Future<dynamic> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    String token = await localStore.getAccessToken();
    // String token =
    //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJtZW1faWR4IjoxLCJtZW1JZCI6ImFiZWV0ZXN0IiwibWVtR2VuIjoibSIsIm1lbVJlZ2lvbiI6IuyEnOyauF_sooXroZwiLCJtZW1CaXJ0aCI6IjIwMjMtMDYtMTMiLCJtZW1Qb2ludCI6MTQ1NzksImlhdCI6MTY4OTIyMDAzNn0.08kirj874YYNFDIh8KnLfZM-4jDsM77JLsJqnkjoVGs';
    if (token.isNotEmpty) {
      options.headers['authorization'] = 'Bearer $token';
      options.queryParameters
          .addAll(<String, dynamic>{'access_token': 'Bearer $token'});
    }

    return super.onRequest(options, handler);
  }
}
