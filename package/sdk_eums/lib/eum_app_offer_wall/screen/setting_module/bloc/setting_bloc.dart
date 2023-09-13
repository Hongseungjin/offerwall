import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';

part 'setting_event.dart';
part 'setting_state.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  SettingBloc()
      : _eumsOfferWallService = EumsOfferWallServiceApi(),
        super(SettingState()) {
    on<SettingEvent>(_onSettingToState);
  }
  final EumsOfferWallService _eumsOfferWallService;

  FutureOr<void> _onSettingToState(
      SettingEvent event, Emitter<SettingState> emit) async {
    if (event is SettingTime) {
      await _mapSettingTimeToState(event, emit);
    }
    if (event is GetSettingTime) {
      await _mapGetSettingTimeToState(event, emit);
    }
    if (event is EnableOrDisbleSetting) {
      await _mapEnableOrDisbleSettingToState(event, emit);
    }
  }

  _mapEnableOrDisbleSettingToState(EnableOrDisbleSetting event, emit) async {
    // emit(state.copyWith(updateSettingStatus: UpdateSettingStatus.loading));
    try {
      await _eumsOfferWallService.enableOrDisebleSettingTime(
          enable: event.enableOrDisble);
      // emit(state.copyWith(updateSettingStatus: UpdateSettingStatus.success));
    } catch (ex) {
      // emit(state.copyWith(updateSettingStatus: UpdateSettingStatus.failure));
    }
  }

  _mapSettingTimeToState(SettingTime event, emit) async {
    emit(state.copyWith(updateSettingStatus: UpdateSettingStatus.loading));
    try {
      await _eumsOfferWallService.createOrUpdateSettingTime(
          startTime: event.startTime, endTime: event.endTime);
      emit(state.copyWith(updateSettingStatus: UpdateSettingStatus.success));
    } catch (ex) {
      emit(state.copyWith(updateSettingStatus: UpdateSettingStatus.failure));
    }
  }

  _mapGetSettingTimeToState(GetSettingTime event, emit) async {
    emit(state.copyWith(settingStatus: SettingStatus.loading));
    try {
      dynamic dataSettingTime = await _eumsOfferWallService.getSettingTime();
      emit(state.copyWith(
          settingStatus: SettingStatus.success, dataSetting: dataSettingTime));
    } catch (ex) {
      emit(state.copyWith(settingStatus: SettingStatus.failure));
    }
  }
}
