part of 'post_bloc.dart';

class PostState extends Equatable {
  const PostState();

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => true;
}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostLoaded extends PostState {
  final List<PostEntity> posts;

  const PostLoaded({required this.posts});

  @override
  List<Object?> get props => [posts];

  @override
  bool? get stringify => true;
}

class PostError extends PostState {
  final String message;

  const PostError({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  bool? get stringify => true;
}
