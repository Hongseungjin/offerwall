part of 'scrap_adverbox_bloc.dart';

abstract class ScrapAdverboxEvent extends Equatable {}

class ScrapAdverbox extends ScrapAdverboxEvent {
  ScrapAdverbox({this.limit, this.offset, this.sort});

  final dynamic limit;
  final dynamic offset;
  final dynamic sort;

  @override
  List<Object?> get props => [limit, offset, sort];
}

class LoadMoreScrapAdverbox extends ScrapAdverboxEvent {
  LoadMoreScrapAdverbox({this.limit, this.offset, this.sort});

  final dynamic limit;
  final dynamic offset;
  final dynamic sort;

  @override
  List<Object?> get props => [limit, offset, sort];
}

class DeleteScrapdverbox extends ScrapAdverboxEvent {
  DeleteScrapdverbox({required this.adsIdx, required this.adType});
  final int adsIdx;
  final String adType;
  @override
  List<Object?> get props => [adsIdx, adType];
}

class LikeScrap extends ScrapAdverboxEvent {
  LikeScrap({this.id});
  final dynamic id;
  @override
  List<Object?> get props => [id];
}

class UnLikeScrap extends ScrapAdverboxEvent {
  UnLikeScrap({this.id});
  final dynamic id;
  @override
  List<Object?> get props => [id];
}
