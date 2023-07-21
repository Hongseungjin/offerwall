part of 'visit_offerwall_bloc.dart';

enum VisitOfferWallInternalStatus { inital, loading, success, failure }

@immutable
class VisitOfferWallInternalState extends Equatable {
  const VisitOfferWallInternalState({
    this.visitOfferWallInternalStatus = VisitOfferWallInternalStatus.inital,
  });
  final VisitOfferWallInternalStatus visitOfferWallInternalStatus;

  VisitOfferWallInternalState copyWith({
    VisitOfferWallInternalStatus? visitOfferWallInternalStatus,
  }) {
    return VisitOfferWallInternalState(
      visitOfferWallInternalStatus:
          visitOfferWallInternalStatus ?? this.visitOfferWallInternalStatus,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [visitOfferWallInternalStatus];
}
