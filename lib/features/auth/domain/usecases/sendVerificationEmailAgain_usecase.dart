import 'package:buldm/core/failure/failure.dart';
import 'package:buldm/features/auth/domain/repository/Iauthrepository.dart';
import 'package:either_dart/either.dart';

class SendVerificationEmailAgainUseCase {
  final authRepositoryInterface repository;

  SendVerificationEmailAgainUseCase({required this.repository});

  Future<Either<Failure, void>> call({required String email}) {
    return repository.sendVerificationEmailAgain(email: email);
  }
}
