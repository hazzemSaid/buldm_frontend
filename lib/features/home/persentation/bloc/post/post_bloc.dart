// features/home/persentation/bloc/post/post_bloc.dart
import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:buldm/features/auth/domain/usecases/get_currentuser_usercase.dart';
import 'package:buldm/features/home/data/models/commentsmodel.dart';
import 'package:buldm/features/home/data/models/post_model.dart';
import 'package:buldm/features/home/domain/usecases/changeikepostUsecase.dart';
import 'package:buldm/features/home/domain/usecases/createPostUseCase.dart';
import 'package:buldm/features/home/domain/usecases/deletpostUsecase.dart';
import 'package:buldm/features/home/domain/usecases/getIndividualPostUseCase.dart';
import 'package:buldm/features/home/domain/usecases/getPostsUseCase.dart';
import 'package:buldm/features/home/domain/usecases/getcommentedpostUsecase.dart';
import 'package:buldm/features/home/domain/usecases/getlikedpostUsecase.dart';
import 'package:buldm/features/home/domain/usecases/setcommentUsecase.dart';
import 'package:buldm/features/home/domain/usecases/setreplycommentUsecase.dart';
import 'package:buldm/features/home/domain/usecases/updatePostUseCase.dart';
import 'package:buldm/features/home/persentation/bloc/post/post_state.dart';
import 'package:buldm/features/notifications/integration/notification_integration.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

