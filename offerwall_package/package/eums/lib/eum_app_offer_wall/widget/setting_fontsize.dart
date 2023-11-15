import 'package:get/get.dart';
import 'package:eums/common/local_store/local_store.dart';
import 'package:eums/common/local_store/local_store_service.dart';

class SettingFontSize extends GetxController {
  // LocalStore localStore = LocalStoreService();
  RxDouble fontSizeObx = RxDouble(14);

  initSetingFontSize(SettingFontSize controllerGet) async {
    double value = 0.obs.toDouble();
    switch ((double.parse(LocalStoreService.instant.getSizeText())).toInt()) {
      case 14:
        value = 0;
        break;
      case 16:
        value = 1;
        break;
      case 18:
        value = 2;
        break;
      case 20:
        value = 3;
        break;
      case 22:
        value = 4;
        break;
      default:
    }
    controllerGet.increaseSize(value);
  }

  increaseSize(num numberSizeInCrease) {
    fontSizeObx.value = 14.obs.toDouble();
    switch (numberSizeInCrease) {
      case 0:
        fontSizeObx.value = 14;
        break;
      case 1:
        fontSizeObx.value += 2;
        break;
      case 2:
        fontSizeObx.value += 4;
        break;
      case 3:
        fontSizeObx.value += 6;
        break;
      case 4:
        fontSizeObx.value += 8;
        break;
      default:
    }

    LocalStoreService.instant.setSizeText(fontSizeObx.value);
  }
}
