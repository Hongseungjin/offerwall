part of 'register_link_bloc.dart';

abstract class RegisterLinkEvent extends Equatable {}

class MissionOfferWallRegisterLink extends RegisterLinkEvent {
  MissionOfferWallRegisterLink({this.xId, this.files, this.lang, this.html});

  final File? files;
  final dynamic xId;
  final String? lang;
  final String? html;
  @override
  List<Object?> get props => [xId, files, lang, html];
}
