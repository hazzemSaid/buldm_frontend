import 'package:buldm/features/home/data/models/commentsmodel.dart';
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
  individualPostLoadLoading,
  individualPostLoadSuccess,
  individualPostLoadError,
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
  final PostModel? individualPost;
  final Map<String, PostModel> posts;
  final bool isLoadingMore;

  final String? message;
  final Map<String, CommentModel> comments;
  final Map<String, Set<String>> likes;

  const PostState({
    this.individualPost,
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
    PostModel? individualPost,
    PostStatus? status,
    Map<String, PostModel>? posts,
    bool? hasMoreposts,
    bool? hasMorecomments,
    bool? isLoadingMore,
    String? message,
    Map<String, CommentModel>? comments,
    Map<String, Set<String>>? likes,
  }) {
    return PostState(
      individualPost: individualPost ?? this.individualPost,
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
