// part of 'watch_adver_bloc.dart';

// enum EarnMoneyStatus { initial, loading, success, failure }

// enum SaveKeepAdverboxStatus { initial, loading, success, failure }

// enum DeleteScrapStatus { initial, loading, success, failure }

// @immutable
// class WatchAdverState extends Equatable {
//   WatchAdverState(
//       {this.dataWatch,
//       this.saveKeepAdverboxStatus = SaveKeepAdverboxStatus.initial,
//       this.deleteScrapStatus = DeleteScrapStatus.initial,
//       this.earnMoneyStatus = EarnMoneyStatus.initial});

//   dynamic dataWatch;
//   final EarnMoneyStatus earnMoneyStatus;
//   final SaveKeepAdverboxStatus saveKeepAdverboxStatus;
//   final DeleteScrapStatus deleteScrapStatus;

//   WatchAdverState copyWith(
//       {SaveKeepAdverboxStatus? saveKeepAdverboxStatus,
//       dynamic dataWatch,
//       EarnMoneyStatus? earnMoneyStatus,
//       DeleteScrapStatus? deleteScrapStatus}) {
//     return WatchAdverState(
//         dataWatch: dataWatch ?? this.dataWatch,
//         earnMoneyStatus: earnMoneyStatus ?? this.earnMoneyStatus,
//         saveKeepAdverboxStatus:
//             saveKeepAdverboxStatus ?? this.saveKeepAdverboxStatus,
//         deleteScrapStatus: deleteScrapStatus ?? this.deleteScrapStatus);
//   }

//   @override
//   // TODO: implement props
//   List<Object?> get props =>
//       [dataWatch, saveKeepAdverboxStatus, earnMoneyStatus, deleteScrapStatus];
// }
