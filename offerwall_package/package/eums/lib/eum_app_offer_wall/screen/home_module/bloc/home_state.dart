part of 'home_bloc.dart';

class HomeState {}

class HomeInitState extends HomeState {
  final dynamic account;
  final dynamic totalPoint;

  HomeInitState({
    required this.account,
    required this.totalPoint,
  });
}

class HomeBannerState extends HomeState {
  final dynamic bannerList;

  HomeBannerState({required this.bannerList});
}

class HomeListDataOfferWallState extends HomeState {
  final List<Map<String, dynamic>>? listData;
  final int offset;
  final int limit;
  final int total;
   bool loading;
  final bool lastItem;

  HomeListDataOfferWallState({
    this.listData,
    this.offset = 0,
    this.limit = 10,
    this.total = 0,
    this.loading = false,
    this.lastItem = false,
  });

  HomeListDataOfferWallState copyWith({
    List<Map<String, dynamic>>? listData,
    int? offset,
    bool? loading,
    bool? lastItem,
    int? total,
  }) {
    return HomeListDataOfferWallState(
      offset: offset ?? this.offset,
      limit: 10,
      lastItem: lastItem ?? this.lastItem,
      total: total ?? this.total,
      loading: loading ?? this.loading,
      listData: listData ?? this.listData,
    );
  }
}


// enum ListAdverStatus { initial, loading, success, failure }

// enum LoadmoreListAdverStatus { initial, loading, success, failure }

// enum GetPointStatus { initial, loading, success, failure }

// @immutable
// class HomeState {
//   const HomeState(
//       {this.listAdverStatus = ListAdverStatus.initial,
//       this.loadmoreListAdverStatus = LoadmoreListAdverStatus.initial,
//       this.getPointStatus = GetPointStatus.initial,
//       this.account,
//       this.bannerList,
//       this.totalPoint,
//       this.listDataOfferWall});

//   final ListAdverStatus listAdverStatus;
//   final LoadmoreListAdverStatus loadmoreListAdverStatus;
//   final List<Map<String, dynamic>>? listDataOfferWall;
//   final dynamic account;
//   final dynamic bannerList;
//   final dynamic totalPoint;
//   final GetPointStatus getPointStatus;

//   HomeState copyWith(
//       {ListAdverStatus? listAdverStatus,
//       LoadmoreListAdverStatus? loadmoreListAdverStatus,
//       List<Map<String, dynamic>>? listDataOfferWall,
//       GetPointStatus? getPointStatus,
//       dynamic account,
//       dynamic bannerList,
//       dynamic totalPoint}) {
//     return HomeState(
//         getPointStatus: getPointStatus ?? this.getPointStatus,
//         listAdverStatus: listAdverStatus ?? this.listAdverStatus,
//         loadmoreListAdverStatus: loadmoreListAdverStatus ?? this.loadmoreListAdverStatus,
//         listDataOfferWall: listDataOfferWall ?? this.listDataOfferWall,
//         account: account ?? this.account,
//         totalPoint: totalPoint ?? this.totalPoint,
//         bannerList: bannerList ?? this.bannerList);
//   }
// }
