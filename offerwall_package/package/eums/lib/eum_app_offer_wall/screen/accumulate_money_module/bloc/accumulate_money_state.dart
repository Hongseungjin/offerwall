part of 'accumulate_money_bloc.dart';

enum AccumulateMoneyStatus { initial, loading, success, failure }

enum ListOfferWallStatus { initial, loading, success, failure }

enum NextPageStatus { initial, loading, success, failure }

enum SaveKeepStatus { initial, loading, success, failure }

@immutable
class AccumulateMoneyState extends Equatable {
  const AccumulateMoneyState(
      {this.accumulateMoneyStatus = AccumulateMoneyStatus.initial,
      this.listOfferWallStatus = ListOfferWallStatus.initial,
      this.dataListOfferWall,
      this.account,
      this.dataAccumulateMoney,
      this.nextPageStatus = NextPageStatus.initial,
      this.saveKeepStatus = SaveKeepStatus.initial,
      this.checkOnOffAdver = false});
  final AccumulateMoneyStatus accumulateMoneyStatus;
  final dynamic dataAccumulateMoney;
  final dynamic dataListOfferWall;
  final ListOfferWallStatus listOfferWallStatus;
  final bool checkOnOffAdver;
  final NextPageStatus nextPageStatus;
  final SaveKeepStatus saveKeepStatus;
  final dynamic account;

  AccumulateMoneyState copyWith(
      {AccumulateMoneyStatus? accumulateMoneyStatus,
      ListOfferWallStatus? listOfferWallStatus,
      dynamic dataAccumulateMoney,
      dynamic dataListOfferWall,
      bool? checkOnOffAdver,
      NextPageStatus? nextPageStatus,
      dynamic account,
      SaveKeepStatus? saveKeepStatus}) {
    return AccumulateMoneyState(
        checkOnOffAdver: checkOnOffAdver ?? this.checkOnOffAdver,
        dataListOfferWall: dataListOfferWall ?? this.dataListOfferWall,
        listOfferWallStatus: listOfferWallStatus ?? this.listOfferWallStatus,
        accumulateMoneyStatus:
            accumulateMoneyStatus ?? this.accumulateMoneyStatus,
        nextPageStatus: nextPageStatus ?? this.nextPageStatus,
        dataAccumulateMoney: dataAccumulateMoney ?? this.dataAccumulateMoney,
        account: account ?? this.account,
        saveKeepStatus: saveKeepStatus ?? this.saveKeepStatus);
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
        accumulateMoneyStatus,
        dataAccumulateMoney,
        listOfferWallStatus,
        dataListOfferWall,
        checkOnOffAdver,
        nextPageStatus,
        saveKeepStatus,
        account
      ];
}
