import 'package:buldm/core/failure/failure.dart';
import 'package:buldm/features/auth/data/repositery/AuthRepositoryImpl.dart';
import 'package:either_dart/either.dart';

class ResetPassword {
  final AuthRepositoryImpl repository;

  ResetPassword({required this.repository});

  Future<Either<Failure, void>> call(
      {required String email, required String newPassword}) {
    return repository.resetpassword(
      email: email,
      newPassword: newPassword,
    );
  }
}
