import 'package:dio/dio.dart';

abstract class ProfileRepository {
  Future<Response> updateProfile({
    required Map<String, dynamic>? profileData,
    required String userId,
    required String token,
  });

  Future<void> deleteProfile();

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  Future<Response> fetchPost({
    required String token,
    required String userId,
  });
}
