import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';

part 'purchase_offerwall_internal_event.dart';
part 'purchase_offerwall_internal_state.dart';

class PurchaseOfferwallInternalBloc
    extends Bloc<PuschaseOffWallEvent, PuschaseOffWallState> {
  PurchaseOfferwallInternalBloc()
      : _eumsOfferWallService = EumsOfferWallServiceApi(),
        super(const PuschaseOffWallState()) {
    on<PuschaseOffWallEvent>(mapEventToState);
  }
  final EumsOfferWallService _eumsOfferWallService;

  FutureOr<void> mapEventToState(PuschaseOffWallEvent event, emit) async {
    if (event is PuschaseOffWall) {
      await _mapMissionOfferWallState(event, emit);
    }
  }

  _mapMissionOfferWallState(PuschaseOffWall event, emit) async {
    emit(state.copyWith(
        puschaseOfferWallInternalStatus:
            PuschaseOfferWallInternalStatus.loading));
    try {
      await _eumsOfferWallService.missionOfferWallInternal(
          offerWallIdx: event.xId, lang: event.lang);
      emit(state.copyWith(
        puschaseOfferWallInternalStatus:
            PuschaseOfferWallInternalStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
          puschaseOfferWallInternalStatus:
              PuschaseOfferWallInternalStatus.failure));
    }
  }
}
