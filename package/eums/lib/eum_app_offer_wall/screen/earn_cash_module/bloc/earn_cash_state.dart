part of 'earn_cash_bloc.dart';

enum EarnCashStatus { initial, loading, success, failure }

enum LoadMoreEarnCashStatus { initial, loading, success, failure }

@immutable
class EarnCashState extends Equatable {
  const EarnCashState(
      {this.earnCashStatus = EarnCashStatus.initial,
      this.loadMoreEarnCashStatus = LoadMoreEarnCashStatus.initial,
      this.dataEarnCash,
      this.dataPointOffer});
  final EarnCashStatus earnCashStatus;
  final LoadMoreEarnCashStatus loadMoreEarnCashStatus;
  final dynamic dataEarnCash;
  final dynamic dataPointOffer;

  EarnCashState copyWith(
      {EarnCashStatus? earnCashStatus,
      LoadMoreEarnCashStatus? loadMoreEarnCashStatus,
      dynamic dataEarnCash,
      dynamic dataPointOffer}) {
    return EarnCashState(
        earnCashStatus: earnCashStatus ?? this.earnCashStatus,
        dataEarnCash: dataEarnCash ?? this.dataEarnCash,
        dataPointOffer: dataPointOffer ?? this.dataPointOffer);
  }

  @override
  // TODO: implement props
  List<Object?> get props =>
      [earnCashStatus, dataEarnCash, dataPointOffer, loadMoreEarnCashStatus];
}
