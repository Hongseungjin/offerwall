part of 'notifi_bloc.dart';

abstract class NotifiEvent extends Equatable {}

class ListNotifi extends NotifiEvent {
  ListNotifi({this.limit, this.offset});

  final dynamic limit;
  final dynamic offset;
  @override
  List<Object?> get props => [limit, offset];
}

class LoadMoreListNotifi extends NotifiEvent {
  LoadMoreListNotifi({this.limit, this.offset});

  final dynamic limit;
  final dynamic offset;
  @override
  List<Object?> get props => [limit, offset];
}
