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
  EnableOrDisbleSetting();

  @override
  List<Object?> get props => [];
}
