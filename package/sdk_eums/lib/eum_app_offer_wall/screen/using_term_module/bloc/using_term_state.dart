part of 'using_term_bloc.dart';

enum UsingTermStatus { initial, loading, success, failure }

@immutable
class UsingTermState extends Equatable {
  const UsingTermState(
      {this.status = UsingTermStatus.initial, this.dataUsingTerm});

  final UsingTermStatus status;
  final dynamic dataUsingTerm;

  UsingTermState copyWith({UsingTermStatus? status, dynamic dataUsingTerm}) {
    return UsingTermState(
        status: status ?? this.status,
        dataUsingTerm: dataUsingTerm ?? this.dataUsingTerm);
  }

  @override
  // TODO: implement props
  List<Object?> get props => [status, dataUsingTerm];
}
