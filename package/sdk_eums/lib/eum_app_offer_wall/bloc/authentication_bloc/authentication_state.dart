part of 'authentication_bloc.dart';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

enum LogoutStatus { initial, loading, finish }

@immutable
class AuthenticationState extends Equatable {
  const AuthenticationState({
    this.status = AuthenticationStatus.unknown,
    this.logoutStatus = LogoutStatus.initial,
  });

  final AuthenticationStatus status;
  final LogoutStatus logoutStatus;

  AuthenticationState copyWith({
    AuthenticationStatus? status,
    LogoutStatus? logoutStatus,
  }) {
    return AuthenticationState(
      status: status ?? this.status,
      logoutStatus: logoutStatus ?? this.logoutStatus,
    );
  }

  @override
  List<Object> get props => [
        status,
        logoutStatus,
      ];
}
