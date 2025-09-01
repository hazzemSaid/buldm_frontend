import 'package:buldm/features/home/data/models/commentsmodel.dart';
import 'package:buldm/features/home/data/models/likemodel.dart';
import 'package:buldm/features/home/data/models/post_model.dart';
import 'package:equatable/equatable.dart';

enum PostStatus {
  initial,
  postLoadLoading,
  postLoadSuccess,
  postLoadError,
  postCreateLoading,
  postCreateSuccess,
  postCreateError,
  postDeleteLoading,
  postDeleteError,
  postDeleteSuccess,
  postUpdateLoading,
  postUpdateSuccess,
  postUpdateError,
  commentCreateLoading,
  commentCreateSuccess,
  commentCreateError,
  commentLoadLoading,
  commentLoadSuccess,
  commentLoadError,
  likeLoadLoading,
  likeLoadSuccess,
  likeLoadError,
  likeToggleLoading,
  likeToggleSuccess,
  likeToggleError,
}

class PostState extends Equatable {
  final PostStatus status;
  final bool hasMoreposts;
  final bool hasMorecomments;

  final Map<String, PostModel> posts;
  final bool isLoadingMore;

  final String? message;
  final Map<String, CommentModel> comments;
  final Map<String, LikeModel> likes;

  const PostState({
    this.status = PostStatus.initial,
    this.posts = const {},
    this.hasMoreposts = true,
    this.hasMorecomments = true,
    this.isLoadingMore = false,
    this.message,
    this.comments = const {},
    this.likes = const {},
  });

  PostState copyWith({
    PostStatus? status,
    Map<String, PostModel>? posts,
    bool? hasMoreposts,
    bool? hasMorecomments,
    bool? isLoadingMore,
    String? message,
    Map<String, CommentModel>? comments,
    Map<String, LikeModel>? likes,
  }) {
    return PostState(
      hasMoreposts: hasMoreposts ?? this.hasMoreposts,
      hasMorecomments: hasMorecomments ?? this.hasMorecomments,
      status: status ?? this.status,
      posts: posts ?? this.posts,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      message: message ?? this.message,
      comments: comments ?? this.comments,
      likes: likes ?? this.likes,
    );
  }

  @override
  List<Object?> get props => [
        status,
        posts,
        isLoadingMore,
        hasMoreposts,
        hasMorecomments,
        message,
        comments,
        likes,
      ];
}
