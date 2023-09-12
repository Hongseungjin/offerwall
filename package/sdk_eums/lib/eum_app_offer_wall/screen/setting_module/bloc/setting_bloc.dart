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
  }

  _mapSettingTimeToState(SettingTime event, emit) async {
    emit(state.copyWith(settingStatus: SettingStatus.loading));
    try {
      // dynamic banner = await _eumsOfferWallService.getBanner(type: event.type);
      emit(state.copyWith(
        settingStatus: SettingStatus.success,
      ));
    } catch (ex) {
      emit(state.copyWith(settingStatus: SettingStatus.failure));
    }
  }
}
