import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

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
  Future<Response> searchByName({
    required String name,
  });

  Future<Response> updateProfileAvatar({
    required String userId,
    required String token,
    required XFile imagePath,
  });
}
