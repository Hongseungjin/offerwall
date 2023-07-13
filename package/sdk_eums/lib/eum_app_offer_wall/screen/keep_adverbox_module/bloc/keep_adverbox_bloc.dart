import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:sdk_eums/sdk_eums_library.dart';

part 'keep_adverbox_event.dart';
part 'keep_adverbox_state.dart';

class KeepAdverboxBloc extends Bloc<KeepAdverboxEvent, KeepAdverboxState> {
  KeepAdverboxBloc()
      : _eumsOfferWallService = EumsOfferWallServiceApi(),
        super(KeepAdverboxState()) {
    on<KeepAdverboxEvent>(mapEventToState);
  }

  final EumsOfferWallService _eumsOfferWallService;

  FutureOr<void> mapEventToState(KeepAdverboxEvent event, emit) async {
    if (event is KeepAdverbox) {
      await _mapKeepAdverboxToState(event, emit);
    }
    if (event is LoadMoreKeepAdverbox) {
      await _mapLoadMoreKeepAdverboxToState(event, emit);
    } else if (event is DeleteKeep) {
      await _mapDeleteKeepAdverboxToState(event, emit);
    } else if (event is EarnPoin) {
      await _mapEarnPoinKeepAdverboxToState(event, emit);
    } else if (event is GetAdvertiseSponsor) {
      await _mapGetAdvertiseSponsorToState(event, emit);
    }
  }

  _mapGetAdvertiseSponsorToState(GetAdvertiseSponsor event, emit) async {
    try {
      dynamic data = await _eumsOfferWallService.getAdvertiseSponsor();
     

      emit(state.copyWith(dataAdvertiseSponsor: data));
    } catch (e) {}
  }

  _mapKeepAdverboxToState(KeepAdverbox event, emit) async {
    emit(state.copyWith(status: KeepAdverboxStatus.loading));
    try {
      dynamic data = await _eumsOfferWallService.getListKeep(
          limit: event.limit, offset: event.offset);

      emit(state.copyWith(
          status: KeepAdverboxStatus.success, dataKeepAdverbox: data));
    } catch (e) {
      emit(state.copyWith(status: KeepAdverboxStatus.failure));
    }
  }

  _mapLoadMoreKeepAdverboxToState(LoadMoreKeepAdverbox event, emit) async {
    emit(state.copyWith(statusLoadmore: LoadMoreKeepAdverboxStatus.loading));
    try {
      dynamic data = await _eumsOfferWallService.getListKeep(
          limit: event.limit, offset: event.offset);
      List<dynamic> dataKeep = [];
      if (state.dataKeepAdverbox != null) {
        dataKeep = List.of(state.dataKeepAdverbox!)..addAll(data);
      } else {
        dataKeep = data;
      }
      emit(state.copyWith(
          statusLoadmore: LoadMoreKeepAdverboxStatus.success,
          dataKeepAdverbox: dataKeep));
    } catch (e) {
      emit(state.copyWith(statusLoadmore: LoadMoreKeepAdverboxStatus.failure));
    }
  }

  _mapDeleteKeepAdverboxToState(DeleteKeep event, emit) async {
    emit(state.copyWith(deleteKeepStatus: DeleteKeepStatus.loading));
    try {
      await _eumsOfferWallService.deleteKeep(advertiseIdx: event.id);
      emit(state.copyWith(
        deleteKeepStatus: DeleteKeepStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(deleteKeepStatus: DeleteKeepStatus.failure));
    }
  }

  _mapEarnPoinKeepAdverboxToState(EarnPoin event, emit) async {
    emit(state.copyWith(adverKeepStatus: AdverKeepStatus.loading));
    try {
      await _eumsOfferWallService.missionOfferWallOutside(
          advertiseIdx: event.advertise_idx, pointType: event.pointType);
      emit(state.copyWith(
        adverKeepStatus: AdverKeepStatus.success,
      ));
    } catch (e) {
   
      emit(state.copyWith(adverKeepStatus: AdverKeepStatus.failure));
    }
  }
}
