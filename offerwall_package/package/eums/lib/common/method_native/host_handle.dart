
import 'package:flutter/services.dart';

import 'host_api.dart';


abstract class FlutterBookApi {
  static const MessageCodec<Object?> codec = _FlutterBookApiCodec();

  void displayBookDetails(Book book);
  static void setup(FlutterBookApi? api) {
    {
      const channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.FlutterBookApi.displayBookDetails', codec);
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        // ignore: avoid_types_on_closure_parameters
        channel.setMessageHandler((Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.FlutterBookApi.displayBookDetails was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final Book? arg_book = args[0] as Book?;
          assert(arg_book != null,
              'Argument for dev.flutter.pigeon.FlutterBookApi.displayBookDetails was null, expected non-null Book.');
          api.displayBookDetails(arg_book!);
          return;
        });
      }
    }
  }
}


class _FlutterBookApiCodec extends StandardMessageCodec {
  const _FlutterBookApiCodec();
  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is Book) {
      buffer.putUint8(128);
      writeValue(buffer, value.encode());
    } else {
      super.writeValue(buffer, value);
    }
  }

  @override
  Object? readValueOfType(int type, ReadBuffer buffer) {
    switch (type) {
      case 128:
        return Book.decode(readValue(buffer)!);

      default:
        return super.readValueOfType(type, buffer);
    }
  }
}

typedef BookReceived = void Function(Book book);
class FlutterBookApiHandler extends FlutterBookApi {
  FlutterBookApiHandler(this.callback);

  final BookReceived callback;

  @override
  void displayBookDetails(Book book) {
    callback(book);
  }
}