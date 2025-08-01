import 'package:buldm/core/failure/failure.dart';
import 'package:buldm/features/auth/data/datasource/localdatasource.dart';
import 'package:buldm/features/auth/data/datasource/remotedatasource.dart';
import 'package:buldm/features/auth/data/model/Registerusere_model.dart';
import 'package:buldm/features/auth/data/model/usermodel.dart';
import 'package:buldm/features/auth/data/services/google_auth.dart';
import 'package:buldm/features/auth/domain/repository/Iauthrepository.dart';
import 'package:either_dart/either.dart';
import 'package:hive/hive.dart';

class AuthRepositoryImpl implements authRepositoryInterface {
  final AuthRemoteDataSourceImpl remoteDataSourceImpl;
  final AuthLocalDataSourceImpl localDataSourceImpl;
  AuthRepositoryImpl({
    required this.remoteDataSourceImpl,
    required this.localDataSourceImpl,
  });

  @override
  Future<Either<String, UserModel>> authwithgoogle() async {
    // first make the google sign in

    final GoogleAuth googleAuth = GoogleAuth();
    final Either<Exception, String> result =
        await googleAuth.googleauth_service();
    // check if the result is a failure or success
    if (result.isLeft) {
      return Left(result.left.toString());
    }
    // if success then we can send the token to the backend
    final String idToken = result.right;
    // now we can send the token to the backend
    try {
      final response = await remoteDataSourceImpl.googleAuthService(
        idToken: idToken,
      );
      if (response.isLeft) {
        return Left(
          'Failed to authenticate with Google sign-in: ${response.left}',
        );
      }
      // if success then we can parse the response to the user model
      // Assuming the remoteDataSourceImpl returns the user data on success
      final userModel = response.right;
      // cache the user in the local data source
      await localDataSourceImpl.cacheUser(userModel);
      return Right(userModel);
    } on Exception catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() {
    // TODO: implement deleteAccount
    throw UnimplementedError();
  }

  @override
  @override
  Future<Either<Failure, UserModel>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final user = await remoteDataSourceImpl.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return await user.fold(
      (failure) async => Left(failure),
      (userModel) async {
        await localDataSourceImpl.cacheUser(userModel);
        return Right(userModel);
      },
    );
  }

  @override
  Future<void> signOut() {
    return localDataSourceImpl.removeUser();
  }

  @override
  Future<Either<Failure, RegisterUserModel>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    final result = await remoteDataSourceImpl.signUpWithEmailAndPassword(
      email: email,
      password: password,
      name: name,
    );
    return result.fold(
      (failure) => Left(failure),
      (registerusermodel) async {
        return Right(registerusermodel);
      },
    );
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final userBox = Hive.box<UserModel>('user');
    if (userBox.isEmpty) {
      return null; // No user is currently signed in
    }
    return userBox.get('user'); // Retrieve the current user
  }

  @override
  Future<Either<Failure, UserModel>> verifyEmailCode(
      {required String code, required String email}) async {
    final userModel = await remoteDataSourceImpl.verifyEmailCode(
      code: code,
      email: email,
    );

    return userModel.fold(
      (failure) => Left(failure),
      (user) async {
        await localDataSourceImpl.cacheUser(user);
        return Right(user);
      },
    );
  }

  @override
  Future<Either<Failure, void>> sendVerificationEmailAgain(
      {required String email}) async {
    final response =
        await remoteDataSourceImpl.sendVerificationEmailAgain(email: email);
    return response.fold(
      (failure) => Left(failure),
      (success) => Right(success),
    );
  }

  @override
  Future<Either<Failure, void>> forgotPassword({required String email}) async {
    final response = await remoteDataSourceImpl.forgotPassword(email: email);
    return response.fold(
      (failure) => Left(failure),
      (success) => Right(success),
    );
  }

  @override
  Future<Either<Failure, void>> verifyCode(
      {required String email, required String code}) async {
    final response = await remoteDataSourceImpl.verifyCode(
      email: email,
      code: code,
    );
    return response.fold(
      (failure) => Left(failure),
      (success) => Right(success),
    );
  }

  @override
  Future<Either<Failure, void>> resetpassword(
      {required String email, required String newPassword}) {
    final response = remoteDataSourceImpl.resetPassword(
      email: email,
      newPassword: newPassword,
    );
    return response.fold(
      (failure) => Left(failure),
      (success) => Right(success),
    );
  }
}
