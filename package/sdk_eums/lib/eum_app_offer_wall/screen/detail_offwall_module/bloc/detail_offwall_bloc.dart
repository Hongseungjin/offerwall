import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../api_eums_offer_wall/eums_offer_wall_service.dart';
import '../../../../api_eums_offer_wall/eums_offer_wall_service_api.dart';

part 'detail_offwall_event.dart';
part 'detail_offwall_state.dart';

class DetailOffWallBloc extends Bloc<DetailOffWallEvent, DetailOffWallState> {
  DetailOffWallBloc()
      : _eumsOfferWallService = EumsOfferWallServiceApi(),
        super(const DetailOffWallState()) {
    on<DetailOffWallEvent>(mapEventToState);
  }

  final EumsOfferWallService _eumsOfferWallService;

  FutureOr<void> mapEventToState(DetailOffWallEvent event, emit) async {
    if (event is DetailOffWal) {
      await _mapDetailOffWallToState(event, emit);
    } else if (event is MissionCompleteOfferWall) {
      await _mapMissionOfferWallState(event, emit);
    }
  }

  _mapMissionOfferWallState(MissionCompleteOfferWall event, emit) async {
    emit(state.copyWith(
        missionCompleteOfferWallStatus:
            MissionCompleteOfferWallStatus.loading));
    try {
      await _eumsOfferWallService.missionOfferWallInternal(
          offerWallIdx: event.xId);
      emit(state.copyWith(
        missionCompleteOfferWallStatus: MissionCompleteOfferWallStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
          missionCompleteOfferWallStatus:
              MissionCompleteOfferWallStatus.failure));
    }
  }

  _mapDetailOffWallToState(DetailOffWal event, emit) async {
    emit(state.copyWith(detailOffWallStatus: DetailOffWallStatus.loading));
    try {
      dynamic data =
          await _eumsOfferWallService.getDetailOffWall(xId: event.xId);
      emit(state.copyWith(
          detailOffWallStatus: DetailOffWallStatus.success,
          dataDetailOffWall: data));
    } catch (e) {
      emit(state.copyWith(detailOffWallStatus: DetailOffWallStatus.failure));
    }
  }
}
