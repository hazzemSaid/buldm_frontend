import 'package:bloc/bloc.dart';
import 'package:buldm/core/failure/failure.dart';
import 'package:buldm/features/auth/domain/usecases/forgotPasswordusecase.dart';
import 'package:buldm/features/auth/domain/usecases/get_currentuser_usercase.dart';
import 'package:buldm/features/auth/domain/usecases/google_auth_usecase.dart';
import 'package:buldm/features/auth/domain/usecases/resetpasswordusecase.dart';
import 'package:buldm/features/auth/domain/usecases/sendVerificationEmailAgain_usecase.dart';
import 'package:buldm/features/auth/domain/usecases/signin_user_usecase.dart';
import 'package:buldm/features/auth/domain/usecases/signout_usecase.dart';
import 'package:buldm/features/auth/domain/usecases/signup_user_usecase.dart';
import 'package:buldm/features/auth/domain/usecases/verifyCodeusecase.dart';
import 'package:buldm/features/auth/domain/usecases/verifyEmailCode.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignInUserUseCase signInUserUseCase;
  final SignUpUserUseCase signUpUserUseCase;
  final GoogleAuthUsecase googleAuthUsecase;
  final GetCurrentuserUsercase getCurrentuserUsercase;
  final SignOutUseCase signOutUseCase;
  final VerifyEmailCode verifyEmailCode;
  final SendVerificationEmailAgainUseCase sendVerificationEmailAgain;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final ResetPassword passwordResetRequest;
  final VerifyCode verificationCode;
  AuthCubit({
    required this.verificationCode,
    required this.passwordResetRequest,
    required this.forgotPasswordUseCase,
    required this.sendVerificationEmailAgain,
    required this.verifyEmailCode,
    required this.signOutUseCase,
    required this.getCurrentuserUsercase,
    required this.signInUserUseCase,
    required this.googleAuthUsecase,
    required this.signUpUserUseCase,
  }) : super(AuthInitial());
  // Method to handle user sign-in
  Future<void> signIn({required String email, required String password}) async {
    emit(Loading());
    final user = await signInUserUseCase(email: email, password: password);
    user.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (userModel) => emit(Authenticated(user: userModel)),
    );
  }

  // Method to handle user sign-up
  Future<void> signUp(String email, String password, String name) async {
    emit(Loading());

    final result = await signUpUserUseCase(
      email: email,
      password: password,
      name: name,
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (userModel) => emit(SignUp(userRegistration: userModel)),
    );
  }

  Future<void> authWithGoogle() async {
    emit(GoogleLoading());
    // try {
    //   final result = await googleAuthUsecase.signInWithGoogle();
    //   print("Google Auth Result: $result");
    //   if (result.isLeft) {
    //     emit(AuthError(message: result.left));
    //     return;
    //   } else {
    //     emit(Authenticated(user: result.right));
    //   }
    // } catch (e) {
    //   final Failure failure = Failure(error: e);
    //   emit(AuthError(message: failure.message));
    final response = await googleAuthUsecase.signInWithGoogle();
    if (response.isLeft) {
      emit(GoogleAuthError(message: response.left));
    } else {
      emit(Authenticated(user: response.right));
    }
  }

  Future<void> appStarted() async {
    final user = await getCurrentuserUsercase();
    if (user != null) {
      emit(Authenticated(user: user));
    } else {
      emit(UnAuthenticated());
    }
  }

  Future<void> signOut() async {
    try {
      await signOutUseCase.signOut();
      emit(UnAuthenticated());
    } catch (e) {
      final Failure failure = Failure(error: e);
      emit(AuthError(message: failure.message));
    }
  }

  Future<void> verifyEmail(
      {required String code, required String email}) async {
    emit(Loading());
    final response = await verifyEmailCode.call(code, email);

    response.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> sendverificationemailagain({required String email}) async {
    emit(Loading());
    final response = await sendVerificationEmailAgain.call(email: email);
    response.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (message) => emit(
          resendVerificationCode(message: 'Verification code sent to $email')),
    );
  }

  Future<void> forgotPassword({required String email}) async {
    emit(Loading());
    final response = await forgotPasswordUseCase.call(email: email);
    response.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(
          ForgotPasswordSuccess(message: 'Password reset link sent to $email')),
    );
  }

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    emit(Loading());
    final response = await passwordResetRequest.call(
      email: email,
      newPassword: newPassword,
    );
    response.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(ResetPasswordSuccess(message: 'Password reset successful')),
    );
  }

  Future<void> checkVerificationCode(
      {required String email, required String code}) async {
    emit(Loading());
    final response = await verificationCode.call(email: email, code: code);
    response.fold(
      (failure) => emit(Verifycodeerror(message: failure.message)),
      (_) => emit(Verifycodesuccess(message: 'Verification code is valid')),
    );
  }
}
