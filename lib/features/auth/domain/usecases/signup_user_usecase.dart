import 'package:buldm/features/auth/data/model/Registerusere_model.dart';
import 'package:buldm/features/auth/domain/repository/Iauthrepository.dart';

class SignUpUserUseCase {
  final authRepositoryInterface repository;

  SignUpUserUseCase({required this.repository});

  Future<RegisterusereModel> call(
      {required String email, required String password, required String name}) {
    return repository.signUpWithEmailAndPassword(
        email: email, password: password, name: name);
  }
}
