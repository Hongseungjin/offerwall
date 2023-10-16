part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {}

class AuthenticationStatusChanged extends AuthenticationEvent {
  AuthenticationStatusChanged(this.status);

  final AuthenticationStatus status;

  @override
  List<Object?> get props => [status];
}

class AuthenticationLogout extends AuthenticationEvent {
  AuthenticationLogout(this.context);

  final BuildContext context;

  @override
  List<Object?> get props => [
        context,
      ];
}

class CheckSaveAccountLogged extends AuthenticationEvent {
  CheckSaveAccountLogged();

  @override
  List<Object?> get props => [];
}
