import 'package:buldm/core/failure/failure.dart';
import 'package:buldm/features/auth/data/repositery/AuthRepositoryImpl.dart';
import 'package:either_dart/either.dart';

class ForgotPasswordUseCase {
  final AuthRepositoryImpl repository;

  ForgotPasswordUseCase({required this.repository});

  Future<Either<Failure, void>> call({required String email}) {
    return repository.forgotPassword(email: email);
  }
}
