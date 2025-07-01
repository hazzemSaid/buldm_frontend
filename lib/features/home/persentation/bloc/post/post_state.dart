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
  final bool hasMore;
  final bool isLoadingMore;

  const PostLoaded({
    required this.posts,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  PostLoaded copyWith({
    List<PostEntity>? posts,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return PostLoaded(
      posts: posts ?? this.posts,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [posts, hasMore, isLoadingMore];
}

class PostError extends PostState {
  final String message;

  const PostError({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  bool? get stringify => true;
}
