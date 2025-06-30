import 'package:bloc/bloc.dart';
import 'package:buldm/features/auth/domain/usecases/get_currentuser_usercase.dart';
import 'package:buldm/features/auth/domain/usecases/google_auth_usecase.dart';
import 'package:buldm/features/auth/domain/usecases/signin_user_usecase.dart';
import 'package:buldm/features/auth/domain/usecases/signout_usecase.dart';
import 'package:buldm/features/auth/domain/usecases/signup_user_usecase.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignInUserUseCase signInUserUseCase;
  final SignUpUserUseCase signUpUserUseCase;
  final GoogleAuthUsecase googleAuthUsecase;
  final GetCurrentuserUsercase getCurrentuserUsercase;
  final SignOutUseCase signOutUseCase;
  AuthCubit({
    required this.signOutUseCase,
    required this.getCurrentuserUsercase,
    required this.signInUserUseCase,
    required this.googleAuthUsecase,
    required this.signUpUserUseCase,
  }) : super(AuthInitial());
  // Method to handle user sign-in
  Future<void> signIn({required String email, required String password}) async {
    try {
      final user = await signInUserUseCase(
        email: email,
        password: password,
      );
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  // Method to handle user sign-up
  Future<void> signUp(String email, String password, String name) async {
    try {
      final userRegistration = await signUpUserUseCase(
        email: email,
        password: password,
        name: name,
      );
      emit(SignUp(userRegistration: userRegistration));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> authWithGoogle() async {
    try {
      final result = await googleAuthUsecase.signInWithGoogle();
      print("Google Auth Result: $result");
      if (result.isLeft) {
        emit(AuthError(message: result.left));
      } else {
        emit(Authenticated(user: result.right));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> appStarted() async {
    try {
      final user = await getCurrentuserUsercase();
      if (user != null) {
        emit(Authenticated(user: user));
      } else {
        emit(UnAuthenticated());
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> signOut() async {
    try {
      await signOutUseCase.signOut();
      emit(UnAuthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}
