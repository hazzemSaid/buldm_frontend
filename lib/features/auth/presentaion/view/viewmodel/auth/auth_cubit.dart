import 'package:buldm/features/auth/data/model/usermodel.dart';
import 'package:buldm/features/auth/data/repositery/AuthRepositoryImpl%20.dart';
import 'package:buldm/features/auth/presentaion/view/viewmodel/auth/auth_state.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class AuthCubit extends HydratedCubit<AuthState> {
  final Authrepositoryimpl _auth;
  UserModel? getCurrentUser() {
    return state is Authenticated ? (state as Authenticated).usermodel : null;
  }

  AuthCubit(this._auth) : super(AuthInitial()) {
    _initialize();
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
      result.fold(
        (error) => emit(AuthFailure(error)),
        (user) => emit(Authenticated(usermodel: user)),
      );
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
      if (json['user'] != null) {
        final user = UserModel.fromJson(json['user']);
        return Authenticated(usermodel: user);
      }
    } catch (e) {
      // Log error if needed
    }
    return AuthInitial();
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    return state is Authenticated ? {'user': state.usermodel.toJson()} : null;
  }
}
