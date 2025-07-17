import 'package:buldm/features/auth/data/model/usermodel.dart';
import 'package:buldm/features/auth/domain/repository/Iauthrepository.dart';

class SignInUserUseCase {
  final authRepositoryInterface repository;

  SignInUserUseCase({required this.repository});

  Future<UserModel> call({required String email, required String password}) {
    return repository.signInWithEmailAndPassword(
        email: email, password: password);
  }
}
