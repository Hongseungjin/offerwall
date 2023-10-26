import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../api_eums_offer_wall/eums_offer_wall_service.dart';
import '../../../../api_eums_offer_wall/eums_offer_wall_service_api.dart';
import '../../../../common/local_store/local_store.dart';
import '../../../../common/local_store/local_store_service.dart';

part 'setting_event.dart';
part 'setting_state.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  SettingBloc()
      : _eumsOfferWallService = EumsOfferWallServiceApi(),
        // _localStore = LocalStoreService(),
        super(const SettingState()) {
    on<SettingEvent>(mapEventToState);
  }

  final EumsOfferWallService _eumsOfferWallService;
  // final LocalStore _localStore;

  FutureOr<void> mapEventToState(SettingEvent event, emit) async {
    if (event is NextTab) {
      await _mapNextTabToState(event, emit);
      // } else if (event is UpdateUser) {
      //   await _mapUpdateUserToState(event, emit);
      // } else if (event is InfoUser) {
      //   await _mapInfoUserToState(event, emit);
    }
  }

  // _mapInfoUserToState(InfoUser event, emit) async {
  //   try {
  //     dynamic user = await _eumsOfferWallService.userInfo();
  //     emit(state.copyWith(account: user));
  //   } catch (ex) {}
  // }

  // _mapUpdateUserToState(UpdateUser event, emit) async {
  //   emit(state.copyWith(appSettingStatus: AppSettingStatus.loading));
  //   try {
  //     emit(state.copyWith(appSettingStatus: AppSettingStatus.success));
  //   } catch (ex) {
  //     emit(state.copyWith(appSettingStatus: AppSettingStatus.failure));
  //   }
  // }

  _mapNextTabToState(SettingEvent event, emit) async {
    emit(state.copyWith(appSettingStatus: AppSettingStatus.loading));
    try {
      emit(state.copyWith(appSettingStatus: AppSettingStatus.success));
    } catch (ex) {
      emit(state.copyWith(appSettingStatus: AppSettingStatus.failure));
    }
  }
}
