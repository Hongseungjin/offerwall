part of 'visit_offerwall_bloc.dart';

abstract class VisitOffWallEvent extends Equatable {}

class VisitOffWall extends VisitOffWallEvent {
  VisitOffWall({
    this.lang,
    this.xId,
  });

  final String? lang;
  final dynamic xId;
  @override
  List<Object?> get props => [xId, lang];
}