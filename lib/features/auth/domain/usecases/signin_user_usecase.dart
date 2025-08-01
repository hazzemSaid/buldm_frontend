import 'package:buldm/core/failure/failure.dart';
import 'package:buldm/features/auth/data/model/usermodel.dart';
import 'package:buldm/features/auth/domain/repository/Iauthrepository.dart';
import 'package:either_dart/either.dart';

class SignInUserUseCase {
  final authRepositoryInterface repository;

  SignInUserUseCase({required this.repository});

  Future<Either<Failure, UserModel>> call(
      {required String email, required String password}) {
    return repository.signInWithEmailAndPassword(
        email: email, password: password);
  }
}
