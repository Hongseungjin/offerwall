part of 'join_offerwall_bloc.dart';

enum JoinOfferWallStatus { inital, loading, success, failure }

@immutable
class JoinOffWallState extends Equatable {
  const JoinOffWallState({
    this.joinOfferWallStatus = JoinOfferWallStatus.inital,
  });
  final JoinOfferWallStatus joinOfferWallStatus;

  JoinOffWallState copyWith({
    JoinOfferWallStatus? joinOfferWallStatus,
  }) {
    return JoinOffWallState(
      joinOfferWallStatus: joinOfferWallStatus ?? this.joinOfferWallStatus,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [joinOfferWallStatus];
}
