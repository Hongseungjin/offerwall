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

// class UpdateUser extends SettingEvent {
//   UpdateUser({this.account});

//   final dynamic account;
//   @override
//   List<Object?> get props => [account];
// }

// class InfoUser extends SettingEvent {
//   InfoUser({this.account});

//   final dynamic account;
//   @override
//   List<Object?> get props => [account];
// }
