import 'package:buldm/features/auth/data/model/usermodel.dart';
import 'package:buldm/features/auth/domain/repository/Iauthrepository.dart';
import 'package:either_dart/either.dart';

class GoogleAuthUsecase {
  final authRepositoryInterface authRepository;

  GoogleAuthUsecase({required this.authRepository});

  Future<Either<String, UserModel>> signInWithGoogle() async {
    return await authRepository.authwithgoogle();
  }
}
