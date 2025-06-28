import 'package:buldm/features/auth/data/model/usermodel.dart';
import 'package:hive/hive.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> removeUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final Box<UserModel> userBox;

  AuthLocalDataSourceImpl(this.userBox);

  static const String userKey = 'user';

  @override
  Future<void> cacheUser(UserModel user) async {
    await userBox.put(userKey, user);
  }

  @override
  Future<UserModel?> getCachedUser() async {
    return userBox.get(userKey);
  }

  @override
  Future<void> removeUser() async {
    await userBox.delete(userKey);
  }
}
