part of 'asked_question_bloc.dart';

enum AskedQuestionStatus { initial, loading, success, failure }

enum LoadMoreAskedQuestionStatus { initial, loading, success, failure }

@immutable
class AskedQuestionState extends Equatable {
  const AskedQuestionState(
      {this.status = AskedQuestionStatus.initial,
      this.dataAskedQuestion,
      this.loadMoreAskedQuestionStatus = LoadMoreAskedQuestionStatus.initial});

  final AskedQuestionStatus status;
  final LoadMoreAskedQuestionStatus loadMoreAskedQuestionStatus;
  final dynamic dataAskedQuestion;

  AskedQuestionState copyWith(
      {AskedQuestionStatus? status,
      dynamic dataUsingTerm,
      LoadMoreAskedQuestionStatus? loadMoreAskedQuestionStatus}) {
    return AskedQuestionState(
        status: status ?? this.status,
        loadMoreAskedQuestionStatus:
            loadMoreAskedQuestionStatus ?? this.loadMoreAskedQuestionStatus,
        dataAskedQuestion: dataUsingTerm ?? this.dataAskedQuestion);
  }

  @override
  // TODO: implement props
  List<Object?> get props =>
      [status, dataAskedQuestion, loadMoreAskedQuestionStatus];
}
