part of 'profile_cubit.dart';

@freezed
abstract class ProfileState extends Equatable {}

class ProfileInitial extends ProfileState {
  @override
  List<Object> get props => [];
}

class fetchpost extends ProfileState {
  List<PostModel> posts;
  fetchpost({required this.posts});
  @override
  List<Object> get props => [posts];
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError({required this.message});

  @override
  List<Object> get props => [message];
}

class ProfileLoading extends ProfileState {
  @override
  List<Object> get props => [];
}
