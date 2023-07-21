part of 'register_link_bloc.dart';

abstract class RegisterLinkEvent extends Equatable {}

class MissionOfferWallRegisterLink extends RegisterLinkEvent {
  MissionOfferWallRegisterLink({this.xId, this.files, this.lang});

  final File? files;
  final dynamic xId;
  final String? lang;
  @override
  List<Object?> get props => [xId, files, lang];
}
