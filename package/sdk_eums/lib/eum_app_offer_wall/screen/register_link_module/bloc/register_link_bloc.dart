import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';

part 'register_link_event.dart';
part 'register_link_state.dart';

class RegisterLinkBloc extends Bloc<RegisterLinkEvent, RegisterLinkState> {
  RegisterLinkBloc()
      : _eumsOfferWallService = EumsOfferWallServiceApi(),
        super(RegisterLinkState()) {
    on<RegisterLinkEvent>(mapEventToState);
  }
  final EumsOfferWallService _eumsOfferWallService;

  FutureOr<void> mapEventToState(RegisterLinkEvent event, emit) async {
    if (event is MissionOfferWallRegisterLink) {
      await _mapMissionOfferWallRegisterLinkToState(event, emit);
    }
  }

  _mapMissionOfferWallRegisterLinkToState(
      MissionOfferWallRegisterLink event, emit) async {
    emit(state.copyWith(registerLinkStatus: RegisterLinkStatus.loading));
    try {
      await _eumsOfferWallService
          .uploadImageOfferWallInternal(files: event.files)
          .then((value) {

        _eumsOfferWallService.missionOfferWallInternal(
            offerWallIdx: event.xId, urlImage: value[0]);
      });

      emit(state.copyWith(registerLinkStatus: RegisterLinkStatus.success));
    } catch (ex) {
      
      emit(state.copyWith(registerLinkStatus: RegisterLinkStatus.failure));
    }
  }
}
