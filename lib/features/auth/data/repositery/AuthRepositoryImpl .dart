import 'package:buldm/features/auth/data/db/authdb.dart';
import 'package:buldm/features/auth/data/model/usermodel.dart';
import 'package:buldm/features/auth/data/repositery/Iauthrepository.dart';
import 'package:buldm/features/auth/data/services/google_auth.dart';
import 'package:either_dart/src/either.dart';
// Add this import
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

// Create a single instance (preferably as a field in your repository or cubit)

class Authrepositoryimpl implements IAuth {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

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
      final Authdb authdb = Authdb();
      final response = await authdb.sendTokenToBackend(idToken);
      // check if the response is a success or failure
      if (response.statusCode != 200) {
        return Left(
          'Failed to authenticate with Google sign-in: ${response.statusCode}',
        );
      }
      // if success then we can parse the response to the user model
      final userModel = UserModel.fromJson(response.data['user']);
      final token = response.data['user']['token'];
      // save the token to secure storage
      saveToken(token);
      // and return the user model
      return Right(userModel);
    } on Exception catch (e) {
      // if there is an error then we can return the error
      return Left(e.toString());
    }
    // this is the flow of the google auth service

    // second send the request to the backend
    //third fetch for the respone -> either 1 - fauiler , usermodel
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
  Future<void> signInWithEmailAndPassword(String email, String password) {
    // TODO: implement signInWithEmailAndPassword
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() {
    // TODO: implement signOut
    throw UnimplementedError();
  }

  @override
  Future<void> signUpWithEmailAndPassword(String email, String password) {
    // TODO: implement signUpWithEmailAndPassword
    throw UnimplementedError();
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

  @override
  static Future<void> setCurrentUser(UserModel user) async {
    await Hive.box('user').put('user', user);
  }

  @override
  Future<void> deleteToken() async {
    await secureStorage.delete(key: 'auth_token');
  }

  @override
  Future<String?> gettoken() async {
    return await secureStorage.read(key: 'auth_token');
  }

  @override
  Future<void> saveToken(String token) async {
    await secureStorage.write(key: 'auth_token', value: token);
  }
}
