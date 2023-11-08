import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class HiveLocal {
  HiveLocal._();
  static HiveLocal instant = HiveLocal._();

  String nameDataLocal = 'offerwallEums';
  late Box<dynamic> box;

  init() async {
    final path = (await getApplicationDocumentsDirectory()).path;
    Hive.init(path);
    box = await Hive.openBox(nameDataLocal);
  }

  Future setIsToast(bool isToast) async {
   await box.put('isToast', isToast);
  }

  bool getIsToast() {
    return box.get('isToast');
  }
}
