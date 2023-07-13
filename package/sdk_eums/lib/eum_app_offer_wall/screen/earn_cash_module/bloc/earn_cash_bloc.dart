import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';

part 'earn_cash_event.dart';
part 'earn_cash_state.dart';

class EarnCashBloc extends Bloc<EarnCashEvent, EarnCashState> {
  EarnCashBloc()
      : _eumsOfferWallService = EumsOfferWallServiceApi(),
        super(const EarnCashState()) {
    on<EarnCashEvent>(mapEventToState);
  }

  final EumsOfferWallService _eumsOfferWallService;

  FutureOr<void> mapEventToState(EarnCashEvent event, emit) async {
    if (event is EarnCashList) {
      await _mapEarnCashListToState(event, emit);
    } else if (event is PointOfferWallList) {
      await _mapPointOfferWallListToState(event, emit);
    }
    
  }
  
  _mapEarnCashListToState(EarnCashList event, emit) async {
    emit(state.copyWith(earnCashStatus: EarnCashStatus.loading));
    try {
      dynamic data =
          await _eumsOfferWallService.getPointEum();
      emit(state.copyWith(
          earnCashStatus: EarnCashStatus.success, dataEarnCash: data));
    } catch (e) {
      emit(state.copyWith(earnCashStatus: EarnCashStatus.failure));
    }
  }

  _mapPointOfferWallListToState(PointOfferWallList event, emit) async {
    emit(state.copyWith(earnCashStatus: EarnCashStatus.loading));
    try {
      dynamic data = await _eumsOfferWallService.getPointOffWall();

      emit(state.copyWith(
          earnCashStatus: EarnCashStatus.success, dataPointOffer: data));
    } catch (e) {
      emit(state.copyWith(earnCashStatus: EarnCashStatus.failure));
    }
  }
}
