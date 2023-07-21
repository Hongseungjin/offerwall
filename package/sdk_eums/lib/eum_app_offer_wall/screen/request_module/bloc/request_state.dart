part of 'request_bloc.dart';

enum TypeInquireStatus { initial, loading, success, failure }

enum InquireStatus { initial, loading, success, failure }

enum InquireListStatus { initial, loading, success, failure }

enum InquireLoadMoreListStatus { initial, loading, success, failure }

@immutable
class RequestState extends Equatable {
  const RequestState(
      {this.inquireStatus = InquireStatus.initial,
      this.typeInquireStatus = TypeInquireStatus.initial,
      this.inquireListStatus = InquireListStatus.initial,
      this.dataInquire,
      this.dataListInquire,
      this.inquireLoadMoreListStatus = InquireLoadMoreListStatus.initial});

  final TypeInquireStatus typeInquireStatus;
  final InquireListStatus inquireListStatus;
  final InquireStatus inquireStatus;
  final dynamic dataInquire;
  final dynamic dataListInquire;
  final InquireLoadMoreListStatus inquireLoadMoreListStatus;

  RequestState copyWith(
      {InquireStatus? inquireStatus,
      TypeInquireStatus? typeInquireStatus,
      InquireListStatus? inquireListStatus,
      InquireLoadMoreListStatus? inquireLoadMoreListStatus,
      dynamic dataListInquire,
      dynamic dataInquire}) {
    return RequestState(
        typeInquireStatus: typeInquireStatus ?? this.typeInquireStatus,
        inquireStatus: inquireStatus ?? this.inquireStatus,
        dataInquire: dataInquire ?? this.dataInquire,
        inquireListStatus: inquireListStatus ?? this.inquireListStatus,
        dataListInquire: dataListInquire ?? this.dataListInquire,
        inquireLoadMoreListStatus:
            inquireLoadMoreListStatus ?? this.inquireLoadMoreListStatus);
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
        typeInquireStatus,
        inquireStatus,
        dataInquire,
        dataListInquire,
        inquireListStatus,
        inquireLoadMoreListStatus
      ];
}
