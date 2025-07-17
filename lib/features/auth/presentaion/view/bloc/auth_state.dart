import 'package:buldm/features/auth/data/model/usermodel.dart';
import 'package:buldm/features/auth/domain/entities/registeruserentities.dart';
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {}

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
