import 'package:buldm/features/auth/data/datasource/localdatasource.dart';
import 'package:buldm/features/auth/data/datasource/remotedatasource.dart';
import 'package:buldm/features/auth/data/model/Registerusere_model.dart';
import 'package:buldm/features/auth/data/model/usermodel.dart';
import 'package:buldm/features/auth/data/services/google_auth.dart';
import 'package:buldm/features/auth/domain/repository/Iauthrepository.dart';
import 'package:either_dart/either.dart';
import 'package:either_dart/src/either.dart';
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
      final response = await remoteDataSourceImpl.google_auth_service(
        idToken: idToken,
      );
      if (response.statusCode != 200) {
        return Left(
          'Failed to authenticate with Google sign-in: ${response.statusCode}',
        );
      }
      // if success then we can parse the response to the user model
      final userModel = UserModel.fromJson(response.data['user']);
      // cache the user in the local data source
      await localDataSourceImpl.cacheUser(userModel);
      return Right(userModel);
    } on Exception catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<void> deleteAccount() {
    // TODO: implement deleteAccount
    throw UnimplementedError();
  }

  @override
  Future<void> resetPassword(String email) {
    // TODO: implement resetPassword
    throw UnimplementedError();
  }

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    var response = remoteDataSourceImpl.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Cache the user in the local data source
    response = response.then((user) async {
      await localDataSourceImpl.cacheUser(user);
      return user;
    });
    return response;
  }

  @override
  Future<void> signOut() {
    return localDataSourceImpl.removeUser();
  }

  @override
  Future<RegisterusereModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) {
    return remoteDataSourceImpl.signUpWithEmailAndPassword(
      email: email,
      password: password,
      name: name,
    );
  }

  @override
  Future<void> updateProfile(String name, String photoUrl) {
    // TODO: implement updateProfile
    throw UnimplementedError();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final userBox = Hive.box<UserModel>('user');
    if (userBox.isEmpty) {
      return null; // No user is currently signed in
    }
    return userBox.get('user'); // Retrieve the current user
  }
}
