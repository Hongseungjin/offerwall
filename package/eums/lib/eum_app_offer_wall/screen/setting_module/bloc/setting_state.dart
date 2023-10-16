part of 'setting_bloc.dart';

enum SettingStatus { initial, loading, success, failure }

enum UpdateSettingStatus { initial, loading, success, failure }

@immutable
class SettingState extends Equatable {
  const SettingState(
      {this.settingStatus = SettingStatus.initial,
      this.dataSetting,
      this.updateSettingStatus = UpdateSettingStatus.initial});
  final SettingStatus settingStatus;
  final UpdateSettingStatus updateSettingStatus;
  final dynamic dataSetting;

  SettingState copyWith(
      {UpdateSettingStatus? updateSettingStatus,
      SettingStatus? settingStatus,
      dynamic dataSetting}) {
    return SettingState(
        settingStatus: settingStatus ?? this.settingStatus,
        updateSettingStatus: updateSettingStatus ?? this.updateSettingStatus,
        dataSetting: dataSetting ?? this.dataSetting);
  }

  @override
  // TODO: implement props
  List<Object?> get props => [settingStatus, updateSettingStatus, dataSetting];
}
