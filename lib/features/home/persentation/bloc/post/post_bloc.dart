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
    on<getlike>(_onGetLike);
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

      emit(
          PostLoaded(posts: newPosts, hasMore: newPosts.length == event.limit));
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
        final currentPosts = currentState.posts;
        final nextPage = (currentPosts.length / 5).ceil() + 1;

        final newPosts = await getPostUseCase(
          category: null,
          status: null,
          userId: null,
          searchQuery: null,
          limit: 5,
          page: nextPage,
          token: token,
        );

        final hasMore = newPosts.length == 5;
        emit(PostLoaded(
          posts: [...currentPosts, ...newPosts],
          hasMore: hasMore,
        ));
      } catch (e) {
        emit(PostError(message: e.toString()));
      } finally {
        isFetchingMore = false;
      }
    }
  }

  Future<void> _onGetLike(getlike event, Emitter<PostState> emit) async {
    final currentState = state;
    List<PostModel> posts = [];
    bool hasMore = true;
    if (currentState is PostLoaded) {
      posts = currentState.posts;
      hasMore = currentState.hasMore;
    }
    try {
      final result = await getlikedpostusecase(event.postId);
      result.fold(
        (failure) => emit(PostError(message: failure.message)),
        (likeUserIds) {
          // Map user IDs to LikeModel to satisfy PostModel types

          // Update the specific post with new likes and count
          final updatedPosts = posts.map((post) {
            if (post.id == event.postId) {
              return post.copyWith(likes: likeUserIds);
            }
            return post;
          }).toList();

          emit(PostLoaded(posts: updatedPosts, hasMore: hasMore));
        },
      );
    } catch (e) {
      emit(PostError(message: e.toString()));
    }
  }

  Future<void> _onSetLike(setlike event, Emitter<PostState> emit) async {
    try {
      final user = await getCurrentuserUsercase();
      final userId = user?.user_id ?? '';
      final result = await changeLikePostUseCase(event.postId, userId);
      result.fold(
        (failure) => emit(PostError(message: failure.message)),
        (_) {
          // Refresh likes for this specific post
          add(getlike(postId: event.postId));
        },
      );
    } catch (e) {
      emit(PostError(message: e.toString()));
    }
  }

  Future<void> _onGetComment(getcomment event, Emitter<PostState> emit) async {
    List<PostModel> posts = [];
    bool hasMore = true;
    if (state is PostLoaded) {
      posts = (state as PostLoaded).posts;
      hasMore = (state as PostLoaded).hasMore;
    }
    try {
      print('[Comment][API][Request] postId=${event.postId}');
      final result = await getCommentedPostUseCase(event.postId);
      result.fold(
        (failure) {
          print(
              '[Comment][API][Error] postId=${event.postId} err=${failure.message}');
          emit(CommentError(message: failure.message));
        },
        (data) {
          print(
              '[Comment][API][Success] postId=${event.postId} count=${data.length}');
          print(
              '[Comment][Received] postId=${event.postId} count=${data.length}');
          for (final c in data) {
            final createdIso = c.createdAt.toIso8601String();
            print('[Comment][Received][Item] id='
                '${c.id} parent=${c.parentCommentId ?? ''} user=${c.userId} createdAt='
                '$createdIso content="${c.comment}"');
          }
          if (posts.isEmpty ||
              posts.where((p) => p.id == event.postId).isEmpty) {
            // No posts in this bloc instance; emit a dedicated state with comments
            print(
                '[Comment][State] Emitting CommentsForPostLoaded for postId=${event.postId}');
            emit(CommentsForPostLoaded(postId: event.postId, comments: data));
          } else {
            // Immutably update the specific post with new comments
            final updatedPosts = posts.map((p) {
              if (p.id == event.postId) {
                return p.copyWith(
                  comments: data,
                  commentsCount: data.length,
                );
              }
              return p;
            }).toList();
            print(
                '[Comment][State] Emitting PostLoaded with updated comments for postId=${event.postId}');
            emit(PostLoaded(posts: updatedPosts, hasMore: hasMore));
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
    List<PostModel> posts = [];
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

    final user = await getCurrentuserUsercase();
    final optimisticId = 'pending_${DateTime.now().millisecondsSinceEpoch}';
    final optimisticComment = CommentModel(
      comment: event.content,
      userId: user?.user_id ?? '',
      postId: event.postId,
      createdAt: DateTime.now(),
      id: optimisticId,
      parentCommentId: null,
    );
    print(
        '[Comment][Send][Optimistic] postId=${event.postId} tempId=$optimisticId parentId='
        '${optimisticComment.parentCommentId ?? ''} content="${event.content}" state='
        '${state.runtimeType}');

    if (posts.isNotEmpty) {
      final updatedPosts = posts.map((p) {
        if (p.id == event.postId) {
          final newComments = List<CommentModel>.from(p.comments)
            ..add(optimisticComment);
          return p.copyWith(
            comments: newComments,
            commentsCount: newComments.length,
          );
        }
        return p;
      }).toList();
      emit(PostLoaded(posts: updatedPosts, hasMore: hasMore));
    } else if (isCommentsOnly) {
      final updated = List<CommentModel>.from(commentsForPost)
        ..add(optimisticComment);
      emit(CommentsForPostLoaded(postId: event.postId, comments: updated));
    }

    try {
      print(
          '[Comment][API][Root][Request] postId=${event.postId} content="${event.content}"');
      final res = await setCommentUseCase(event.postId, event.content);
      res.fold(
        (failure) {
          print(
              '[Comment][API][Root][Failure] postId=${event.postId} err=${failure.message}');
          if (posts.isNotEmpty) {
            final reverted = posts.map((p) {
              if (p.id == event.postId) {
                final filtered =
                    p.comments.where((c) => c.id != optimisticId).toList();
                return p.copyWith(
                  comments: filtered,
                  commentsCount: filtered.length,
                );
              }
              return p;
            }).toList();
            emit(PostLoaded(posts: reverted, hasMore: hasMore));
          } else if (isCommentsOnly) {
            final filtered =
                commentsForPost.where((c) => c.id != optimisticId).toList();
            emit(CommentsForPostLoaded(
                postId: event.postId, comments: filtered));
          }
          emit(CommentError(message: failure.message));
        },
        (_) {
          print(
              '[Comment][API][Root][Success] postId=${event.postId} -> refresh');
          add(getcomment(postId: event.postId));
        },
      );
    } catch (e) {
      print('[Comment][API][Exception] postId=${event.postId} err=$e');
      if (posts.isNotEmpty) {
        final reverted = posts.map((p) {
          if (p.id == event.postId) {
            final filtered =
                p.comments.where((c) => c.id != optimisticId).toList();
            return p.copyWith(
              comments: filtered,
              commentsCount: filtered.length,
            );
          }
          return p;
        }).toList();
        emit(PostLoaded(posts: reverted, hasMore: hasMore));
      } else if (isCommentsOnly) {
        final filtered =
            commentsForPost.where((c) => c.id != optimisticId).toList();
        emit(CommentsForPostLoaded(postId: event.postId, comments: filtered));
      }
      emit(CommentError(message: e.toString()));
    }
  }

  Future<void> _onSetReplyComment(
      setreplycomment event, Emitter<PostState> emit) async {
    // Reply comment (has parentId)
    List<PostModel> posts = [];
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

    final user = await getCurrentuserUsercase();
    final optimisticId = 'pending_${DateTime.now().millisecondsSinceEpoch}';
    final optimisticComment = CommentModel(
      comment: event.content,
      userId: user?.user_id ?? '',
      postId: event.postId,
      createdAt: DateTime.now(),
      id: optimisticId,
      parentCommentId: event.parentCommentId,
    );
    print(
        '[Comment][Send][Optimistic] postId=${event.postId} tempId=$optimisticId parentId='
        '${optimisticComment.parentCommentId ?? ''} content="${event.content}" state='
        '${state.runtimeType}');

    if (posts.isNotEmpty) {
      final updatedPosts = posts.map((p) {
        if (p.id == event.postId) {
          final newComments = List<CommentModel>.from(p.comments)
            ..add(optimisticComment);
          return p.copyWith(
            comments: newComments,
            commentsCount: newComments.length,
          );
        }
        return p;
      }).toList();
      emit(PostLoaded(posts: updatedPosts, hasMore: hasMore));
    } else if (isCommentsOnly) {
      final updated = List<CommentModel>.from(commentsForPost)
        ..add(optimisticComment);
      emit(CommentsForPostLoaded(postId: event.postId, comments: updated));
    }

    try {
      final parentIdForRequest = optimisticComment.parentCommentId ?? '';
      if (parentIdForRequest.isEmpty) {
        emit(const CommentError(message: 'Missing parentCommentId for reply'));
        return;
      }
      print(
          '[Comment][API][Reply][Request] postId=${event.postId} parentId=$parentIdForRequest content="${event.content}"');
      final res = await setReplyCommentUseCase(
          event.postId, parentIdForRequest, event.content);
      res.fold(
        (failure) {
          print(
              '[Comment][API][Reply][Failure] postId=${event.postId} err=${failure.message}');
          if (posts.isNotEmpty) {
            final reverted = posts.map((p) {
              if (p.id == event.postId) {
                final filtered =
                    p.comments.where((c) => c.id != optimisticId).toList();
                return p.copyWith(
                  comments: filtered,
                  commentsCount: filtered.length,
                );
              }
              return p;
            }).toList();
            emit(PostLoaded(posts: reverted, hasMore: hasMore));
          } else if (isCommentsOnly) {
            final filtered =
                commentsForPost.where((c) => c.id != optimisticId).toList();
            emit(CommentsForPostLoaded(
                postId: event.postId, comments: filtered));
          }
          emit(CommentError(message: failure.message));
        },
        (_) {
          print(
              '[Comment][API][Reply][Success] postId=${event.postId} parentId=$parentIdForRequest');
          // emit(ReplySuccess(
          //     postId: event.postId, parentCommentId: parentIdForRequest));
          add(getcomment(postId: event.postId));
        },
      );
    } catch (e) {
      print('[Comment][API][Exception] postId=${event.postId} err=$e');
      if (posts.isNotEmpty) {
        final reverted = posts.map((p) {
          if (p.id == event.postId) {
            final filtered =
                p.comments.where((c) => c.id != optimisticId).toList();
            return p.copyWith(
              comments: filtered,
              commentsCount: filtered.length,
            );
          }
          return p;
        }).toList();
        emit(PostLoaded(posts: reverted, hasMore: hasMore));
      } else if (isCommentsOnly) {
        final filtered =
            commentsForPost.where((c) => c.id != optimisticId).toList();
        emit(CommentsForPostLoaded(postId: event.postId, comments: filtered));
      }
      emit(CommentError(message: e.toString()));
    }
  }
}
