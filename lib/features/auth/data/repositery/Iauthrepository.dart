import 'package:buldm/features/auth/data/model/usermodel.dart';
import 'package:either_dart/either.dart';

abstract class IAuth {
  Future<void> signInWithEmailAndPassword(String email, String password);
  Future<void> signUpWithEmailAndPassword(String email, String password);
  Future<Either<String, UserModel>> authwithgoogle();
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<void> updateProfile(String name, String photoUrl);
  Future<void> deleteAccount();
  Future<UserModel?> getCurrentUser();
  Future<String?> gettoken();
  Future<void> saveToken(String token);
  Future<void> deleteToken();
}
