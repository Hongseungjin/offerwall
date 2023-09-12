import 'dart:async';

// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service.dart';
import 'package:sdk_eums/api_eums_offer_wall/eums_offer_wall_service_api.dart';

part 'my_page_event.dart';
part 'my_page_state.dart';

class MyPageBloc extends Bloc<MyPageEvent, MyPageState> {
  MyPageBloc()
      : _eumsOfferWallService = EumsOfferWallServiceApi(),
        super(MyPageState()) {
    on<MyPageEvent>(_onHomeToState);
  }

  final EumsOfferWallService _eumsOfferWallService;

  FutureOr<void> _onHomeToState(
      MyPageEvent event, Emitter<MyPageState> emit) async {
    if (event is ListBanner) {
      await _mapListBannerToState(event, emit);
    }
  }

  _mapListBannerToState(ListBanner event, emit) async {
    emit(state.copyWith(loadBannerStatus: LoadBannerStatus.loading));
    try {
      dynamic banner = await _eumsOfferWallService.getBanner(type: event.type);
      emit(state.copyWith(
          loadBannerStatus: LoadBannerStatus.success, listBanner: banner));
    } catch (ex) {
      emit(state.copyWith(loadBannerStatus: LoadBannerStatus.failure));
    }
  }
}
