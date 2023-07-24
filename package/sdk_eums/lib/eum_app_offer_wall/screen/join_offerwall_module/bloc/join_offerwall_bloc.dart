import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';

part 'join_offerwall_event.dart';
part 'join_offerwall_state.dart';

class JoinOfferwallInternalBloc
    extends Bloc<JoinOffWallEvent, JoinOffWallState> {
  JoinOfferwallInternalBloc()
      : _eumsOfferWallService = EumsOfferWallServiceApi(),
        super(const JoinOffWallState()) {
    on<JoinOffWallEvent>(mapEventToState);
  }
  final EumsOfferWallService _eumsOfferWallService;

  FutureOr<void> mapEventToState(JoinOffWallEvent event, emit) async {
    if (event is JoinOffWall) {
      await _mapsJoinOffWallState(event, emit);
    }
  }

  _mapsJoinOffWallState(JoinOffWall event, emit) async {
    emit(state.copyWith(joinOfferWallStatus: JoinOfferWallStatus.loading));
    try {
      await _eumsOfferWallService.missionOfferWallInternal(
          offerWallIdx: event.xId, lang: event.lang);
      emit(state.copyWith(
        joinOfferWallStatus: JoinOfferWallStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(joinOfferWallStatus: JoinOfferWallStatus.failure));
    }
  }
}
