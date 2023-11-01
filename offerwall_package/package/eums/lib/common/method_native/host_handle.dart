
import 'package:flutter/services.dart';

import 'host_api.dart';


abstract class FlutterOfferWallApi {
  static const MessageCodec<Object?> codec = _FlutterOfferWallApiCodec();

  void displayOfferWallDetails(OfferWall offerWall);
  static void setup(FlutterOfferWallApi? api) {
    {
      const channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.FlutterOfferWallApi.displayOfferWallDetails', codec);
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        // ignore: avoid_types_on_closure_parameters
        channel.setMessageHandler((Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.FlutterOfferWallApi.displayOfferWallDetails was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final OfferWall? arg_offerwall = args[0] as OfferWall?;
          assert(arg_offerwall != null,
              'Argument for dev.flutter.pigeon.FlutterOfferWallApi.displayOfferWallDetails was null, expected non-null offerWall.');
          api.displayOfferWallDetails(arg_offerwall!);
          return;
        });
      }
    }
  }
}


class _FlutterOfferWallApiCodec extends StandardMessageCodec {
  const _FlutterOfferWallApiCodec();
  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is OfferWall) {
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
        return OfferWall.decode(readValue(buffer)!);

      default:
        return super.readValueOfType(type, buffer);
    }
  }
}

typedef OfferWallReceived = void Function(OfferWall offerWall);
class FlutterOfferWallApiHandler extends FlutterOfferWallApi {
  FlutterOfferWallApiHandler(this.callback);

  final OfferWallReceived callback;

  @override
  void displayOfferWallDetails(OfferWall offerWall) {
    callback(offerWall);
  }
}