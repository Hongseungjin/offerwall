part of 'purchase_offerwall_internal_bloc.dart';

enum PuschaseOfferWallInternalStatus { inital, loading, success, failure }

@immutable
class PuschaseOffWallState extends Equatable {
  const PuschaseOffWallState({
    this.puschaseOfferWallInternalStatus =
        PuschaseOfferWallInternalStatus.inital,
  });
  final PuschaseOfferWallInternalStatus puschaseOfferWallInternalStatus;

  PuschaseOffWallState copyWith({
    PuschaseOfferWallInternalStatus? puschaseOfferWallInternalStatus,
  }) {
    return PuschaseOffWallState(
      puschaseOfferWallInternalStatus: puschaseOfferWallInternalStatus ??
          this.puschaseOfferWallInternalStatus,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props =>
      [puschaseOfferWallInternalStatus];
}
