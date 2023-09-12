import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:sdk_eums/common/local_store/local_store.dart';
import 'package:sdk_eums/common/local_store/local_store_service.dart';

import '../../../../api_eums_offer_wall/eums_offer_wall_service.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc()
      : _eumsOfferWallService = EumsOfferWallServiceApi(),
        _localStore = LocalStoreService(),
        super(HomeState()) {
    on<HomeEvent>(_onHomeToState);
  }

  final EumsOfferWallService _eumsOfferWallService;
  final LocalStore _localStore;

  FutureOr<void> _onHomeToState(
      HomeEvent event, Emitter<HomeState> emit) async {
    if (event is ListOfferWall) {
      await _mapListOfferWall(event, emit);
    }
    if (event is InfoUser) {
      await _mapInfoUserToState(event, emit);
    }
    if (event is ListBanner) {
      await _mapListBannerToState(event, emit);
    }
    if (event is GetTotalPoint) {
      await _mapGetTotalPointToState(event, emit);
    }
  }

  _mapGetTotalPointToState(GetTotalPoint event, emit) async {
    emit(state.copyWith(getPointStatus: GetPointStatus.loading));
    try {
      dynamic totalPoint = await _eumsOfferWallService.getTotalPoint();
      emit(state.copyWith(
          getPointStatus: GetPointStatus.success, totalPoint: totalPoint));
      print("useruser$totalPoint");
    } catch (ex) {
      emit(state.copyWith(getPointStatus: GetPointStatus.failure));
      print("exexexex$ex");
    }
  }

  _mapInfoUserToState(InfoUser event, emit) async {
    try {
      dynamic user = await _eumsOfferWallService.userInfo();
      emit(state.copyWith(account: user));
      print("useruser$user");
      _localStore.setDataUser(user);
    } catch (ex) {
      print("exexexex$ex");
    }
  }

  _mapListBannerToState(ListBanner event, emit) async {
    emit(state.copyWith(listAdverStatus: ListAdverStatus.loading));
    try {
      dynamic banner = await _eumsOfferWallService.getBanner(type: event.type);
      emit(state.copyWith(
          listAdverStatus: ListAdverStatus.success, bannerList: banner));
    } catch (ex) {
      emit(state.copyWith(listAdverStatus: ListAdverStatus.failure));
    }
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
