part of 'setting_bloc.dart';

@immutable
abstract class SettingEvent extends Equatable {
  const SettingEvent();
}

class NextTab extends SettingEvent {
  const NextTab();

  @override
  List<Object?> get props => [];
}
