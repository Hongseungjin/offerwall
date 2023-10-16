part of 'register_link_bloc.dart';

enum RegisterLinkStatus { initial, loading, success, failure }

@immutable
class RegisterLinkState extends Equatable {
  RegisterLinkState({this.registerLinkStatus = RegisterLinkStatus.initial});

  final RegisterLinkStatus registerLinkStatus;

  RegisterLinkState copyWith({RegisterLinkStatus? registerLinkStatus}) {
    return RegisterLinkState(
        registerLinkStatus: registerLinkStatus ?? this.registerLinkStatus);
  }

  @override
  // TODO: implement props
  List<Object?> get props => [registerLinkStatus];
}
