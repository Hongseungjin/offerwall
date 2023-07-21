part of 'request_bloc.dart';

abstract class RequestEvent extends Equatable {}

class RequestInquire extends RequestEvent {
  RequestInquire({
    this.contents,
    this.type,
    this.deviceManufacturer,
    this.deviceModelName,
    this.deviceOsVersion,
    this.deviceSdkVersion,
    this.deviceAppVersion,
  });

  final String? type;
  final String? contents;
  final String? deviceManufacturer;
  final String? deviceModelName;
  final String? deviceOsVersion;
  final String? deviceSdkVersion;
  final String? deviceAppVersion;
  @override
  List<Object?> get props => [
        contents,
        type,
        deviceAppVersion,
        deviceManufacturer,
        deviceModelName,
        deviceOsVersion,
        deviceSdkVersion
      ];
}

class ListInquire extends RequestEvent {
  ListInquire({this.limit, this.offset});

  final dynamic limit;
  final dynamic offset;

  @override
  List<Object?> get props => [limit, offset];
}

class LoadMoreListInquire extends RequestEvent {
  LoadMoreListInquire({this.limit, this.offset});

  final dynamic limit;
  final dynamic offset;

  @override
  List<Object?> get props => [limit, offset];
}
