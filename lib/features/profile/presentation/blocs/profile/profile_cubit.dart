import 'package:bloc/bloc.dart';
import 'package:buldm/features/home/data/models/post_model.dart';
import 'package:buldm/features/profile/domain/usecases/fetchpost.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required this.fetchpostUseCase}) : super(ProfileInitial());
  final Fetchpost fetchpostUseCase;
  List<PostModel> _allPosts = [];

  // fetch from API, cache full list, and emit loaded
  Future<void> fetchPost(
      {required String token, required String userId}) async {
    emit(ProfileLoading());
    try {
      final response =
          await fetchpostUseCase.call(token: token, userId: userId);
      if (response.statusCode != 200) {
        emit(ProfileError(message: 'Failed to fetch posts'));
      }
      final List<PostModel> posts = (response.data['data'] as List)
          .map((post) => PostModel.fromJson(post))
          .toList();
      _allPosts = posts;
      emit(fetchpost(posts: posts));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  // filter against the cached _allPosts
  void filterpost({required bool status}) {
    final filtered = _allPosts
        .where((post) => post.status == (status ? 'lost' : 'found'))
        .toList();
    emit(fetchpost(posts: filtered));
  }
}
