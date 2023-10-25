import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:eums/eums_library.dart';

part 'scrap_adverbox_event.dart';
part 'scrap_adverbox_state.dart';

class ScrapAdverboxBloc extends Bloc<ScrapAdverboxEvent, ScrapAdverboxState> {
  ScrapAdverboxBloc()
      : _eumsOfferWallService = EumsOfferWallServiceApi(),
        super(ScrapAdverboxState()) {
    on<ScrapAdverboxEvent>(mapEventToState);
  }

  final EumsOfferWallService _eumsOfferWallService;

  FutureOr<void> mapEventToState(ScrapAdverboxEvent event, emit) async {
    if (event is ScrapAdverbox) {
      await _mapKeepAdverboxToState(event, emit);
    } else if (event is LoadMoreScrapAdverbox) {
      await _mapLoadMoreKeepAdverboxToState(event, emit);
    } else if (event is DeleteScrapdverbox) {
      await _mapSaveScrapdverboxToState(event, emit);
    }
  }

  _mapLoadMoreKeepAdverboxToState(LoadMoreScrapAdverbox event, emit) async {
    emit(state.copyWith(statusLoadMore: LoadMoreScrapAdverboxStatus.loading));
    try {
      dynamic data = await _eumsOfferWallService.getListScrap(limit: event.limit, offset: event.offset, sort: event.sort);

      List<dynamic> dataScrap = [];
      if (state.dataScrapAdverbox != null) {
        dataScrap = List.of(state.dataScrapAdverbox!)..addAll(data);
      } else {
        dataScrap = data;
      }
      emit(state.copyWith(statusLoadMore: LoadMoreScrapAdverboxStatus.success, dataScrapAdverbox: dataScrap));
    } catch (e) {
      emit(state.copyWith(statusLoadMore: LoadMoreScrapAdverboxStatus.failure));
    }
  }

  _mapKeepAdverboxToState(ScrapAdverbox event, emit) async {
    emit(state.copyWith(status: ScrapAdverboxStatus.loading));
    try {
      dynamic data = await _eumsOfferWallService.getListScrap(limit: event.limit, offset: event.offset, sort: event.sort);

      emit(state.copyWith(status: ScrapAdverboxStatus.success, dataScrapAdverbox: data));
    } catch (e) {
      emit(state.copyWith(status: ScrapAdverboxStatus.failure));
    }
  }

  _mapSaveScrapdverboxToState(DeleteScrapdverbox event, emit) async {
    emit(state.copyWith(deleteScrapAdverboxStatus: DeleteScrapAdverboxStatus.loading));
    try {
      await _eumsOfferWallService.deleteScrap(idx: event.idx);
      emit(state.copyWith(
        deleteScrapAdverboxStatus: DeleteScrapAdverboxStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(deleteScrapAdverboxStatus: DeleteScrapAdverboxStatus.failure));
    }
  }
}
