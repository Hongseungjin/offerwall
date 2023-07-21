import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:sdk_eums/sdk_eums_library.dart';

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
      dynamic data = await _eumsOfferWallService.getQuestion(
          limit: event.limit, search: event.search);
      emit(state.copyWith(
          status: AskedQuestionStatus.success, dataUsingTerm: data));
    } catch (e) {
      emit(state.copyWith(status: AskedQuestionStatus.failure));
    }
  }

  _mapLoadMoreAskedQuestionToState(LoadMoreAskedQuestion event, emit) async {
    emit(state.copyWith(
        loadMoreAskedQuestionStatus: LoadMoreAskedQuestionStatus.loading));
    try {
      dynamic data = await _eumsOfferWallService.getQuestion(
          limit: event.limit, offset: event.offset, search: event.search);

      List<dynamic> dataAsked = [];
      if (state.dataAskedQuestion != null) {
        dataAsked = List.of(state.dataAskedQuestion!)..addAll(data);
      } else {
        dataAsked = data;
      }
      emit(state.copyWith(
          loadMoreAskedQuestionStatus: LoadMoreAskedQuestionStatus.success,
          dataUsingTerm: dataAsked));
    } catch (e) {
      emit(state.copyWith(
          loadMoreAskedQuestionStatus: LoadMoreAskedQuestionStatus.failure));
    }
  }
}
