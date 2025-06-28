import 'package:buldm/features/auth/data/model/Registerusere_model.dart';
import 'package:buldm/features/auth/data/model/usermodel.dart';
import 'package:either_dart/either.dart';

abstract class authRepositoryInterface {
  Future<UserModel> signInWithEmailAndPassword(
      {required String email, required String password});
  Future<RegisterusereModel> signUpWithEmailAndPassword(
      {required String email, required String password, required String name});
  Future<Either<String, UserModel>> authwithgoogle();
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<void> updateProfile(String name, String photoUrl);
  Future<void> deleteAccount();
  Future<UserModel?> getCurrentUser();
}
