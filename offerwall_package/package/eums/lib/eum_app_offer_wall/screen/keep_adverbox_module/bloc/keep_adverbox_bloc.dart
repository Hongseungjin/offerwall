import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:eums/eums_library.dart';

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
    } else if (event is SaveScrap) {
      await _mapSaveKeepAdverboxToState(event, emit);
    } else if (event is SaveKeep) {
      await _mapSaveKeepAdverToState(event, emit);
    } else if (event is DeleteScrap) {
      await _mapDeleteScrapAdverboxToState(event, emit);
    }
  }

  _mapSaveKeepAdverToState(SaveKeep event, emit) async {
    emit(state.copyWith(saveKeepStatus: SaveKeepStatus.initial));

    try {
      await _eumsOfferWallService.saveKeep(advertiseIdx: event.id, adType: event.adType);
      emit(state.copyWith(saveKeepStatus: SaveKeepStatus.success));
    } catch (ex) {
      emit(state.copyWith(saveKeepStatus: SaveKeepStatus.failure));
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
      dynamic data = await _eumsOfferWallService.getListKeep(limit: event.limit, offset: event.offset);

      emit(state.copyWith(status: KeepAdverboxStatus.success, dataKeepAdverbox: data));
    } catch (e) {
      emit(state.copyWith(status: KeepAdverboxStatus.failure));
    }
  }

  _mapLoadMoreKeepAdverboxToState(LoadMoreKeepAdverbox event, emit) async {
    emit(state.copyWith(statusLoadmore: LoadMoreKeepAdverboxStatus.loading));
    try {
      dynamic data = await _eumsOfferWallService.getListKeep(limit: event.limit, offset: event.offset);
      List<dynamic> dataKeep = [];
      if (state.dataKeepAdverbox != null) {
        dataKeep = List.of(state.dataKeepAdverbox!)..addAll(data);
      } else {
        dataKeep = data;
      }
      emit(state.copyWith(statusLoadmore: LoadMoreKeepAdverboxStatus.success, dataKeepAdverbox: dataKeep));
    } catch (e) {
      emit(state.copyWith(statusLoadmore: LoadMoreKeepAdverboxStatus.failure));
    }
  }

  _mapDeleteKeepAdverboxToState(DeleteKeep event, emit) async {
    emit(state.copyWith(deleteKeepStatus: DeleteKeepStatus.loading));
    try {
      await _eumsOfferWallService.deleteKeep(idx: event.idx);
      emit(state.copyWith(
        deleteKeepStatus: DeleteKeepStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(deleteKeepStatus: DeleteKeepStatus.failure));
    }
  }

  _mapSaveKeepAdverboxToState(SaveScrap event, emit) async {
    emit(state.copyWith(saveScrapStatus: SaveScrapStatus.loading));
    try {
      await _eumsOfferWallService.saveScrap(advertiseIdx: event.advertiseIdx, adType: event.adType);
      emit(state.copyWith(
        saveScrapStatus: SaveScrapStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(saveScrapStatus: SaveScrapStatus.failure));
    }
  }

  _mapDeleteScrapAdverboxToState(DeleteScrap event, emit) async {
    try {
      await _eumsOfferWallService.deleteScrap(idx: event.idx);
    } catch (e) {}
  }

  _mapEarnPoinKeepAdverboxToState(EarnPoin event, emit) async {
    emit(state.copyWith(adverKeepStatus: AdverKeepStatus.loading));
    try {
      await _eumsOfferWallService.missionOfferWallOutside(advertiseIdx: event.advertiseIdx, pointType: event.pointType);
      emit(state.copyWith(
        adverKeepStatus: AdverKeepStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(adverKeepStatus: AdverKeepStatus.failure));
    }
  }
}
