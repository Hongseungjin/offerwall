import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';

import '../../../../api_eums_offer_wall/eums_offer_wall_service.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc()
      : _eumsOfferWallService = EumsOfferWallServiceApi(),
        super(HomeState()) {
    on<HomeEvent>(_onHomeToState);
  }

  final EumsOfferWallService _eumsOfferWallService;

  FutureOr<void> _onHomeToState(
      HomeEvent event, Emitter<HomeState> emit) async {
    if (event is ListOfferWall) {
      await _mapListOfferWall(event, emit);
    }
    if (event is InfoUser) {
      await _mapInfoUserToState(event, emit);
    }
  }

  _mapInfoUserToState(InfoUser event, emit) async {
    try {
      dynamic user = await _eumsOfferWallService.userInfo();
      emit(state.copyWith(account: user));
    } catch (ex) {}
  }

  _mapListOfferWall(ListOfferWall event, emit) async {
    emit(state.copyWith(listAdverStatus: ListAdverStatus.loading));

    try {
      dynamic data = await _eumsOfferWallService.getListOfferWall(
          category: event.category, limit: event.limit, filter: event.filter);
      emit(state.copyWith(
          listAdverStatus: ListAdverStatus.success, listDataOfferWall: data));
    } catch (ex) {
      emit(state.copyWith(listAdverStatus: ListAdverStatus.failure));
    }
  }
}
