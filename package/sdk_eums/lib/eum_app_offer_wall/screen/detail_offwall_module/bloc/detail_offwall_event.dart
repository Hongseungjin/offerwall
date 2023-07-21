part of 'detail_offwall_bloc.dart';

abstract class DetailOffWallEvent extends Equatable {}

class DetailOffWal extends DetailOffWallEvent {
  DetailOffWal({this.xId});

  final dynamic xId;
  @override
  List<Object?> get props => [xId];
}

class MissionCompleteOfferWall extends DetailOffWallEvent {
  MissionCompleteOfferWall({this.xId});

  final dynamic xId;
  @override
  List<Object?> get props => [xId];
}

class VisitOffWall extends DetailOffWallEvent {
  VisitOffWall({
    this.lang,
    this.xId,
  });

  final String? lang;
  final dynamic xId;
  @override
  List<Object?> get props => [xId, lang];
}
