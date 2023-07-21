part of 'detail_offwall_bloc.dart';

enum DetailOffWallStatus { inital, loading, success, failure }

enum MissionCompleteOfferWallStatus { inital, loading, success, failure }

enum VisitOfferWallInternalStatus { inital, loading, success, failure }

@immutable
class DetailOffWallState extends Equatable {
  const DetailOffWallState(
      {this.detailOffWallStatus = DetailOffWallStatus.inital,
      this.dataDetailOffWall,
      this.visitOfferWallInternalStatus = VisitOfferWallInternalStatus.inital,
      this.missionCompleteOfferWallStatus =
          MissionCompleteOfferWallStatus.inital});
  final DetailOffWallStatus detailOffWallStatus;
  final dynamic dataDetailOffWall;
  final MissionCompleteOfferWallStatus missionCompleteOfferWallStatus;
  final VisitOfferWallInternalStatus visitOfferWallInternalStatus;

  DetailOffWallState copyWith(
      {DetailOffWallStatus? detailOffWallStatus,
      dynamic dataDetailOffWall,
      VisitOfferWallInternalStatus? visitOfferWallInternalStatus,
      MissionCompleteOfferWallStatus? missionCompleteOfferWallStatus}) {
    return DetailOffWallState(
        dataDetailOffWall: dataDetailOffWall ?? this.dataDetailOffWall,
        detailOffWallStatus: detailOffWallStatus ?? this.detailOffWallStatus,
        visitOfferWallInternalStatus:
            visitOfferWallInternalStatus ?? this.visitOfferWallInternalStatus,
        missionCompleteOfferWallStatus: missionCompleteOfferWallStatus ??
            this.missionCompleteOfferWallStatus);
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
        dataDetailOffWall,
        detailOffWallStatus,
        missionCompleteOfferWallStatus,
        visitOfferWallInternalStatus
      ];
}