part 'post_event.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  bool isFetchingMore = false;

  final GetPostUseCase getPostUseCase;
  final GetIndividualPostUseCase getIndividualPostUseCase;
  final GetCurrentuserUsercase getCurrentuserUsercase;
  final Createpostusecase createPostUsecase;
  final GetCommentedPostUseCase getCommentedPostUseCase;
  final Updatepostusecase uploadpostusecase;
  final SetReplyCommentUseCase setReplyCommentUseCase;
  final SetCommentUseCase setCommentUseCase;
  final Getlikedpostusecase getlikedpostusecase;
  final DeletePostUseCase deletePostUseCase;
  final ChangeLikePostUseCase changeLikePostUseCase;
  PostBloc(
      {required this.getCurrentuserUsercase,
      required this.getPostUseCase,
      required this.getIndividualPostUseCase,
      required this.createPostUsecase,
      required this.getCommentedPostUseCase,
      required this.uploadpostusecase,
      required this.setReplyCommentUseCase,
      required this.setCommentUseCase,
      required this.getlikedpostusecase,
      required this.deletePostUseCase,
      required this.changeLikePostUseCase})
      : super(const PostState(
          status: PostStatus.initial,
        )) {
    on<LoadPostEvent>(_onLoadPost);
    on<AddPostEvent>(_onAddPost);
    on<uploadPostEvent>(_onUpdatePost);
    on<DeletePostEvent>(_onDeletePost);
    on<FilterPostEvent>(_onFilterPost);
    on<Getlike>(_onGetLike);
    on<setlike>(_onSetLike);
    on<getcomment>(_onGetComment);
    on<setcomment>(_onSetComment);
    on<setreplycomment>(_onSetReplyComment);
    on<LoadIndividualPostEvent>(_onLoadIndividualPost);
  }

  Future<void> _onLoadPost(LoadPostEvent event, Emitter<PostState> emit) async {
    final posts = state.posts;
    emit(PostState(status: PostStatus.postLoadLoading, posts: posts));

    try {
      final user = await getCurrentuserUsercase();

      final token = user?.token ?? '';

      final newPosts = await getPostUseCase(
        category: event.category,
        status: event.status,
        userId: event.userId,
        searchQuery: event.searchQuery,
        limit: event.limit,
        page: event.page,
        token: token,
      );

      // Already a map keyed by post id
      emit(PostState(
        status: PostStatus.postLoadSuccess,
        posts: {...posts, for (var p in newPosts.values) p.id: p},
        hasMoreposts: newPosts.length >= event.limit,
      ));
    } catch (e) {
      emit(PostState(
          status: PostStatus.postLoadError,
          message: e.toString(),
          posts: posts));
    }
  }

  Future<void> _onAddPost(AddPostEvent event, Emitter<PostState> emit) async {
    final posts = state.posts;
    emit(PostState(status: PostStatus.postCreateLoading, posts: posts));
    final user = await getCurrentuserUsercase();
    final token = user?.token ?? '';
    final postModel = event.post;
    final data = {
      'category': postModel.category,
      'status': postModel.status,
      'user_id': postModel.user_id,
      'title': postModel.title,
      'description': postModel.description,
      ...postModel.location.toJson(),
    };
    final formData = FormData.fromMap({
      ...data,
      'images': await Future.wait(event.imageFiles.map((file) async {
        return await MultipartFile.fromFile(file.path,
            filename: file.path.split('/').last);
      })),
    });
    final response = await createPostUsecase(data: formData, token: token);
    response.fold(
      (l) => emit(
          PostState(status: PostStatus.postCreateError, message: l.message)),
      (r) {
        emit(PostState(status: PostStatus.postCreateSuccess, posts: posts));
        add(LoadPostEvent(
          category: null,
          status: null,
          userId: null,
          searchQuery: null,
          limit: 5,
          page: 1,
        ));
      },
    );

    // Optionally, you can reload posts after adding a new one
  }

  Future<void> _onUpdatePost(
      uploadPostEvent event, Emitter<PostState> emit) async {
    // Clone to a mutable map before modifications
    final posts = Map<String, PostModel>.from(state.posts);
    final user = await getCurrentuserUsercase();
    final token = user?.token ?? '';
    final uploadpostmodel = event.post;
    final data = {
      'category': uploadpostmodel.category,
      'status': uploadpostmodel.status,
      'user_id': uploadpostmodel.user_id,
      'title': uploadpostmodel.title,
      'description': uploadpostmodel.description,
      ...uploadpostmodel.location.toJson(),
    };
    //can not change the image after create posts
    final response = await uploadpostusecase(token, event.post.id, data);
    response.fold((l) {
      emit(PostState(status: PostStatus.postCreateError, message: l.message));
    }, (r) {
      posts[r.id] = r;
      emit(PostState(status: PostStatus.postCreateSuccess, posts: posts));
    });
  }

  Future<void> _onDeletePost(
      DeletePostEvent event, Emitter<PostState> emit) async {
    // Clone to a mutable map before modifications
    final posts = Map<String, PostModel>.from(state.posts);
    emit(PostState(
      status: PostStatus.postDeleteLoading,
      posts: posts,
    ));
    final user = await getCurrentuserUsercase();
    final token = user?.token;
    final response = await deletePostUseCase(token!, event.post.id);
    response.fold((l) {
      emit(PostState(status: PostStatus.postDeleteError, message: l.message));
    }, (r) {
      posts.remove(event.post.id);
      emit(PostState(status: PostStatus.postDeleteSuccess, posts: posts));
    });
  }

  Future<void> _onFilterPost(
      FilterPostEvent event, Emitter<PostState> emit) async {
    // Logic to filter posts by category
  }

  Future<void> _onGetLike(Getlike event, Emitter<PostState> emit) async {
    final post = state.posts[event.postId];
    if (post == null) {
      emit(PostState(
          posts: state.posts,
          likes: state.likes,
          comments: state.comments,
          status: PostStatus.likeLoadError,
          message: 'Post not found'));
      return;
    }

    emit(PostState(status: PostStatus.likeLoadLoading, posts: state.posts));
    final result = await getlikedpostusecase(event.postId);
    result.fold(
      (failure) {
        emit(PostState(
          status: PostStatus.likeLoadError,
          message: failure.message,
          posts: state.posts,
          likes: state.likes,
          comments: state.comments,
        ));
      },
      (likeUserIds) {
        Set<String> userIds = likeUserIds.toSet();
        emit(PostState(
          status: PostStatus.likeLoadSuccess,
          posts: state.posts,
          likes: {event.postId: userIds},
          comments: state.comments,
        ));
      },
    );
  }

  Future<void> _onSetLike(setlike event, Emitter<PostState> emit) async {
    final posts = state.posts;
    // emit(PostState(
    //   status: PostStatus.likeToggleLoading,
    //   posts: posts,
    // ));
    final user = await getCurrentuserUsercase();
    final userId = user?.user_id ?? '';

    // Get current post and its likes
    if (posts[event.postId] == null) {
      emit(PostState(
          message: 'Post not found',
          posts: posts,
          status: PostStatus.likeToggleError));
      // add(LoadIndividualPostEvent(postId: event.postId));

      return;
    }
    final currentPost = posts[event.postId]!;
    final result = await changeLikePostUseCase(event.postId, userId);
    result.fold((failure) {
      // Revert optimistic update on failure
      emit(PostState(
        message: failure.message,
        posts: posts,
        status: PostStatus.likeToggleError,
      ));
    }, (r) {
      // Update post with new like count
      final updatedPosts = Map<String, PostModel>.from(posts);
      updatedPosts[event.postId] = currentPost.copyWith(
        likesCount: currentPost.likesCount + (r ? 1 : -1),
        isliked: r,
      );
      emit(PostState(
        status: PostStatus.likeToggleSuccess,
        posts: updatedPosts,
        likes: state.likes,
      ));
    });
  }

  Future<void> _onGetComment(getcomment event, Emitter<PostState> emit) async {
    final posts = state.posts;
    // Clone to a mutable map before modifications
    final comments = Map<String, CommentModel>.from(state.comments);
    emit(PostState(
      posts: posts,
      status: PostStatus.commentLoadLoading,
      comments: comments,
      likes: state.likes,
    ));
    final result = await getCommentedPostUseCase(
      postId: event.postId,
      page: event.page,
      limit: event.limit,
    );
    result.fold((failure) {
      emit(PostState(
          posts: posts,
          status: PostStatus.commentLoadError,
          comments: comments,
          likes: state.likes,
          message: failure.message));
    }, (data) {
      if (event.page == 1) {
        comments.clear();
      }
      data.forEach((element) => comments[element.id] = element);
      emit(PostState(
          posts: posts,
          comments: comments,
          status: PostStatus.commentLoadSuccess,
          likes: state.likes));
    });
  }

  Future<void> _onSetComment(setcomment event, Emitter<PostState> emit) async {
    // Root comment only (no parentId)
    final posts = Map<String, PostModel>.from(state.posts);
    // Clone to a mutable map before modifications
    final comments = Map<String, CommentModel>.from(state.comments);
    emit(PostState(
        posts: posts,
        status: PostStatus.commentCreateLoading,
        comments: comments));
    final res = await setCommentUseCase(event.postId, event.content);
    res.fold(
      (failure) {
        emit(PostState(
            status: PostStatus.commentCreateError,
            posts: posts,
            message: failure.message));
      },
      (data) async {
        comments[data.id] = data;
        // Increment the post's comments count if present
        final post = posts[event.postId];
        if (post != null) {
          posts[event.postId] = post.copyWith(
            commentsCount: (post.commentsCount) + 1,
          );
        }
        emit(PostState(
            posts: posts,
            status: PostStatus.commentCreateSuccess,
            comments: comments));
        await NotificationIntegration.createCommentNotification(
          postId: event.postId,
          postOwnerId: posts[event.postId]!.user_id,
          commentText: event.content,
          commentId: data.id,
        );
      },
    );
  }

  Future<void> _onSetReplyComment(
      setreplycomment event, Emitter<PostState> emit) async {
    // // Reply comment (has parentId)
    final posts = state.posts;
    emit(PostState(
        posts: posts,
        likes: state.likes,
        individualPost: state.individualPost,
        status: PostStatus.commentCreateLoading,
        comments: state.comments));
    final res = await setReplyCommentUseCase(
        event.postId, event.parentCommentId, event.content);
    res.fold(
      (failure) {
        emit(PostState(
            status: PostStatus.commentCreateError,
            posts: posts,
            message: failure.message));
      },
      (data) async {
        emit(PostState(
            posts: posts,
            status: PostStatus.commentCreateSuccess,
            comments: state.comments..addAll({data.id: data})));
        await NotificationIntegration.createCommentNotification(
          postId: event.postId,
          postOwnerId: posts[event.postId]!.user_id,
          commentText: event.content,
          commentId: data.id,
        );
      },
    );
  }

  Future<void> _onLoadIndividualPost(
      LoadIndividualPostEvent event, Emitter<PostState> emit) async {
    final posts = state.posts;
    emit(PostState(
      posts: posts,
      status: PostStatus.individualPostLoadLoading,
      comments: state.comments,
      likes: state.likes,
    ));
    try {
      final user = await getCurrentuserUsercase();
      final result = await getIndividualPostUseCase(
        postId: event.postId,
        token: user!.token,
      );
      emit(PostState(
        individualPost: result,
        posts: posts,
        status: PostStatus.individualPostLoadSuccess,
        comments: state.comments,
        likes: state.likes,
      ));
    } on Exception catch (e) {
      emit(PostState(
        posts: posts,
        status: PostStatus.individualPostLoadError,
        comments: state.comments,
        likes: state.likes,
      ));
    }
  }
}
