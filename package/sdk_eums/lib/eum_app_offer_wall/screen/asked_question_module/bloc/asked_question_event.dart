part of 'asked_question_bloc.dart';

abstract class AskedQuestionEvent extends Equatable {}

class AskedQuestion extends AskedQuestionEvent {
  final dynamic limit;
  final dynamic offset;
  final dynamic search;
  AskedQuestion({this.limit, this.offset, this.search});
  @override
  List<Object?> get props => [limit, offset, search];
}

class LoadMoreAskedQuestion extends AskedQuestionEvent {
  final dynamic limit;
  final dynamic offset;
  final dynamic search;
  LoadMoreAskedQuestion({this.limit, this.offset, this.search});
  @override
  List<Object?> get props => [limit, offset, search];
}
