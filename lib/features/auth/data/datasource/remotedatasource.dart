import 'package:buldm/features/auth/data/model/Registerusere_model.dart';
import 'package:buldm/features/auth/data/model/usermodel.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';

import '../../../../core/failure/failure.dart';

abstract class AuthRemoteDataSource {
  Future<Either<Failure, UserModel>> verifyEmailCode({
    required String code,
    required String email,
  });
  Future<Either<Failure, UserModel>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, RegisterUserModel>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  });

  Future<void> signOut();

  Future<Either<Failure, UserModel>> googleAuthService({
    required String idToken,
  });
  Future<Either<Failure, void>> sendVerificationEmailAgain({
    required String email,
  });
  Future<Either<Failure, void>> forgotPassword({required String email});
  Future<Either<Failure, void>> verifyCode(
      {required String email, required String code});
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String newPassword,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<Either<Failure, UserModel>> signInWithEmailAndPassword({
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
        return Right(UserModel.fromJson(response.data['user']));
      } else if (response.statusCode == 422) {
        return Left(
            Failure(error: response.data['error'] ?? 'Password is incorrect'));
      } else {
        return Left(
            Failure(error: response.data['error'] ?? 'Failed to sign in'));
      }
    } on DioException catch (e) {
      String errorMsg = 'Failed to sign in';
      if (e.response != null && e.response?.data != null) {
        errorMsg = e.response?.data['error']?.toString() ?? errorMsg;
      }
      return Left(Failure(error: errorMsg));
    } catch (e) {
      return Left(Failure(error: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RegisterUserModel>> signUpWithEmailAndPassword({
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
        return Right(RegisterUserModel.fromJson(response.data));
      } else {
        return Left(
            Failure(error: response.data['error'] ?? 'Failed to sign up'));
      }
    } on DioException catch (e) {
      String errorMsg = 'Failed to sign up';
      if (e.response != null && e.response?.data != null) {
        errorMsg = e.response?.data['error']?.toString() ?? errorMsg;
      }
      return Left(Failure(error: errorMsg));
    } catch (e) {
      return Left(Failure(error: e.toString()));
    }
  }

  @override
  Future<void> signOut() async {
    return;
  }

  @override
  Future<Either<Failure, UserModel>> googleAuthService({
    required String idToken,
  }) async {
    try {
      final response = await dio.post(
        '/user/google_auth',
        data: {'token': idToken},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(UserModel.fromJson(response.data['user']));
      } else {
        return Left(
            Failure(error: response.data['error'] ?? 'Failed to sign in'));
      }
    } on DioException catch (e) {
      String errorMsg = 'Failed to sign in with Google';
      if (e.response != null && e.response?.data != null) {
        errorMsg = e.response?.data['error']?.toString() ?? errorMsg;
      }
      return Left(Failure(error: errorMsg));
    } catch (e) {
      return Left(Failure(error: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> verifyEmailCode(
      {required String code, required String email}) async {
    try {
      final response = await dio.post(
        '/user/verifyemail',
        data: {
          'code': code,
          'email': email,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(UserModel.fromJson(response.data['user']));
      } else {
        return Left(
            Failure(error: response.data['error'] ?? 'Failed to verify email'));
      }
    } on DioException catch (e) {
      String errorMsg = 'Failed to verify email';
      if (e.response != null && e.response?.data != null) {
        errorMsg = e.response?.data['error']?.toString() ?? errorMsg;
      }
      return Left(Failure(error: errorMsg));
    } catch (e) {
      return Left(Failure(error: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendVerificationEmailAgain(
      {required String email}) async {
    try {
      final response = await dio.post(
        '/user/resendverificationcode',
        data: {'email': email},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(null);
      } else {
        return Left(Failure(
            error: response.data['error'] ??
                'Failed to resend verification email'));
      }
    } on DioException catch (e) {
      String errorMsg = 'Failed to resend verification email';
      if (e.response != null && e.response?.data != null) {
        errorMsg = e.response?.data['error']?.toString() ?? errorMsg;
      }
      return Left(Failure(error: errorMsg));
    } catch (e) {
      return Left(Failure(error: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword({required String email}) async {
    try {
      final response = await dio.post(
        '/user/forgotpassword',
        data: {'email': email},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(null);
      } else {
        return Left(
            Failure(error: response.data['error'] ?? 'Failed to send email'));
      }
    } on DioException catch (e) {
      String errorMsg = 'Failed to send forgot password email';
      if (e.response != null && e.response?.data != null) {
        errorMsg = e.response?.data['error']?.toString() ?? errorMsg;
      }
      return Left(Failure(error: errorMsg));
    } catch (e) {
      return Left(Failure(error: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(
      {required String email, required String newPassword}) async {
    try {
      final response = await dio.post(
        '/user/resetpassword',
        data: {
          'email': email,
          'password': newPassword,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(null);
      } else {
        return Left(Failure(
            error: response.data['error'] ?? 'Failed to reset password'));
      }
    } on DioException catch (e) {
      String errorMsg = 'Failed to reset password';
      if (e.response != null && e.response?.data != null) {
        errorMsg = e.response?.data['error']?.toString() ?? errorMsg;
      }
      return Left(Failure(error: errorMsg));
    } catch (e) {
      return Left(Failure(error: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyCode(
      {required String email, required String code}) async {
    try {
      final response = await dio.post(
        '/user/verifycode',
        data: {
          'email': email,
          'code': code,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(null);
      } else {
        return Left(
            Failure(error: response.data['error'] ?? 'Failed to verify code'));
      }
    } on DioException catch (e) {
      String errorMsg = 'Failed to verify code';
      if (e.response != null && e.response?.data != null) {
        errorMsg = e.response?.data['error']?.toString() ?? errorMsg;
      } else if (e.type == DioExceptionType.badResponse &&
          e.response?.statusCode == 401) {
        errorMsg = 'Unauthorized: Invalid email or code';
      }
      return Left(Failure(error: errorMsg));
    } catch (e) {
      return Left(Failure(error: e.toString()));
    }
  }
}
