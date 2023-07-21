import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';

part 'visit_offerwall_event.dart';
part 'visit_offerwall_state.dart';

class VisitOfferwallInternalBloc
    extends Bloc<VisitOffWallEvent, VisitOfferWallInternalState> {
  VisitOfferwallInternalBloc()
      : _eumsOfferWallService = EumsOfferWallServiceApi(),
        super(const VisitOfferWallInternalState()) {
    on<VisitOffWallEvent>(mapEventToState);
  }
  final EumsOfferWallService _eumsOfferWallService;

  FutureOr<void> mapEventToState(VisitOffWallEvent event, emit) async {
    if (event is VisitOffWall) {
      await _mapVisitOffWallState(event, emit);
    }
  }

  _mapVisitOffWallState(VisitOffWall event, emit) async {
    emit(state.copyWith(
        visitOfferWallInternalStatus: VisitOfferWallInternalStatus.loading));
    try {
      await _eumsOfferWallService.missionOfferWallInternal(
          offerWallIdx: event.xId, lang: event.lang);
      emit(state.copyWith(
        visitOfferWallInternalStatus: VisitOfferWallInternalStatus.success,
      ));
    } catch (e) {
      print("eeeeeee$e");
      emit(state.copyWith(
          visitOfferWallInternalStatus: VisitOfferWallInternalStatus.failure));
    }
  }
}
