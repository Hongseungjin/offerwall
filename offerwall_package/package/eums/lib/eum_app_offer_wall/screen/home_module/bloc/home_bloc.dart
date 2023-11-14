import 'dart:async';

import 'package:eums/eum_app_offer_wall/utils/loading_dialog.dart';
import 'package:eums/eum_app_offer_wall/widget/toast/app_alert.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';
import 'package:eums/common/local_store/local_store_service.dart';

import '../../../../api_eums_offer_wall/eums_offer_wall_service.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc()
      : _eumsOfferWallService = EumsOfferWallServiceApi(),
        // _localStore = LocalStoreService(),
        super(HomeState()) {
    // on<HomeEvent>(_onHomeToState);
    on<HomeInitEvent>(_onHomeInitEvent);
    on<HomeBannerEvent>(_onHomeBannerEvent);
    on<HomeListDataOfferWallEvent>(_onHomeListDataOfferWallEvent);
  }

  final EumsOfferWallService _eumsOfferWallService;
  // final LocalStore _localStore;

  // FutureOr<void> _onHomeToState(HomeEvent event, Emitter<HomeState> emit) async {
  //   if (event is ListOfferWall) {
  //     await _mapListOfferWall(event, emit);
  //   }
  //   if (event is InfoUser) {
  //     await _mapInfoUserToState(event, emit);
  //   }
  //   if (event is ListBanner) {
  //     await _mapListBannerToState(event, emit);
  //   }
  //   if (event is GetTotalPoint) {
  //     await _mapGetTotalPointToState(event, emit);
  //   }
  // }

  // _mapGetTotalPointToState(GetTotalPoint event, emit) async {
  //   emit(state.copyWith(getPointStatus: GetPointStatus.loading));
  //   try {
  //     dynamic totalPoint = await _eumsOfferWallService.getTotalPoint();
  //     emit(state.copyWith(getPointStatus: GetPointStatus.success, totalPoint: totalPoint));
  //     // print("useruser$totalPoint");
  //   } catch (ex) {
  //     emit(state.copyWith(getPointStatus: GetPointStatus.failure));
  //     // print("exexexex$ex");
  //   }
  // }

  // _mapInfoUserToState(InfoUser event, emit) async {
  //   try {
  //     dynamic user = await _eumsOfferWallService.userInfo();
  //     await LocalStoreService.instant.setDataUser(user);
  //     emit(state.copyWith(account: user));
  //     // print("useruser$user");
  //   } catch (ex) {
  //     // print("exexexex$ex");
  //   }
  // }

  // _mapListBannerToState(ListBanner event, emit) async {
  //   emit(state.copyWith(listAdverStatus: ListAdverStatus.loading));
  //   try {
  //     dynamic banner = await _eumsOfferWallService.getBanner(type: event.type);
  //     emit(state.copyWith(listAdverStatus: ListAdverStatus.success, bannerList: banner));
  //   } catch (ex) {
  //     emit(state.copyWith(listAdverStatus: ListAdverStatus.failure));
  //   }
  // }

  // _mapListOfferWall(ListOfferWall event, emit) async {
  //   emit(state.copyWith(listAdverStatus: ListAdverStatus.loading, listDataOfferWall: []));
  //   try {
  //     dynamic data = await _eumsOfferWallService.getListOfferWall(category: event.category, limit: event.limit, filter: event.filter);

  //     final listMap = (data as List).map((e) => e as Map<String, dynamic>).toList();
  //     emit(state.copyWith(listAdverStatus: ListAdverStatus.success, listDataOfferWall: listMap));
  //   } catch (ex) {
  //     emit(state.copyWith(listAdverStatus: ListAdverStatus.failure));
  //   }
  // }

  FutureOr<void> _onHomeInitEvent(HomeInitEvent event, Emitter<HomeState> emit) async {
    // LoadingDialog.instance.show();
    try {
      final totalPoint = await _eumsOfferWallService.getTotalPoint();
      final account = await _eumsOfferWallService.userInfo();
      await LocalStoreService.instant.setDataUser(account);
      // LoadingDialog.instance.hide();
      emit(HomeInitState(account: account, totalPoint: totalPoint));
    } catch (e) {
      // LoadingDialog.instance.hide();
      AppAlert.showError("$e");
    }
  }

  FutureOr<void> _onHomeBannerEvent(HomeBannerEvent event, Emitter<HomeState> emit) async {
    // LoadingDialog.instance.show();
    try {
      final bannerList = await _eumsOfferWallService.getBanner(type: event.type);
      // LoadingDialog.instance.hide();
      emit(HomeBannerState(bannerList: bannerList));
    } catch (e) {
      // LoadingDialog.instance.hide();
      AppAlert.showError("$e");
    }
  }

  FutureOr<void> _onHomeListDataOfferWallEvent(HomeListDataOfferWallEvent event, Emitter<HomeState> emit) async {
    // LoadingDialog.instance.show();
    try {
      emit(event.stateClient.copyWith(loading: true));
      final data = await _eumsOfferWallService.getListOfferWall(
        category: event.category,
        limit: event.stateClient.limit,
        offset: event.stateClient.offset,
        filter: event.filter,
      );
      final listMap = (data['data'] as List).map((e) => e as Map<String, dynamic>).toList();
      final total = data['total'];
      bool lastItem = !(total > event.stateClient.offset * event.stateClient.limit);
      // LoadingDialog.instance.hide();
      emit(event.stateClient.copyWith(
          listData: [...event.stateClient.listData ?? [], ...listMap],
          total: total,
          lastItem: lastItem,
          offset: event.stateClient.offset + event.stateClient.limit,
          loading: false));
    } catch (e) {
      LoadingDialog.instance.hide();
      AppAlert.showError("$e");
      emit(event.stateClient.copyWith(loading: false));
    }
  }
}
