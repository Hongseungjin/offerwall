import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';

import '../../../../api_eums_offer_wall/eums_offer_wall_service.dart';

part 'status_point_event.dart';
part 'status_point_state.dart';

class StatusPointBloc extends Bloc<StatusPointEvent, StatusPointState> {
  StatusPointBloc()
      : _eumsOfferWallService = EumsOfferWallServiceApi(),
        super(StatusPointState()) {
    on<StatusPointEvent>(_onStatusPointToState);
  }
  final EumsOfferWallService _eumsOfferWallService;

  FutureOr<void> _onStatusPointToState(
      StatusPointEvent event, Emitter<StatusPointState> emit) async {
    if (event is ListPoint) {
      await _mapListPoint(event, emit);
    }
    if (event is LoadMoreListPoint) {
      await _mapLoadListPoint(event, emit);
    }
    if (event is PointOutsideAdvertisinglList) {
      await _mapPointOutsideAdvertisinglListState(event, emit);
    }
    if (event is GetPoint) {
      await _mapGetPointListState(event, emit);
    }
  }

  _mapGetPointListState(GetPoint event, emit) async {
    try {
      dynamic data = await _eumsOfferWallService.getPointEarmed();
      print("datadatadata$data");

      emit(state.copyWith(dataTotalPoint: data));
    } catch (ex) {}
  }

  _mapLoadListPoint(LoadMoreListPoint event, emit) async {
    emit(state.copyWith(
        loadMoreListPointStatus: LoadMoreListPointStatus.loading));

    try {
      dynamic data = await _eumsOfferWallService.getPointEum(
          limit: event.limit,
          offset: event.offset,
          month: event.month,
          year: event.year);

      List<dynamic> dataCampaign = [];

      if (state.dataPoint != null) {
        dataCampaign = List.of(state.dataPoint!)..addAll(data);
      } else {
        dataCampaign = data;
      }
      emit(state.copyWith(
          loadMoreListPointStatus: LoadMoreListPointStatus.success,
          dataPoint: dataCampaign));
    } catch (ex) {
      emit(state.copyWith(
          loadMoreListPointStatus: LoadMoreListPointStatus.failure));
    }
  }

  _mapListPoint(ListPoint event, emit) async {
    emit(state.copyWith(loadListPointStatus: LoadListPointStatus.loading));

    try {
      dynamic data = await _eumsOfferWallService.getPointEum(
          limit: event.limit,
          offset: event.offset,
          month: event.month,
          year: event.year);
      emit(state.copyWith(
          loadListPointStatus: LoadListPointStatus.success, dataPoint: data));
    } catch (ex) {
      emit(state.copyWith(loadListPointStatus: LoadListPointStatus.failure));
    }
  }

  _mapPointOutsideAdvertisinglListState(
      PointOutsideAdvertisinglList event, emit) async {
    emit(state.copyWith(loadListPointStatus: LoadListPointStatus.loading));

    try {
      dynamic data = await _eumsOfferWallService.getPointOffWall(
          month: event.month, year: event.year);
      emit(state.copyWith(
          loadListPointStatus: LoadListPointStatus.success,
          dataPointOutsideAdvertising: data));
    } catch (ex) {
      emit(state.copyWith(loadListPointStatus: LoadListPointStatus.failure));
    }
  }
}
