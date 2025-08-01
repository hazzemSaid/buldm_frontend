part of 'Search_Cubit.dart';

@freezed
abstract class SearchState extends Equatable {}

class SearchInitial extends SearchState {
  @override
  List<Object> get props => [];
}

class SearchLoading extends SearchState {
  @override
  List<Object> get props => [];
}

class SearchLoaded extends SearchState {
  final List<ViewerUser> users;

  SearchLoaded({required this.users});

  @override
  List<Object> get props => [users];
}

class SearchError extends SearchState {
  final String message;

  SearchError({required this.message});

  @override
  List<Object> get props => [message];
}
