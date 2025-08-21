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
  final Map<String, PostModel> posts;
  final bool hasMore;
  final bool isLoadingMore;
  final String? category;
  final String? status;
  final String? userId;
  final String? searchQuery;
  final int pageSize;
  final int currentPage;

  const PostLoaded({
    required this.posts,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.category,
    this.status,
    this.userId,
    this.searchQuery,
    this.pageSize = 5,
    this.currentPage = 1,
  });

  PostLoaded copyWith({
    Map<String, PostModel>? posts,
    bool? hasMore,
    bool? isLoadingMore,
    String? category,
    String? status,
    String? userId,
    String? searchQuery,
    int? pageSize,
    int? currentPage,
  }) {
    return PostLoaded(
      posts: posts ?? this.posts,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      category: category ?? this.category,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      searchQuery: searchQuery ?? this.searchQuery,
      pageSize: pageSize ?? this.pageSize,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
        posts,
        hasMore,
        isLoadingMore,
        category,
        status,
        userId,
        searchQuery,
        pageSize,
        currentPage
      ];
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

class PostUploadError extends PostState {
  final String message;

  const PostUploadError({required this.message});

  @override
  List<Object?> get props => [message];
}

class PostUpdatedSuccess extends PostState {
  const PostUpdatedSuccess();

  @override
  List<Object?> get props => [];
}

class PostUpdatedError extends PostState {
  final String message;

  const PostUpdatedError({required this.message});

  @override
  List<Object?> get props => [message];
}

class PostUpdatedLoading extends PostState {
  const PostUpdatedLoading();

  @override
  List<Object?> get props => [];
}
