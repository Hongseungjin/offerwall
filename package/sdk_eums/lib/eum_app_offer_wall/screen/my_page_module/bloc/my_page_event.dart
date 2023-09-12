part of 'my_page_bloc.dart';

abstract class MyPageEvent extends Equatable {}

class ListBanner extends MyPageEvent {
  ListBanner({this.type});

  final dynamic type;
  @override
  List<Object?> get props => [type];
}
