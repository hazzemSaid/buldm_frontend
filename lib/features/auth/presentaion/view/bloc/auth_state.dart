import 'package:buldm/features/auth/data/model/usermodel.dart';
import 'package:buldm/features/auth/domain/entities/registeruserentities.dart';
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {}

class passwordLoading extends AuthState {
  @override
  List<Object?> get props => [];
}

class Codeloading extends AuthState {
  @override
  List<Object?> get props => [];
}

// Initial state of the authentication
class AuthInitial extends AuthState {
  @override
  List<Object?> get props => [];
}

//signin , signup , google_auth , authenticated , unauthenticated

class SignUp extends AuthState {
  final UserRegistration userRegistration;
  SignUp({required this.userRegistration});

  @override
  List<Object?> get props => [userRegistration];
}

class Authenticated extends AuthState {
  final UserModel user;

  Authenticated({
    required this.user,
  });

  @override
  List<Object?> get props => [user];
}

class UnAuthenticated extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthError extends AuthState {
  final String message;

  AuthError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

class Loading extends AuthState {
  @override
  List<Object?> get props => [];
}

class GoogleLoading extends AuthState {
  @override
  List<Object?> get props => [];
}

class GoogleAuthSuccess extends AuthState {
  final UserModel user;

  GoogleAuthSuccess({
    required this.user,
  });

  @override
  List<Object?> get props => [user];
}

class GoogleAuthError extends AuthState {
  final String message;

  GoogleAuthError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

class resendVerificationCode extends AuthState {
  final String message;

  resendVerificationCode({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

class ForgotPasswordLoading extends AuthState {
  @override
  List<Object?> get props => [];
}

class ForgotPasswordSuccess extends AuthState {
  final String message;

  ForgotPasswordSuccess({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

class ForgotPasswordError extends AuthState {
  final String message;

  ForgotPasswordError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

class ResetPasswordLoading extends AuthState {
  @override
  List<Object?> get props => [];
}

class ResetPasswordSuccess extends AuthState {
  final String message;

  ResetPasswordSuccess({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

class ResetPasswordError extends AuthState {
  final String message;

  ResetPasswordError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

class Verifycodeloading extends AuthState {
  @override
  List<Object?> get props => [];
}

class Verifycodesuccess extends AuthState {
  final String message;

  Verifycodesuccess({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

class Verifycodeerror extends AuthState {
  final String message;

  Verifycodeerror({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}
