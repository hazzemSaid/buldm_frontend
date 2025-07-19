import 'package:buldm/features/auth/data/model/usermodel.dart';
import 'package:buldm/features/auth/domain/repository/Iauthrepository.dart';

class VerifyEmailCode {
  final authRepositoryInterface authRepository;
  VerifyEmailCode({required this.authRepository});

  Future<UserModel> call(String code, String email) async {
    // Implement the email verification logic using the authRepository
    return await authRepository.verifyEmailCode(code: code, email: email);
  }
}
