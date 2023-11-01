part of 'keep_adverbox_bloc.dart';

abstract class KeepAdverboxEvent extends Equatable {}

class KeepAdverbox extends KeepAdverboxEvent {
  KeepAdverbox({this.limit, this.offset});

  final dynamic limit;
  final dynamic offset;
  @override
  List<Object?> get props => [limit, offset];
}

class LoadMoreKeepAdverbox extends KeepAdverboxEvent {
  LoadMoreKeepAdverbox({this.limit, this.offset});

  final dynamic limit;
  final dynamic offset;
  @override
  List<Object?> get props => [limit, offset];
}

class DeleteKeep extends KeepAdverboxEvent {
  DeleteKeep({required this.idx});

  final int idx;

  @override
  List<Object?> get props => [idx];
}

class SaveKeep extends KeepAdverboxEvent {
  SaveKeep({
    required this.id,
    required this.adType,
  });

  final int id;
  final String adType;

  @override
  List<Object?> get props => [id, adType];
}

class EarnPoint extends KeepAdverboxEvent {
  EarnPoint( {required this.adType, this.advertiseIdx, this.pointType});

  final dynamic advertiseIdx;
  final dynamic pointType;
  final String adType;

  @override
  // TODO: implement props
  List<Object?> get props => [advertiseIdx, pointType, adType];
}

class GetAdvertiseSponsor extends KeepAdverboxEvent {
  GetAdvertiseSponsor();

  @override
  List<Object?> get props => [];
}

class SaveScrap extends KeepAdverboxEvent {
  SaveScrap({required this.advertiseIdx, required this.adType});
  final int advertiseIdx;
  final String adType;
  @override
  List<Object?> get props => [advertiseIdx, adType];
}

class DeleteScrap extends KeepAdverboxEvent {
  DeleteScrap({required this.idx});

  final int idx;

  @override
  List<Object?> get props => [idx];
}
