import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../api_eums_offer_wall/eums_offer_wall_service.dart';
import '../../../../api_eums_offer_wall/eums_offer_wall_service_api.dart';
import '../../../../common/local_store/local_store.dart';
import '../../../../common/local_store/local_store_service.dart';

part 'accumulate_money_even.dart';
part 'accumulate_money_state.dart';

class AccumulateMoneyBloc extends Bloc<AccumulateMoneyEvent, AccumulateMoneyState> {
  AccumulateMoneyBloc()
      : _eumsOfferWallService = EumsOfferWallServiceApi(),
        // _localStore = LocalStoreService(),
        super(const AccumulateMoneyState()) {
    on<AccumulateMoneyEvent>(mapEventToState);
  }

  final EumsOfferWallService _eumsOfferWallService;
  // final LocalStore _localStore;

  FutureOr<void> mapEventToState(AccumulateMoneyEvent event, emit) async {
    if (event is AccumulateMoneyList) {
      await _mapEarnCashListToState(event, emit);
    } else if (event is ListOfferWall) {
      await _mapListOfferWallToState(event, emit);
    } else if (event is LoadmoreListOfferWall) {
      await _mapLoadMoreListOfferWallToState(event, emit);
    } else if (event is OnOrOffAdver) {
      await _mapOnOrOffAdverToState(event, emit);
    } else if (event is GetOnOrOffAdver) {
      await _mapGetOnOrOffAdverToState(event, emit);
    } else if (event is NextPageOverlay) {
      await _mapNextPageOverlayToState(event, emit);
      // } else if (event is GetToken) {
      //   await _mapGetTokenToState(event, emit);
    } else if (event is SaveKeepAdver) {
      await _mapSaveKeepAdverToState(event, emit);
    } else if (event is InfoUser) {
      await _mapInfoUserToState(event, emit);
    }
  }

  _mapInfoUserToState(InfoUser event, emit) async {
    try {
      dynamic user = await _eumsOfferWallService.userInfo();
      emit(state.copyWith(account: user));
    } catch (ex) {}
  }

  _mapSaveKeepAdverToState(SaveKeepAdver event, emit) async {
    emit(state.copyWith(saveKeepStatus: SaveKeepStatus.loading));
    try {
      await _eumsOfferWallService.saveKeep(advertiseIdx: event.advertiseIdx, adType: event.adType);
      emit(state.copyWith(saveKeepStatus: SaveKeepStatus.success));
    } catch (ex) {
      emit(state.copyWith(saveKeepStatus: SaveKeepStatus.failure));
    }
  }

  // _mapGetTokenToState(GetToken event, emit) async {
  //   await _advertisementService.getTokenNotifi(token: event.token);
  //   emit(state.copyWith());
  // }

  _mapGetOnOrOffAdverToState(GetOnOrOffAdver event, emit) async {
    bool check = LocalStoreService.instant.getSaveAdver();
    emit(state.copyWith(checkOnOffAdver: check));
  }

  _mapOnOrOffAdverToState(OnOrOffAdver event, emit) async {
    await LocalStoreService.instant.setSaveAdver(event.checkOnOff ?? false);
  }

  _mapEarnCashListToState(AccumulateMoneyList event, emit) async {
    emit(state.copyWith(accumulateMoneyStatus: AccumulateMoneyStatus.loading));
    try {
      dynamic data = await _eumsOfferWallService.getListOfferWall();
      emit(state.copyWith(
          accumulateMoneyStatus: AccumulateMoneyStatus.success, dataAccumulateMoney: data['result_code'] == 'S0000' ? data['response'] : null));
    } catch (e) {
      emit(state.copyWith(accumulateMoneyStatus: AccumulateMoneyStatus.failure));
    }
  }

  _mapListOfferWallToState(ListOfferWall event, emit) async {
    emit(state.copyWith(listOfferWallStatus: ListOfferWallStatus.loading));
    try {
      dynamic data = await _eumsOfferWallService.getListOfferWall(category: event.category, limit: event.limit, filter: event.filter);
      emit(state.copyWith(listOfferWallStatus: ListOfferWallStatus.success, dataListOfferWall: data));
    } catch (e) {
      emit(state.copyWith(listOfferWallStatus: ListOfferWallStatus.failure));
    }
  }

  _mapLoadMoreListOfferWallToState(LoadmoreListOfferWall event, emit) async {
    emit(state.copyWith(listOfferWallStatus: ListOfferWallStatus.loading));
    try {
      dynamic data =
          await _eumsOfferWallService.getListOfferWall(category: event.category, limit: event.limit, offset: event.offset, filter: event.filter);
      List<dynamic> dataCampaign = [];
      if (state.dataListOfferWall != null) {
        dataCampaign = List.of(state.dataListOfferWall!)..addAll(data);
      } else {
        dataCampaign = data;
      }
      emit(state.copyWith(listOfferWallStatus: ListOfferWallStatus.success, dataListOfferWall: dataCampaign));
    } catch (e) {
      emit(state.copyWith(listOfferWallStatus: ListOfferWallStatus.failure));
    }
  }

  _mapNextPageOverlayToState(NextPageOverlay event, emit) async {
    emit(state.copyWith(nextPageStatus: NextPageStatus.loading));
    try {
      emit(state.copyWith(
        nextPageStatus: NextPageStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(nextPageStatus: NextPageStatus.failure));
    }
  }
}
