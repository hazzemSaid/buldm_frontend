import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:buldm/features/auth/domain/usecases/get_currentuser_usercase.dart';
import 'package:buldm/features/home/domain/entities/postentity.dart';
import 'package:buldm/features/home/domain/usecases/getPostUseCase.dart';
import 'package:equatable/equatable.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  bool isFetchingMore = false;

  final GetPostUseCase getPostUseCase;
  final GetCurrentuserUsercase getCurrentuserUsercase;
  PostBloc({required this.getCurrentuserUsercase, required this.getPostUseCase})
      : super(PostInitial()) {
    on<LoadPostEvent>(_onLoadPost);
    on<AddPostEvent>(_onAddPost);
    on<UpdatePostEvent>(_onUpdatePost);
    on<DeletePostEvent>(_onDeletePost);
    on<FilterPostEvent>(_onFilterPost);
    on<LoadMorePostsEvent>(_onLoadMorePosts);
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
    // Logic to add a post
  }

  Future<void> _onUpdatePost(
      UpdatePostEvent event, Emitter<PostState> emit) async {
    // Logic to update a post
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
}

class Failure {
  final String message;
  const Failure(this.message);
}
