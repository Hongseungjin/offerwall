import 'package:flutter/services.dart';

class HostOfferWallApi {
  /// Constructor for [HostOfferWallApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  HostOfferWallApi({BinaryMessenger? binaryMessenger}) : _binaryMessenger = binaryMessenger;

  final BinaryMessenger? _binaryMessenger;

  static const MessageCodec<Object?> codec = _HostOfferWallApiCodec();

  Future<void> cancel() async {
    final channel = BasicMessageChannel<Object?>('dev.flutter.pigeon.HostOfferWallApi.cancel', codec, binaryMessenger: _binaryMessenger);
    final Map<Object?, Object?>? replyMap = await channel.send(null) as Map<Object?, Object?>?;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final error = (replyMap['error'] as Map<Object?, Object?>?)!;
      throw PlatformException(
        code: (error['code'] as String?)!,
        message: error['message'] as String?,
        details: error['details'],
      );
    }
  }

  // Future<void> finishEditingBook(Book argBook) async {
  //   final BasicMessageChannel<Object?> channel =
  //       BasicMessageChannel<Object?>('dev.flutter.pigeon.HostBookApi.finishEditingBook', codec, binaryMessenger: _binaryMessenger);
  //   final Map<Object?, Object?>? replyMap = await channel.send(<Object>[argBook]) as Map<Object?, Object?>?;
  //   if (replyMap == null) {
  //     throw PlatformException(
  //       code: 'channel-error',
  //       message: 'Unable to establish connection on channel.',
  //       details: null,
  //     );
  //   } else if (replyMap['error'] != null) {
  //     final Map<Object?, Object?> error = (replyMap['error'] as Map<Object?, Object?>?)!;
  //     throw PlatformException(
  //       code: (error['code'] as String?)!,
  //       message: error['message'] as String?,
  //       details: error['details'],
  //     );
  //   }
  // }
}

class _HostOfferWallApiCodec extends StandardMessageCodec {
  const _HostOfferWallApiCodec();
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

class OfferWall {
  // memBirth: memBirth, memGen: memGen, memRegion: memRegion, memId: memId
  String? memBirth;
  String? memGen;
  String? memRegion;
  String? memId;
  String? firebaseKey;

  OfferWall({this.memBirth, this.memGen, this.memRegion, this.memId, this.firebaseKey});

  Object encode() {
    final pigeonMap = <Object?, Object?>{};
    pigeonMap['memBirth'] = memBirth;
    pigeonMap['memGen'] = memGen;
    pigeonMap['memRegion'] = memRegion;
    pigeonMap['memId'] = memId;
    pigeonMap['firebaseKey'] = firebaseKey;
    return pigeonMap;
  }

  static OfferWall decode(Object message) {
    final pigeonMap = message as Map<Object?, Object?>;
    return OfferWall(
      memBirth: pigeonMap['memBirth'] as String?,
      memGen: pigeonMap['memGen'] as String?,
      memRegion: pigeonMap['memRegion'] as String?,
      memId: pigeonMap['memId'] as String?,
      firebaseKey: pigeonMap['firebaseKey'] as String?,
    );
  }
}
