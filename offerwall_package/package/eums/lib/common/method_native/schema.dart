import 'package:pigeon/pigeon.dart';

class Book {
  String? memBirth;
  String? memGen;
  String? memRegion;
  String? memId;
  String? firebaseKey; 
}


@FlutterApi()
abstract class FlutterBookApi {
  void displayBookDetails(Book book);
}

@HostApi()
abstract class HostBookApi {
  void cancel();
  // void finishEditingBook(Book book);
}
