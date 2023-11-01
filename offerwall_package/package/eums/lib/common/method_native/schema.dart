import 'package:pigeon/pigeon.dart';

class OfferWall {
  String? memBirth;
  String? memGen;
  String? memRegion;
  String? memId;
  String? firebaseKey;
}

@FlutterApi()
abstract class FlutterOfferWallApi {
  void displayOfferWallDetails(OfferWall offerWall);
}

@HostApi()
abstract class HostOfferWallApi {
  void cancel();
  // void finishEditingBook(Book book);
}
