import 'package:buldm/features/auth/domain/repository/Iauthrepository.dart';

class SignOutUseCase {
  final authRepositoryInterface authRepository;

  SignOutUseCase({required this.authRepository});

  Future<void> signOut() async {
    try {
      await authRepository.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }
}
