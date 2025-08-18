part of 'post_bloc.dart';

class PostState extends Equatable {
  const PostState();

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => true;
}

class ReplySuccess extends PostState {
  final String postId;
  final String parentCommentId;

  const ReplySuccess({required this.postId, required this.parentCommentId});

  @override
  List<Object?> get props => [postId, parentCommentId];
}

class CommentsForPostLoaded extends PostState {
  final String postId;
  final List<CommentModel> comments;

  const CommentsForPostLoaded({required this.postId, required this.comments});

  @override
  List<Object?> get props => [postId, comments];
}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostLoaded extends PostState {
  final List<PostModel> posts;
  final bool hasMore;
  final bool isLoadingMore;

  const PostLoaded({
    required this.posts,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  PostLoaded copyWith({
    List<PostModel>? posts,
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

class PostCreatedState extends PostState {
  final String userId;

  const PostCreatedState({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class CommentLoading extends PostState {}

class CommentLoaded extends PostState {}

class CommentError extends PostState {
  final String message;

  const CommentError({required this.message});

  @override
  List<Object?> get props => [message];
}

class LikeLoading extends PostState {}

class LikeLoaded extends PostState {
  final List<LikeModel> likes;

  const LikeLoaded({required this.likes});

  @override
  List<Object?> get props => [likes];
}

class LikeError extends PostState {
  final String message;

  const LikeError({required this.message});

  @override
  List<Object?> get props => [message];
}
