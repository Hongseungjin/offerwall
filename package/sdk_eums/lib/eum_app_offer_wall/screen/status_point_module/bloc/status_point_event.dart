part of 'status_point_bloc.dart';

abstract class StatusPointEvent extends Equatable {}

class ListPoint extends StatusPointEvent {
  ListPoint({this.limit, this.offset, this.month, this.year});

  final dynamic limit;
  final dynamic offset;
  final dynamic month;
  final dynamic year;

  @override
  List<Object?> get props => [limit, offset, month, year];
}

class LoadMoreListPoint extends StatusPointEvent {
  LoadMoreListPoint({this.limit, this.offset, this.month, this.year});

  final dynamic limit;
  final dynamic offset;
  final dynamic month;
  final dynamic year;

  @override
  List<Object?> get props => [limit, offset, month, year];
}

class PointOutsideAdvertisinglList extends StatusPointEvent {
  PointOutsideAdvertisinglList(
      {this.limit, this.offset, this.month, this.year});

  final dynamic limit;
  final dynamic offset;
  final dynamic month;
  final dynamic year;
  @override
  List<Object?> get props => [limit, offset, month, year];
}
