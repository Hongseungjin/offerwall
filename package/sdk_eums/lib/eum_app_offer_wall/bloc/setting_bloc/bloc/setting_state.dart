part of 'setting_bloc.dart';

enum AppSettingStatus { initial, loading, success, failure }

class SettingState extends Equatable {
  const SettingState(
      {this.appSettingStatus = AppSettingStatus.initial, this.account})
      : super();

  final AppSettingStatus appSettingStatus;
  final dynamic account;

  SettingState copyWith(
      {AppSettingStatus? appSettingStatus, dynamic account}) {
    return SettingState(
        appSettingStatus: appSettingStatus ?? this.appSettingStatus,
        account: account ?? this.account);
  }

  @override
  // TODO: implement props
  List<Object?> get props => [appSettingStatus, account];
}
