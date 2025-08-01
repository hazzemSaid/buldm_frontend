import 'package:buldm/core/failure/failure.dart';
import 'package:buldm/features/auth/data/model/Registerusere_model.dart';
import 'package:buldm/features/auth/data/model/usermodel.dart';
import 'package:either_dart/either.dart';

abstract class authRepositoryInterface {
  Future<Either<Failure, UserModel>> signInWithEmailAndPassword(
      {required String email, required String password});
  Future<Either<Failure, RegisterUserModel>> signUpWithEmailAndPassword(
      {required String email, required String password, required String name});
  Future<Either<String, UserModel>> authwithgoogle();
  Future<void> signOut();
  Future<Either<Failure, void>> forgotPassword({required String email});
  Future<Either<Failure, void>> verifyCode(
      {required String email, required String code});
  Future<Either<Failure, void>> resetpassword({
    required String email,
    required String newPassword,
  });

  Future<Either<Failure, void>> deleteAccount();
  Future<UserModel?> getCurrentUser();

  Future<Either<Failure, UserModel>> verifyEmailCode(
      {required String code, required String email});

  Future<Either<Failure, void>> sendVerificationEmailAgain(
      {required String email});
}
