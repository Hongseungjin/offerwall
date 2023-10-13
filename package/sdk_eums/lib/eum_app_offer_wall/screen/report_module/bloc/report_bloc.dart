import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';

part 'report_event.dart';
part 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  ReportBloc()
      : _eumsOfferWallService = EumsOfferWallServiceApi(),
        super(const ReportState()) {
    on<ReportEvent>(_onReportToState);
  }

  final EumsOfferWallService _eumsOfferWallService;

  FutureOr<void> _onReportToState(ReportEvent event, Emitter<ReportState> emit) async {
    if (event is ReportAdver) {
      await _mapReportToState(event, emit);
    }
    if (event is DeleteKeep) {
      await _mapDeleteKeepToState(event, emit);
    }
  }

  _mapDeleteKeepToState(DeleteKeep event, emit) async {
    emit(state.copyWith(deleteKeepStatus: DeleteKeepStatus.loading));
    try {
      await _eumsOfferWallService.deleteKeep(advertiseIdx: event.advertise_idx);
      emit(state.copyWith(
        deleteKeepStatus: DeleteKeepStatus.success,
      ));
    } catch (ex) {
      emit(state.copyWith(deleteKeepStatus: DeleteKeepStatus.failure));
    }
  }

  _mapReportToState(ReportAdver event, emit) async {
    emit(state.copyWith(reportStatus: ReportStatus.loading));
    try {
      await _eumsOfferWallService.reportAdver(adsIdx: event.idx, reason: event.reason ?? '', type: event.type);
      emit(state.copyWith(
        reportStatus: ReportStatus.success,
      ));
    } catch (ex) {
      emit(state.copyWith(reportStatus: ReportStatus.failure));
    }
  }
}
