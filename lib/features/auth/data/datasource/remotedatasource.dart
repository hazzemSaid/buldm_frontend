import 'package:buldm/features/auth/data/model/Registerusere_model.dart';
import 'package:buldm/features/auth/data/model/usermodel.dart';
import 'package:dio/dio.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<RegisterusereModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  });

  Future<void> signOut();

  Future<void> google_auth_service({
    required String idToken,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/user/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(response.data['user']);
      } else {
        throw Exception('Failed to sign in');
      }
    } on DioException catch (e) {
      throw Exception('Sign in error: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<RegisterusereModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await dio.post(
        '/user/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return RegisterusereModel.fromJson(response.data);
      } else {
        throw Exception('Failed to sign up');
      }
    } on DioException catch (e) {
      throw Exception('Sign up error: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<void> signOut() async {
    // أنت ممكن تحذف التوكن من SharedPreferences هنا مثلاً
    return;
  }

  @override
  Future<Response> google_auth_service({
    required String idToken,
  }) {
    final response = dio.post(
      '/user/google_auth',
      data: {'token': idToken},
    );
    return response;
  }
}
