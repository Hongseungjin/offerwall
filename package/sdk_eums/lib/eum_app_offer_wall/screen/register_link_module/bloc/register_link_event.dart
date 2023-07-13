part of 'register_link_bloc.dart';

abstract class RegisterLinkEvent extends Equatable {}

class MissionOfferWallRegisterLink extends RegisterLinkEvent {
  MissionOfferWallRegisterLink({this.xId, this.files});

  final List<File>? files;
  final dynamic xId;
  @override
  List<Object?> get props => [xId, files];
}
