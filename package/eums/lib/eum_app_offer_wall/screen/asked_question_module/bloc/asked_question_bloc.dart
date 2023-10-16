import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../api_eums_offer_wall/eums_offer_wall_service.dart';
import '../../../../api_eums_offer_wall/eums_offer_wall_service_api.dart';

part 'asked_question_event.dart';
part 'asked_question_state.dart';

class AskedQuestionBloc extends Bloc<AskedQuestionEvent, AskedQuestionState> {
  AskedQuestionBloc()
      : _eumsOfferWallService = EumsOfferWallServiceApi(),
        super(const AskedQuestionState(status: AskedQuestionStatus.initial)) {
    on<AskedQuestionEvent>(mapEventToState);
  }

  final EumsOfferWallService _eumsOfferWallService;

  FutureOr<void> mapEventToState(AskedQuestionEvent event, emit) async {
    if (event is AskedQuestion) {
      await _mapAskedQuestionToState(event, emit);
    } else if (event is LoadMoreAskedQuestion) {
      await _mapLoadMoreAskedQuestionToState(event, emit);
    }
  }

  _mapAskedQuestionToState(AskedQuestion event, emit) async {
    emit(state.copyWith(status: AskedQuestionStatus.loading));
    try {
      dynamic data = await _eumsOfferWallService.getQuestion(limit: event.limit, search: event.search);

      dynamic dataNew = data.map((e) {
        e['isExpanded'] = false;
        return e;
      }).toList();

      emit(state.copyWith(status: AskedQuestionStatus.success, dataUsingTerm: dataNew));
    } catch (e) {
      emit(state.copyWith(status: AskedQuestionStatus.failure));
    }
  }

  _mapLoadMoreAskedQuestionToState(LoadMoreAskedQuestion event, emit) async {
    emit(state.copyWith(loadMoreAskedQuestionStatus: LoadMoreAskedQuestionStatus.loading));
    try {
      dynamic data = await _eumsOfferWallService.getQuestion(limit: event.limit, offset: event.offset, search: event.search);

      List<dynamic> dataAsked = [];
      if (state.dataAskedQuestion != null) {
        dataAsked = List.of(state.dataAskedQuestion!)..addAll(data);
      } else {
        dataAsked = data;
      }
      dynamic dataList = dataAsked.map((e) {
        e['isExpanded'] = false;
        return e;
      }).toList();
      emit(state.copyWith(loadMoreAskedQuestionStatus: LoadMoreAskedQuestionStatus.success, dataUsingTerm: dataList));
    } catch (e) {
      emit(state.copyWith(loadMoreAskedQuestionStatus: LoadMoreAskedQuestionStatus.failure));
    }
  }
}
