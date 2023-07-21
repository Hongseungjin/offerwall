part of 'purchase_offerwall_internal_bloc.dart';

abstract class PuschaseOffWallEvent extends Equatable {}

class PuschaseOffWall extends PuschaseOffWallEvent {
  PuschaseOffWall({
    this.lang,
    this.xId,
  });

  final String? lang;
  final dynamic xId;
  @override
  List<Object?> get props => [xId, lang];
}
