import 'package:get/get.dart';
import 'package:sdk_eums/common/local_store/local_store.dart';
import 'package:sdk_eums/common/local_store/local_store_service.dart';

class SettingFontSize extends GetxController {
  LocalStore localStore = LocalStoreService();
  RxDouble fontSizeObx = RxDouble(0);

  initSetingFontSize(SettingFontSize controllerGet) async {
    print("controllerGet.fontSizeObx.value${(await localStore.getSizeText())}");
    controllerGet.increaseSize(double.parse(await localStore.getSizeText()));
  }

  increaseSize(double numberSizeInCrease) {
    try {
      print("fontSizeObx.value ${fontSizeObx.value}");
      fontSizeObx.value += numberSizeInCrease;
      print("fontSizeObx.value ${fontSizeObx.value}");
      // localStore.setSizeText(fontSizeObx.value);
    } catch (ex) {}
  }

  decreaseSize(double numberSizeInCrease) {
    print("numberSizeInCrease ${numberSizeInCrease}");
    try {
      print("fontSizeObx.value12313 ${fontSizeObx.value}");
      fontSizeObx.value -= numberSizeInCrease;
      print("fontSizeObx.value222 ${fontSizeObx.value}");
      // localStore.setSizeText(fontSizeObx.value);
    } catch (ex) {}
  }
}
