part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {}

class ListOfferWall extends HomeEvent {
  ListOfferWall({this.category, this.limit, this.filter});

  final dynamic category;
  final dynamic limit;
  final dynamic filter;
  @override
  List<Object?> get props => [category, limit, filter];
}

class LoadmoreListOfferWall extends HomeEvent {
  LoadmoreListOfferWall({this.category, this.limit, this.offset, this.filter});

  final dynamic category;
  final dynamic limit;
  final dynamic offset;
  final dynamic filter;
  @override
  List<Object?> get props => [category, limit, offset, filter];
}

class InfoUser extends HomeEvent {
  InfoUser({this.account});

  final dynamic account;
  @override
  List<Object?> get props => [account];
}

class ListBanner extends HomeEvent {
  ListBanner({this.type});

  final dynamic type;
  @override
  List<Object?> get props => [type];
}
