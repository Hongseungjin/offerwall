import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:sdk_eums/sdk_eums_library.dart';

part 'request_event.dart';
part 'request_state.dart';

class RequestBloc extends Bloc<RequestEvent, RequestState> {
  RequestBloc()
      : _eumsOfferWallService = EumsOfferWallServiceApi(),
        super(const RequestState()) {
    on<RequestEvent>(mapEventToState);
  }

  final EumsOfferWallService _eumsOfferWallService;

  FutureOr<void> mapEventToState(RequestEvent event, emit) async {
    if (event is RequestInquire) {
      await _mapInquireToState(event, emit);
    } else if (event is ListInquire) {
      await _mapListInquireToState(event, emit);
    } else if (event is LoadMoreListInquire) {
      await _mapLoadMoreListInquireToState(event, emit);
    }
  }

  _mapInquireToState(RequestInquire event, emit) async {
    emit(state.copyWith(inquireStatus: InquireStatus.loading));
    try {
      await _eumsOfferWallService.createInquire(
          content: event.contents,
          type: event.type,
          title: event.title,
          deviceAppVersion: event.deviceOsVersion,
          deviceManufacturer: event.deviceManufacturer,
          deviceModelName: event.deviceModelName,
          deviceOsVersion: event.deviceOsVersion,
          deviceSdkVersion: event.deviceSdkVersion);
      emit(state.copyWith(
        inquireStatus: InquireStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(inquireStatus: InquireStatus.failure));
    }
  }

  _mapListInquireToState(ListInquire event, emit) async {
    emit(state.copyWith(inquireListStatus: InquireListStatus.loading));
    try {
      dynamic data =
          await _eumsOfferWallService.getListInquire(limit: event.limit);
      emit(state.copyWith(
          inquireListStatus: InquireListStatus.success, dataListInquire: data));
    } catch (e) {
      emit(state.copyWith(inquireListStatus: InquireListStatus.failure));
    }
  }

  _mapLoadMoreListInquireToState(LoadMoreListInquire event, emit) async {
    emit(state.copyWith(
        inquireLoadMoreListStatus: InquireLoadMoreListStatus.loading));
    try {
      dynamic data = await _eumsOfferWallService.getListInquire(
          limit: event.limit, offset: event.offset);
      List<dynamic> dataRequest = [];
      if (state.dataListInquire != null) {
        dataRequest = List.of(state.dataListInquire!)..addAll(data);
      } else {
        dataRequest = data;
      }

      emit(state.copyWith(
          inquireLoadMoreListStatus: InquireLoadMoreListStatus.success,
          dataListInquire: dataRequest));
    } catch (e) {
      emit(state.copyWith(
          inquireLoadMoreListStatus: InquireLoadMoreListStatus.failure));
    }
  }
}
