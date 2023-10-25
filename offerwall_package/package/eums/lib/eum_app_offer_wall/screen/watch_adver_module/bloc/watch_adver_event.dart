part of 'watch_adver_bloc.dart';

abstract class WatchAdverEvent extends Equatable {}

class WatchAdver extends WatchAdverEvent {
  WatchAdver({this.id});

  final dynamic id;
  @override
  // TODO: implement props
  List<Object?> get props => [id];
}

class EarnPoin extends WatchAdverEvent {
  EarnPoin({this.advertise_idx, this.pointType});

  final dynamic advertise_idx;
  final dynamic pointType;
  @override
  // TODO: implement props
  List<Object?> get props => [advertise_idx, pointType];
}

class SaveAdver extends WatchAdverEvent {
  SaveAdver({required this.advertiseIdx, required this.adType});
  final int advertiseIdx;
  final String adType;
  @override
  List<Object?> get props => [advertiseIdx, adType];
}

class DeleteScrap extends WatchAdverEvent {
  DeleteScrap({required this.idx});
  final int idx;
  @override
  List<Object?> get props => [idx];
}
