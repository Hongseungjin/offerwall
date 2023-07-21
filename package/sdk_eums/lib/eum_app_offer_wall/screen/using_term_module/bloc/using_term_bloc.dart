import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:sdk_eums/sdk_eums_library.dart';

part 'using_term_event.dart';
part 'using_term_state.dart';

class UsingTermnBloc extends Bloc<UsingTermEvent, UsingTermState> {
  UsingTermnBloc()
      : _eumsOfferWallService = EumsOfferWallServiceApi(),
        super(const UsingTermState(status: UsingTermStatus.initial)) {
    on<UsingTermEvent>(mapEventToState);
  }

  final EumsOfferWallService _eumsOfferWallService;

  FutureOr<void> mapEventToState(UsingTermEvent event, emit) async {
    if (event is UsingTerm) {
      await _mapUsingTermToState(event, emit);
    }
  }

  _mapUsingTermToState(UsingTerm event, emit) async {
    emit(state.copyWith(status: UsingTermStatus.loading));
    try {
      dynamic data = await _eumsOfferWallService.getUsingTerm();
      emit(state.copyWith(status: UsingTermStatus.success, dataUsingTerm: data));
    } catch (e) {
      emit(state.copyWith(status: UsingTermStatus.failure));
    }
  }
}
