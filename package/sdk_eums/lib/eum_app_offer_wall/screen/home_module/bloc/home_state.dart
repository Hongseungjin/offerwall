part of 'home_bloc.dart';

enum ListAdverStatus { initial, loading, success, failure }

enum LoadmoreListAdverStatus { initial, loading, success, failure }

@immutable
class HomeState extends Equatable {
  const HomeState(
      {this.listAdverStatus = ListAdverStatus.initial,
      this.loadmoreListAdverStatus = LoadmoreListAdverStatus.initial,
      this.account,
      this.bannerList,
      this.listDataOfferWall});

  final ListAdverStatus listAdverStatus;
  final LoadmoreListAdverStatus loadmoreListAdverStatus;
  final dynamic listDataOfferWall;
  final dynamic account;
  final dynamic bannerList;

  HomeState copyWith({
    ListAdverStatus? listAdverStatus,
    LoadmoreListAdverStatus? loadmoreListAdverStatus,
    dynamic listDataOfferWall,
    dynamic account,
    dynamic bannerList,
  }) {
    return HomeState(
        listAdverStatus: listAdverStatus ?? this.listAdverStatus,
        loadmoreListAdverStatus:
            loadmoreListAdverStatus ?? this.loadmoreListAdverStatus,
        listDataOfferWall: listDataOfferWall ?? this.listDataOfferWall,
        account: account ?? this.account,
        bannerList: bannerList ?? this.bannerList);
  }

  @override
  List<Object?> get props => [
        listDataOfferWall,
        listAdverStatus,
        account,
        loadmoreListAdverStatus,
        bannerList
      ];
}
