part of 'report_bloc.dart';

abstract class ReportEvent extends Equatable {}

class ReportAdver extends ReportEvent {
  ReportAdver({this.idx, this.reason, this.type});

  final dynamic idx;
  final String? reason;
  final dynamic type;

  @override
  List<Object?> get props => [idx, reason, type];
}

class DeleteKeep extends ReportEvent {
  DeleteKeep({this.advertise_idx});

  final dynamic advertise_idx;

  @override
  List<Object?> get props => [advertise_idx];
}
