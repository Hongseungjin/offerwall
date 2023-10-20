import 'package:flutter/services.dart';

class HostBookApi {
  /// Constructor for [HostBookApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  HostBookApi({BinaryMessenger? binaryMessenger}) : _binaryMessenger = binaryMessenger;

  final BinaryMessenger? _binaryMessenger;

  static const MessageCodec<Object?> codec = _HostBookApiCodec();

  Future<void> cancel() async {
    final channel = BasicMessageChannel<Object?>('dev.flutter.pigeon.HostOfferwallApi.cancel', codec, binaryMessenger: _binaryMessenger);
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

class _HostBookApiCodec extends StandardMessageCodec {
  const _HostBookApiCodec();
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

class Book {
  // memBirth: memBirth, memGen: memGen, memRegion: memRegion, memId: memId
  String? memBirth;
  String? memGen;
  String? memRegion;
  String? memId;
  String? firebaseKey;

  Book({this.memBirth, this.memGen, this.memRegion, this.memId, this.firebaseKey});

  Object encode() {
    final pigeonMap = <Object?, Object?>{};
    pigeonMap['memBirth'] = memBirth;
    pigeonMap['memGen'] = memGen;
    pigeonMap['memRegion'] = memRegion;
    pigeonMap['memId'] = memId;
    pigeonMap['firebaseKey'] = firebaseKey;
    return pigeonMap;
  }

  static Book decode(Object message) {
    final pigeonMap = message as Map<Object?, Object?>;
    return Book(
      memBirth: pigeonMap['memBirth'] as String?,
      memGen: pigeonMap['memGen'] as String?,
      memRegion: pigeonMap['memRegion'] as String?,
      memId: pigeonMap['memId'] as String?,
      firebaseKey: pigeonMap['firebaseKey'] as String?,
    );
  }
}
