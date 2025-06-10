import 'package:buldm/features/auth/data/model/usermodel.dart';
import 'package:buldm/features/auth/data/repositery/AuthRepositoryImpl%20.dart';
import 'package:buldm/features/auth/presentaion/view/viewmodel/auth/auth_state.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class AuthCubit extends HydratedCubit<AuthState> {
  final Authrepositoryimpl _auth;
  Future<UserModel?> getCurrentUser() async {
    final user = await _auth.getCurrentUser();

    return user;
  }

  AuthCubit(this._auth) : super(AuthInitial()) {
    if (state is AuthInitial) {
      _initialize();
    }
  }

  Future<void> _initialize() async {
    try {
      final user = await _auth.getCurrentUser();
      emit(user != null ? Authenticated(usermodel: user) : Unauthenticated());
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  Future<void> authwithgoogle() async {
    emit(AuthLoading());
    try {
      final result = await _auth.authwithgoogle();
      result.fold((error) => emit(AuthFailure(error)), (user) {
        //save the user into hive
        _auth.setCurrentUser(user);
        emit(Authenticated(usermodel: user));
      });
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  // Add this import

  // Create a single instance (preferably as a field in your repository or cubit)

  // Example: Save token

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    try {
      print("Loading from json: $json");
      if (json['user'] != null) {
        final user = UserModel.fromJson(json['user']);
        return Authenticated(usermodel: user);
      }
    } catch (e) {
      print("Error restoring state: $e");
      return Unauthenticated();
    }
    return AuthInitial();
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    if (state is Authenticated) {
      print("Saving to json: ${state.usermodel.toJson()}");
      return {'user': state.usermodel.toJson()};
    } else if (state is Unauthenticated) {
      return {};
    }
    return null; // For AuthInitial or other states, return null
  }
}
