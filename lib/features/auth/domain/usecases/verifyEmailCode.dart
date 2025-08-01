import 'package:buldm/core/failure/failure.dart';
import 'package:buldm/features/auth/data/model/usermodel.dart';
import 'package:buldm/features/auth/domain/repository/Iauthrepository.dart';
import 'package:either_dart/either.dart';

class VerifyEmailCode {
  final authRepositoryInterface authRepository;
  VerifyEmailCode({required this.authRepository});

  Future<Either<Failure, UserModel>> call(String code, String email) async {
    // Implement the email verification logic using the authRepository
    return await authRepository.verifyEmailCode(code: code, email: email);
  }
}
