import 'package:buldm/features/auth/data/model/usermodel.dart';
import 'package:buldm/features/auth/domain/repository/Iauthrepository.dart';

class GetCurrentuserUsercase {
  final authRepositoryInterface authRepository;

  GetCurrentuserUsercase({required this.authRepository});

  Future<UserModel?> call() async {
    return await authRepository.getCurrentUser();
  }
}
