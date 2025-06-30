import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:buldm/features/auth/domain/usecases/get_currentuser_usercase.dart';
import 'package:buldm/features/home/domain/entities/postentity.dart';
import 'package:buldm/features/home/domain/usecases/getPostUseCase.dart';
import 'package:equatable/equatable.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final GetPostUseCase getPostUseCase;
  final GetCurrentuserUsercase getCurrentuserUsercase;
  PostBloc({required this.getCurrentuserUsercase, required this.getPostUseCase})
      : super(PostInitial()) {
    on<LoadPostEvent>(_onLoadPost);
    on<AddPostEvent>(_onAddPost);
    on<UpdatePostEvent>(_onUpdatePost);
    on<DeletePostEvent>(_onDeletePost);
    on<FilterPostEvent>(_onFilterPost);
  }

  Future<void> _onLoadPost(LoadPostEvent event, Emitter<PostState> emit) async {
    emit(PostLoading());
    print("Loading posts with event: $event");
    try {
      final user = await getCurrentuserUsercase();
      final token = user?.token ?? '';

      final posts = await getPostUseCase(
        category: event.category,
        status: event.status,
        userId: event.userId,
        searchQuery: event.searchQuery,
        limit: event.limit,
        offset: event.offset,
        token: token,
      );

      emit(PostLoaded(posts: posts));
    } catch (e) {
      if (e is Failure) {
        emit(PostError(message: e.message));
      } else {
        emit(PostError(message: 'An unexpected error occurred'));
      }
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
}

class Failure {
  final String message;
  const Failure(this.message);
}
