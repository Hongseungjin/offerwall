part of 'setting_bloc.dart';

@immutable
abstract class SettingEvent extends Equatable {}

class SettingTime extends SettingEvent {
  SettingTime({this.startTime, this.endTime});

  final dynamic startTime;
  final dynamic endTime;
  @override
  List<Object?> get props => [endTime, startTime];
}

class EnableOrDisbleSetting extends SettingEvent {
  EnableOrDisbleSetting({this.enableOrDisble});
  final bool? enableOrDisble;

  @override
  List<Object?> get props => [enableOrDisble];
}

class GetSettingTime extends SettingEvent {
  GetSettingTime();

  @override
  List<Object?> get props => [];
}
