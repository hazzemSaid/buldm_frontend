import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:buldm/features/Add_Post/data/model/UploadablePostModel.dart';
import 'package:buldm/features/auth/domain/usecases/get_currentuser_usercase.dart';
import 'package:buldm/features/home/data/models/comments.dart';
import 'package:buldm/features/home/data/models/like.dart';
import 'package:buldm/features/home/data/models/post_model.dart';
import 'package:buldm/features/home/domain/entities/postentity.dart';
import 'package:buldm/features/home/domain/usecases/changeikepostUsecase.dart';
import 'package:buldm/features/home/domain/usecases/createPostUseCase.dart';
import 'package:buldm/features/home/domain/usecases/deletpostUsecase.dart';
import 'package:buldm/features/home/domain/usecases/getPostUseCase.dart';
import 'package:buldm/features/home/domain/usecases/getcommentedpostUsecase.dart';
import 'package:buldm/features/home/domain/usecases/getlikedpostUsecase.dart';
import 'package:buldm/features/home/domain/usecases/setcommentUsecase.dart';
import 'package:buldm/features/home/domain/usecases/setreplycommentUsecase.dart';
import 'package:buldm/features/home/domain/usecases/updatepostUsecase.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  bool isFetchingMore = false;

  final GetPostUseCase getPostUseCase;
  final GetCurrentuserUsercase getCurrentuserUsercase;
  final Createpostusecase createPostUsecase;
  final GetCommentedPostUseCase getCommentedPostUseCase;
  final UpdatePostUseCase updatePostUseCase;
  final SetReplyCommentUseCase setReplyCommentUseCase;
  final SetCommentUseCase setCommentUseCase;
  final Getlikedpostusecase getlikedpostusecase;
  final DeletePostUseCase deletePostUseCase;
  final ChangeLikePostUseCase changeLikePostUseCase;
  PostBloc(
      {required this.getCurrentuserUsercase,
      required this.getPostUseCase,
      required this.createPostUsecase,
      required this.getCommentedPostUseCase,
      required this.updatePostUseCase,
      required this.setReplyCommentUseCase,
      required this.setCommentUseCase,
      required this.getlikedpostusecase,
      required this.deletePostUseCase,
      required this.changeLikePostUseCase})
      : super(PostInitial()) {
    on<LoadPostEvent>(_onLoadPost);
    on<AddPostEvent>(_onAddPost);
    on<uploadPostEvent>(_onUpdatePost);

    on<DeletePostEvent>(_onDeletePost);
    on<FilterPostEvent>(_onFilterPost);
    on<LoadMorePostsEvent>(_onLoadMorePosts);
    // on<getlike>(_onGetLike);
    on<setlike>(_onSetLike);
    on<getcomment>(_onGetComment);
    on<setcomment>(_onSetComment);
    on<setreplycomment>(_onSetReplyComment);
  }

  Future<void> _onLoadPost(LoadPostEvent event, Emitter<PostState> emit) async {
    emit(PostLoading());

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
      emit(PostLoaded(
        posts: newPosts,
        hasMore: newPosts.length == event.limit,
        category: event.category,
        status: event.status,
        userId: event.userId,
        searchQuery: event.searchQuery,
        pageSize: event.limit,
        currentPage: event.page,
      ));
    } catch (e) {
      emit(PostError(message: e.toString()));
    }
  }

  Future<void> _onAddPost(AddPostEvent event, Emitter<PostState> emit) async {
    emit(PostLoading());
    try {
      final user = await getCurrentuserUsercase();
      final token = user?.token ?? '';
      final postModel = event.post;
      final data = postModel.toJson();
      final formData = FormData.fromMap({
        ...data,
        'images': await Future.wait(event.imageFiles.map((file) async {
          return await MultipartFile.fromFile(file.path,
              filename: file.path.split('/').last);
        })),
      });
      await createPostUsecase(data: formData, token: token);

      emit(PostCreatedState(userId: postModel.user_id));
      // Optionally, you can reload posts after adding a new one
      add(LoadPostEvent(
        category: null,
        status: null,
        userId: null,
        searchQuery: null,
        limit: 5,
        page: 1,
      ));
    } catch (e) {
      emit(PostError(message: e.toString()));
    }
  }

  Future<void> _onUpdatePost(
      uploadPostEvent event, Emitter<PostState> emit) async {
    emit(PostLoading());
    try {
      final user = await getCurrentuserUsercase();
      final token = user?.token ?? '';
      final uploadpostmodel = event.post;
      final data = uploadpostmodel.toJson();
      final formData = FormData.fromMap({
        ...data,
        'images': await Future.wait(uploadpostmodel.images.map((image) async {
          return await MultipartFile.fromFile(image.path,
              filename: image.path.split('/').last);
        })),
      });
      await createPostUsecase(data: formData, token: token);

      emit(PostCreatedState(userId: uploadpostmodel.user_id));
      // Optionally, you can reload posts after adding a new one
      add(LoadPostEvent(
        category: null,
        status: null,
        userId: null,
        searchQuery: null,
        limit: 5,
        page: 1,
      ));
    } catch (e) {
      emit(PostError(message: e.toString()));
    }
  }

  Future<void> _onDeletePost(
      DeletePostEvent event, Emitter<PostState> emit) async {
    // Logic to delete a post
  }

  Future<void> _onFilterPost(
      FilterPostEvent event, Emitter<PostState> emit) async {
    // Logic to filter posts by category
  }

  Future<void> _onLoadMorePosts(
      LoadMorePostsEvent event, Emitter<PostState> emit) async {
    if (isFetchingMore) return;

    final currentState = state;
    if (currentState is PostLoaded && currentState.hasMore) {
      isFetchingMore = true;
      try {
        final user = await getCurrentuserUsercase();
        final token = user?.token ?? '';
        final currentPostsMap = Map<String, PostModel>.from(currentState.posts);
        final pageSize = currentState.pageSize;
        final nextPage = currentState.currentPage + 1;

        // Indicate loading more
        emit(currentState.copyWith(isLoadingMore: true));

        final fetched = await getPostUseCase(
          category: currentState.category,
          status: currentState.status,
          userId: currentState.userId,
          searchQuery: currentState.searchQuery,
          limit: pageSize,
          page: nextPage,
          token: token,
        );

        // Merge
        for (final p in fetched.values) {
          currentPostsMap[p.id] = p;
        }

        final hasMore = fetched.length == pageSize;
        emit(PostLoaded(
          posts: currentPostsMap,
          hasMore: hasMore,
          isLoadingMore: false,
          category: currentState.category,
          status: currentState.status,
          userId: currentState.userId,
          searchQuery: currentState.searchQuery,
          pageSize: pageSize,
          currentPage: nextPage,
        ));
      } catch (e) {
        emit(PostError(message: e.toString()));
      } finally {
        isFetchingMore = false;
      }
    }
  }

  // Future<void> _onGetLike(getlike event, Emitter<PostState> emit) async {
  //   final currentState = state;
  //   Map<String, PostModel> posts = {};
  //   bool hasMore = true;
  //   if (currentState is PostLoaded) {
  //     posts = currentState.posts;
  //     hasMore = currentState.hasMore;
  //   }
  //   try {
  //     final result = await getlikedpostusecase(event.postId);
  //     result.fold(
  //       (failure) => emit(PostError(message: failure.message)),
  //       (likeUserIds) {
  //         // Map user IDs to LikeModel to satisfy PostModel types

  //         // Update the specific post with new likes and count
  //         //time complexity O(1)
  //         final updated = Map<String, PostModel>.from(posts);
  //         updated[event.postId] = updated[event.postId]!.copyWith(
  //           likes: likeUserIds,
  //         );

  //         if (currentState is PostLoaded) {
  //           emit(currentState.copyWith(posts: updated));
  //         } else {
  //           emit(PostLoaded(posts: updated, hasMore: hasMore));
  //         }
  //       },
  //     );
  //   } catch (e) {
  //     emit(PostError(message: e.toString()));
  //   }
  // }

  Future<void> _onSetLike(setlike event, Emitter<PostState> emit) async {
    try {
      final user = await getCurrentuserUsercase();
      final userId = user?.user_id ?? '';
      final result = await changeLikePostUseCase(event.postId, userId);
      result.fold(
        (failure) => emit(PostError(message: failure.message)),
        (_) {
          // Refresh likes for this specific post
          // add(getlike(postId: event.postId));
        },
      );
    } catch (e) {
      emit(PostError(message: e.toString()));
    }
  }

  Future<void> _onGetComment(getcomment event, Emitter<PostState> emit) async {
    Map<String, PostModel> posts = {};
    bool hasMore = true;
    if (state is PostLoaded) {
      posts = (state as PostLoaded).posts;
      hasMore = (state as PostLoaded).hasMore;
    }
    try {
      print('[Comment][API][Request] postId=${event.postId}');
      print(event.limit);
      print(event.page);
      final result = await getCommentedPostUseCase(
        postId: event.postId,
        page: event.page,
        limit: event.limit,
      );
      result.fold(
        (failure) {
          print(
              '[Comment][API][Error] postId=${event.postId} err=${failure.message}');
          emit(CommentError(message: failure.message));
        },
        (data) {
          // Merge strategy: if page == 1, replace; else append with de-dup by id
          if (posts.isNotEmpty && posts[event.postId] != null) {
            final updated = Map<String, PostModel>.from(posts);
            final existing = updated[event.postId]!.comments;
            final merged = <CommentModel>[];
            if (event.page > 1) {
              merged.addAll(existing);
              merged.addAll(data);
              final seen = <String>{};
              final deduped = <CommentModel>[];
              for (final c in merged) {
                if (seen.add(c.id)) deduped.add(c);
              }
              updated[event.postId] =
                  updated[event.postId]!.copyWith(comments: deduped);
            } else {
              updated[event.postId] =
                  updated[event.postId]!.copyWith(comments: data);
            }
            emit((state as PostLoaded).copyWith(posts: updated));
          } else if (state is CommentsForPostLoaded &&
              (state as CommentsForPostLoaded).postId == event.postId) {
            final current = (state as CommentsForPostLoaded).comments;
            List<CommentModel> next;
            if (event.page > 1) {
              final merged = [...current, ...data];
              final seen = <String>{};
              next = [];
              for (final c in merged) {
                if (seen.add(c.id)) next.add(c);
              }
            } else {
              next = data;
            }
            emit(CommentsForPostLoaded(postId: event.postId, comments: next));
          } else {
            // Fallback: create minimal PostLoaded with just this post's comments if needed
            final updated = Map<String, PostModel>.from(posts);
            if (updated[event.postId] != null) {
              updated[event.postId] =
                  updated[event.postId]!.copyWith(comments: data);
              emit(PostLoaded(posts: updated, hasMore: hasMore));
            } else {
              // No post found in state; just emit comment list state
              emit(CommentsForPostLoaded(postId: event.postId, comments: data));
            }
          }
        },
      );
    } catch (e) {
      print('[Comment][API][Exception] postId=${event.postId} err=$e');
      print('[Comment][Received][Exception] postId=${event.postId} err=$e');
      emit(CommentError(message: e.toString()));
    }
  }

  Future<void> _onSetComment(setcomment event, Emitter<PostState> emit) async {
    // Root comment only (no parentId)
    Map<String, PostModel> posts = {};
    bool hasMore = true;
    bool isCommentsOnly = false;
    List<CommentModel> commentsForPost = const [];
    if (state is PostLoaded) {
      posts = (state as PostLoaded).posts;
      hasMore = (state as PostLoaded).hasMore;
    } else if (state is CommentsForPostLoaded &&
        (state as CommentsForPostLoaded).postId == event.postId) {
      isCommentsOnly = true;
      commentsForPost =
          List<CommentModel>.from((state as CommentsForPostLoaded).comments);
    }

    try {
      final res = await setCommentUseCase(event.postId, event.content);
      res.fold(
        (failure) {
          emit(CommentError(message: failure.message));
        },
        (data) {
          final updated = Map<String, PostModel>.from(posts);
          updated[event.postId] = updated[event.postId]!.copyWith(
            comments: List<CommentModel>.from(updated[event.postId]!.comments)
              ..add(data),
          );
          if (state is PostLoaded) {
            emit((state as PostLoaded).copyWith(posts: updated));
          } else {
            emit(PostLoaded(posts: updated, hasMore: hasMore));
          }
        },
      );
    } catch (e) {
      emit(CommentError(message: e.toString()));
    }
  }

  Future<void> _onSetReplyComment(
      setreplycomment event, Emitter<PostState> emit) async {
    // Reply comment (has parentId)
    Map<String, PostModel> posts = {};
    bool hasMore = true;
    bool isCommentsOnly = false;
    List<CommentModel> commentsForPost = const [];
    if (state is PostLoaded) {
      posts = (state as PostLoaded).posts;
      hasMore = (state as PostLoaded).hasMore;
    } else if (state is CommentsForPostLoaded &&
        (state as CommentsForPostLoaded).postId == event.postId) {
      isCommentsOnly = true;
      commentsForPost =
          List<CommentModel>.from((state as CommentsForPostLoaded).comments);
    }
    try {
      final res = await setReplyCommentUseCase(
          event.postId, event.parentCommentId, event.content);
      res.fold(
        (failure) {
          emit(CommentError(message: failure.message));
        },
        (data) {
          final updated = Map<String, PostModel>.from(posts);
          updated[event.postId] = updated[event.postId]!.copyWith(
            comments: List<CommentModel>.from(updated[event.postId]!.comments)
              ..add(data),
          );
          if (state is PostLoaded) {
            emit((state as PostLoaded).copyWith(posts: updated));
          } else {
            emit(PostLoaded(posts: updated, hasMore: hasMore));
          }
        },
      );
    } catch (e) {
      emit(CommentError(message: e.toString()));
    }
  }
}
