part of 'earn_cash_bloc.dart';

abstract class EarnCashEvent extends Equatable {}

class EarnCashList extends EarnCashEvent {
  EarnCashList({this.limit, this.offset});

  final dynamic limit;
  final dynamic offset;
  @override
  List<Object?> get props => [limit, offset];
}

class LoadMoreEarnCashList extends EarnCashEvent {
  LoadMoreEarnCashList({this.limit, this.offset});

  final dynamic limit;
  final dynamic offset;
  @override
  List<Object?> get props => [limit, offset];
}

class PointOfferWallList extends EarnCashEvent {
  PointOfferWallList({this.limit, this.offset});

  final dynamic limit;
  final dynamic offset;
  @override
  List<Object?> get props => [limit, offset];
}

class LoadMorePointOfferWallList extends EarnCashEvent {
  LoadMorePointOfferWallList({this.limit, this.offset});

  final dynamic limit;
  final dynamic offset;
  @override
  List<Object?> get props => [limit, offset];
}
