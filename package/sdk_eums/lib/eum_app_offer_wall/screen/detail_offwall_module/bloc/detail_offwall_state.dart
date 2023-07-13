part of 'detail_offwall_bloc.dart';

enum DetailOffWallStatus { inital, loading, success, failure }

enum MissionCompleteOfferWallStatus { inital, loading, success, failure }

@immutable
class DetailOffWallState extends Equatable {
  const DetailOffWallState(
      {this.detailOffWallStatus = DetailOffWallStatus.inital,
      this.dataDetailOffWall,
      this.missionCompleteOfferWallStatus =
          MissionCompleteOfferWallStatus.inital});
  final DetailOffWallStatus detailOffWallStatus;
  final dynamic dataDetailOffWall;
  final MissionCompleteOfferWallStatus missionCompleteOfferWallStatus;

  DetailOffWallState copyWith(
      {DetailOffWallStatus? detailOffWallStatus,
      dynamic dataDetailOffWall,
      MissionCompleteOfferWallStatus? missionCompleteOfferWallStatus}) {
    return DetailOffWallState(
        dataDetailOffWall: dataDetailOffWall ?? this.dataDetailOffWall,
        detailOffWallStatus: detailOffWallStatus ?? this.detailOffWallStatus,
        missionCompleteOfferWallStatus: missionCompleteOfferWallStatus ??
            this.missionCompleteOfferWallStatus);
  }

  @override
  // TODO: implement props
  List<Object?> get props =>
      [dataDetailOffWall, detailOffWallStatus, missionCompleteOfferWallStatus];
}
