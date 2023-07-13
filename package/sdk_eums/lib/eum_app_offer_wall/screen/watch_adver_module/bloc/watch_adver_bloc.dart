import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:sdk_eums/sdk_eums_library.dart';

part 'watch_adver_event.dart';
part 'watch_adver_state.dart';

class WatchAdverBloc extends Bloc<WatchAdverEvent, WatchAdverState> {
  WatchAdverBloc()
      : _eumsOfferWallService = EumsOfferWallServiceApi(),
        super(WatchAdverState()) {
    on<WatchAdverEvent>(mapEventToState);
  }

  final EumsOfferWallService _eumsOfferWallService;

  FutureOr<void> mapEventToState(WatchAdverEvent event, emit) async {
    if (event is EarnPoin) {
      await _mapEarnCashToState(event, emit);
    } else if (event is SaveAdver) {
      await _mapSaveAdverToState(event, emit);
    } else if (event is DeleteScrap) {
      await _mapDeleteScrapToState(event, emit);
    }
  }

  _mapDeleteScrapToState(DeleteScrap event, emit) async {
    emit(state.copyWith(deleteScrapStatus: DeleteScrapStatus.loading));
    try {
      await _eumsOfferWallService.deleteScrap(
          advertiseIdx: int.parse(event.id.toString()));
      emit(state.copyWith(
        deleteScrapStatus: DeleteScrapStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(deleteScrapStatus: DeleteScrapStatus.failure));
    }
  }

  _mapEarnCashToState(EarnPoin event, emit) async {
    emit(state.copyWith(earnMoneyStatus: EarnMoneyStatus.loading));
    try {
      await _eumsOfferWallService.missionOfferWallOutside(
          advertiseIdx: int.parse(event.advertise_idx.toString()),
          pointType: event.pointType);

      emit(state.copyWith(
        earnMoneyStatus: EarnMoneyStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(earnMoneyStatus: EarnMoneyStatus.failure));
    }
  }

  _mapSaveAdverToState(SaveAdver event, emit) async {
    print('save');
    emit(
        state.copyWith(saveKeepAdverboxStatus: SaveKeepAdverboxStatus.loading));
    try {
      await _eumsOfferWallService.saveScrap(
          advertiseIdx: int.parse(event.advertise_idx.toString()));

      emit(state.copyWith(
        saveKeepAdverboxStatus: SaveKeepAdverboxStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
          saveKeepAdverboxStatus: SaveKeepAdverboxStatus.failure));
    }
  }
}
