import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';

part 'notifi_event.dart';
part 'notifi_state.dart';

class NotifiBloc extends Bloc<NotifiEvent, NotifiState> {
  NotifiBloc()
      : _eumsOfferWallService = EumsOfferWallServiceApi(),
        super(NotifiState()) {
    on<NotifiEvent>(_onNotifiToState);
  }

  final EumsOfferWallService _eumsOfferWallService;

  FutureOr<void> _onNotifiToState(
      NotifiEvent event, Emitter<NotifiState> emit) async {
    if (event is ListNotifi) {
      await _mapListNotifi(event, emit);
    }
    if (event is LoadMoreListNotifi) {
      await _mapLoaMoreListNotifi(event, emit);
    }
  }

  _mapListNotifi(ListNotifi event, emit) async {
    emit(state.copyWith(listNotifiStatus: ListNotifiStatus.loading));
    try {
      dynamic data = await _eumsOfferWallService.getListNotifi(
        limit: event.limit,
      );
      emit(state.copyWith(
          listNotifiStatus: ListNotifiStatus.success, dataNotifi: data));
    } catch (e) {
      emit(state.copyWith(listNotifiStatus: ListNotifiStatus.failure));
    }
  }

  _mapLoaMoreListNotifi(LoadMoreListNotifi event, emit) async {
    emit(state.copyWith(
        loaMoreListNotifiStatus: LoaMoreListNotifiStatus.loading));
    try {
      dynamic data = await _eumsOfferWallService.getListNotifi(
          limit: event.limit, offset: event.offset);
      List<dynamic> dataNotifi = [];
      if (state.dataNotifi != null) {
        dataNotifi = List.of(state.dataNotifi!)..addAll(data);
      } else {
        dataNotifi = data;
      }
      emit(state.copyWith(
          loaMoreListNotifiStatus: LoaMoreListNotifiStatus.success,
          dataNotifi: dataNotifi));
    } catch (e) {
      emit(state.copyWith(
          loaMoreListNotifiStatus: LoaMoreListNotifiStatus.failure));
    }
  }
}
