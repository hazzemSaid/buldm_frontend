import 'package:bloc/bloc.dart';
import 'package:buldm/features/auth/domain/repository/Iauthrepository.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final authRepositoryInterface authRepository;
  AuthCubit({
    required this.authRepository,
  }) : super(AuthInitial());
  // Method to handle user sign-in
  Future<void> signIn(String email, String password) async {
    try {
      final user = await authRepository.signInWithEmailAndPassword(
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
      final userRegistration = await authRepository.signUpWithEmailAndPassword(
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
      final result = await authRepository.authwithgoogle();
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
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user: user));
      } else {
        emit(UnAuthenticated());
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}
