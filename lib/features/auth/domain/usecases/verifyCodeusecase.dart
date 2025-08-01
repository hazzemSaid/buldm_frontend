import 'package:buldm/core/failure/failure.dart';
import 'package:buldm/features/auth/data/repositery/AuthRepositoryImpl.dart';
import 'package:either_dart/either.dart';

class VerifyCode {
  final AuthRepositoryImpl repository;

  VerifyCode({required this.repository});

  Future<Either<Failure, void>> call(
      {required String email, required String code}) {
    return repository.verifyCode(
      email: email,
      code: code,
    );
  }
}
