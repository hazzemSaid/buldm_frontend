import 'package:bloc/bloc.dart';
import 'package:buldm/features/profile/domain/usecases/searchByname.dart';
import 'package:buldm/features/profile/presentation/view/screens/OtherUserProfileScreen.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'Search_State.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchByName searchByName;
  SearchCubit({
    required this.searchByName,
  }) : super(SearchInitial());

  // Method to load users based on search criteria
  Future<void> searchUsers(String query) async {
    emit(SearchLoading());
    try {
      // Simulate a network call or database query
      final Response response = await searchByName.call(name: query);
      if (response.statusCode != 200) {
        emit(SearchError(message: 'Failed to fetch users'));
        return;
      }
      final List<ViewerUser> users = (response.data['users'] as List)
          .map((user) => ViewerUser.fromJson(user))
          .toList();
      emit(SearchLoaded(users: users));
    } catch (e) {
      emit(SearchError(message: e.toString()));
    }
  }

  // Method to clear the search results
  void clearSearch() {
    emit(SearchInitial());
  }
}
