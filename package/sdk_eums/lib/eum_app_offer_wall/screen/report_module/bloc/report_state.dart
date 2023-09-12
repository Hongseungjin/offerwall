part of 'report_bloc.dart';

enum ReportStatus { initial, loading, success, failure }

enum DeleteKeepStatus { initial, loading, success, failure }

@immutable
class ReportState extends Equatable {
  const ReportState(
      {this.reportStatus = ReportStatus.initial,
      this.deleteKeepStatus = DeleteKeepStatus.initial});
  final ReportStatus reportStatus;
  final DeleteKeepStatus deleteKeepStatus;

  ReportState copyWith(
      {ReportStatus? reportStatus, DeleteKeepStatus? deleteKeepStatus}) {
    return ReportState(
        reportStatus: reportStatus ?? this.reportStatus,
        deleteKeepStatus: deleteKeepStatus ?? this.deleteKeepStatus);
  }

  @override
  // TODO: implement props
  List<Object?> get props => [reportStatus, deleteKeepStatus];
}
