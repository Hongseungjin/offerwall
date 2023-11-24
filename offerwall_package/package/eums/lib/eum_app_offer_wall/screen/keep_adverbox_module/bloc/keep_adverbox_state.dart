part of 'keep_adverbox_bloc.dart';

enum KeepAdverboxStatus { initial, loading, success, failure }

enum LoadMoreKeepAdverboxStatus { initial, loading, success, failure }

enum DeleteCrapStatus { initial, loading, success, failure }
enum DeleteKeepStatus { initial, loading, success, failure }

enum SaveKeepStatus { initial, loading, success, failure }

enum SaveScrapStatus { initial, loading, success, failure }

enum AdverKeepStatus { initial, loading, success, failure }

@immutable
class KeepAdverboxState extends Equatable {
  const KeepAdverboxState(
      {this.deleteKeepStatus = DeleteKeepStatus.initial,
      this.deleteCrapStatus = DeleteCrapStatus.initial,
      this.saveKeepStatus = SaveKeepStatus.initial,
      this.saveScrapStatus = SaveScrapStatus.initial,
      this.status = KeepAdverboxStatus.initial,
      this.dataKeepAdverbox,
      this.dataDetailKeepAdverbox,
      this.dataAdvertiseSponsor,
      this.statusLoadmore = LoadMoreKeepAdverboxStatus.initial,
      this.adverKeepStatus = AdverKeepStatus.initial});

  final KeepAdverboxStatus status;
  final LoadMoreKeepAdverboxStatus statusLoadmore;
  final DeleteKeepStatus deleteKeepStatus;
  final DeleteCrapStatus deleteCrapStatus;
  final SaveKeepStatus saveKeepStatus;
  final SaveScrapStatus saveScrapStatus;
  final dynamic dataKeepAdverbox;
  final dynamic dataDetailKeepAdverbox;
  final AdverKeepStatus adverKeepStatus;
  final dynamic dataAdvertiseSponsor;

  KeepAdverboxState copyWith(
      {DeleteKeepStatus? deleteKeepStatus,
      DeleteCrapStatus? deleteCrapStatus,
      KeepAdverboxStatus? status,
      dynamic dataKeepAdverbox,
      dynamic dataAdvertiseSponsor,
      dynamic dataDetailKeepAdverbox,
      AdverKeepStatus? adverKeepStatus,
      SaveScrapStatus? saveScrapStatus,
      SaveKeepStatus? saveKeepStatus,
      LoadMoreKeepAdverboxStatus? statusLoadmore}) {
    return KeepAdverboxState(
        dataDetailKeepAdverbox:
            dataDetailKeepAdverbox ?? this.dataDetailKeepAdverbox,
        deleteKeepStatus: deleteKeepStatus ?? this.deleteKeepStatus,
        deleteCrapStatus: deleteCrapStatus ?? this.deleteCrapStatus,
        status: status ?? this.status,
        dataKeepAdverbox: dataKeepAdverbox ?? this.dataKeepAdverbox,
        adverKeepStatus: adverKeepStatus ?? this.adverKeepStatus,
        statusLoadmore: statusLoadmore ?? this.statusLoadmore,
        saveScrapStatus: saveScrapStatus ?? this.saveScrapStatus,
        saveKeepStatus: saveKeepStatus ?? this.saveKeepStatus,
        dataAdvertiseSponsor:
            dataAdvertiseSponsor ?? this.dataAdvertiseSponsor);
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
        status,
        dataKeepAdverbox,
        dataDetailKeepAdverbox,
        deleteKeepStatus,
        deleteCrapStatus,
        adverKeepStatus,
        statusLoadmore,
        dataAdvertiseSponsor,
        saveScrapStatus,
        saveKeepStatus
      ];
}
