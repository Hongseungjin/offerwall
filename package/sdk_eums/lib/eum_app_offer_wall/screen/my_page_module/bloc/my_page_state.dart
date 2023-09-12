part of 'my_page_bloc.dart';

enum LoadBannerStatus { initial, loading, success, failure }

class MyPageState extends Equatable {
  const MyPageState(
      {this.loadBannerStatus = LoadBannerStatus.initial, this.listBanner});

  final LoadBannerStatus loadBannerStatus;
  final dynamic listBanner;

  MyPageState copyWith(
      {LoadBannerStatus? loadBannerStatus, dynamic listBanner}) {
    return MyPageState(
        loadBannerStatus: loadBannerStatus ?? this.loadBannerStatus,
        listBanner: listBanner ?? this.listBanner);
  }

  @override
  // TODO: implement props
  List<Object?> get props => [listBanner, loadBannerStatus];
}
