part of 'join_offerwall_bloc.dart';

abstract class JoinOffWallEvent extends Equatable {}

class JoinOffWall extends JoinOffWallEvent {
  JoinOffWall({
    this.lang,
    this.xId,
  });

  final String? lang;
  final dynamic xId;
  @override
  List<Object?> get props => [xId, lang];
}
