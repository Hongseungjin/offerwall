part of 'scrap_adverbox_bloc.dart';

enum ScrapAdverboxStatus { initial, loading, success, failure }

enum LoadMoreScrapAdverboxStatus { initial, loading, success, failure }

enum DeleteScrapAdverboxStatus { initial, loading, success, failure }

@immutable
class ScrapAdverboxState extends Equatable {
  const ScrapAdverboxState(
      {this.deleteScrapAdverboxStatus = DeleteScrapAdverboxStatus.initial,
      this.status = ScrapAdverboxStatus.initial,
      this.statusLoadMore = LoadMoreScrapAdverboxStatus.initial,
      this.dataScrapAdverbox});

  final ScrapAdverboxStatus status;
  final LoadMoreScrapAdverboxStatus statusLoadMore;
  final dynamic dataScrapAdverbox;
  final DeleteScrapAdverboxStatus deleteScrapAdverboxStatus;

  ScrapAdverboxState copyWith(
      {DeleteScrapAdverboxStatus? deleteScrapAdverboxStatus,
      ScrapAdverboxStatus? status,
      LoadMoreScrapAdverboxStatus? statusLoadMore,
      dynamic dataScrapAdverbox}) {
    return ScrapAdverboxState(
        deleteScrapAdverboxStatus:
            deleteScrapAdverboxStatus ?? this.deleteScrapAdverboxStatus,
        status: status ?? this.status,
        statusLoadMore: statusLoadMore ?? this.statusLoadMore,
        dataScrapAdverbox: dataScrapAdverbox ?? this.dataScrapAdverbox);
  }

  @override
  // TODO: implement props
  List<Object?> get props =>
      [status, dataScrapAdverbox, deleteScrapAdverboxStatus, statusLoadMore];
}
