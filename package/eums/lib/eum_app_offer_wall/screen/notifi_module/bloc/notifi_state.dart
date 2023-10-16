part of 'notifi_bloc.dart';

enum ListNotifiStatus { initial, loading, success, failure }

enum LoaMoreListNotifiStatus { initial, loading, success, failure }

@immutable
class NotifiState extends Equatable {
  const NotifiState(
      {this.dataNotifi,
      this.loaMoreListNotifiStatus = LoaMoreListNotifiStatus.initial,
      this.listNotifiStatus = ListNotifiStatus.initial});

  final ListNotifiStatus listNotifiStatus;

  final LoaMoreListNotifiStatus loaMoreListNotifiStatus;
  final dynamic dataNotifi;

  NotifiState copyWith(
      {ListNotifiStatus? listNotifiStatus,
      LoaMoreListNotifiStatus? loaMoreListNotifiStatus,
      dynamic dataNotifi}) {
    return NotifiState(
        dataNotifi: dataNotifi ?? this.dataNotifi,
        loaMoreListNotifiStatus:
            loaMoreListNotifiStatus ?? this.loaMoreListNotifiStatus,
        listNotifiStatus: listNotifiStatus ?? this.listNotifiStatus);
  }

  @override
  // TODO: implement props
  List<Object?> get props =>
      [dataNotifi, loaMoreListNotifiStatus, listNotifiStatus];
}
