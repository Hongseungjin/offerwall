import 'package:cron/cron.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:sdk_eums/common/constants.dart';
import 'package:sdk_eums/common/local_store/local_store_service.dart';

class CronCustom {
  final cron = Cron();
  initCron() async {
    await Firebase.initializeApp();
    //// 3600
    cron.schedule(Schedule.parse('*/3600 * * * * *'), () async {
      print("count${(await LocalStoreService()
                  .getCountAdvertisement())['count']}");
      try {
        String? token = await FirebaseMessaging.instance.getToken();
        if ((await LocalStoreService().getCountAdvertisement())['date'] ==
            Constants.formatTime(DateTime.now().toIso8601String())) {
          /// ngày hiện tại
          if ((await LocalStoreService()
                  .getCountAdvertisement())['count'] ==
              '50') {
            LocalStoreService().setCountAdvertisement(0);
            await EumsOfferWallServiceApi().unRegisterTokenNotifi(token: token);
          } else {}
        } else {
          /// ngày hôm sau
          if ((await LocalStoreService()
                  .getCountAdvertisement())['count'] <
              '50') {
            LocalStoreService().setCountAdvertisement(0);
          } else {
            await EumsOfferWallServiceApi().createTokenNotifi(token: token);
          }
        }
      } catch (ex) {
        print(ex);
      }
    });
  }
}
