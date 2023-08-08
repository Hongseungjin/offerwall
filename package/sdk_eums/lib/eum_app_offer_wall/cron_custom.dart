import 'package:cron/cron.dart';
import 'package:sdk_eums/common/local_store/local_store.dart';
import 'package:sdk_eums/common/local_store/local_store_service.dart';
import 'package:sdk_eums/eum_app_offer_wall/notification_handler.dart';

class CronCustom {
  final cron = Cron();
  final LocalStore localStore = LocalStoreService();
  initCron() async {
    //// 3600
    cron.schedule(Schedule.parse('*/1800 * * * * *'), () async {
      try {
        CountAdver().checkDate();
      } catch (ex) {
        print(ex);
      }
    });
  }
}
