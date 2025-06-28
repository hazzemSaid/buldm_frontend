import 'package:buldm/features/auth/domain/entities/userentities.dart';
import 'package:buldm/features/auth/domain/repository/Iauthrepository.dart';

class SignInUserUseCase {
  final authRepositoryInterface repository;

  SignInUserUseCase(this.repository);

  Future<User> call({required String email, required String password}) {
    return repository.signInWithEmailAndPassword(
        email: email, password: password);
  }
}
