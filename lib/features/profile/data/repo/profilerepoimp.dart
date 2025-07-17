import 'package:buldm/features/profile/data/datasource/profile_remote_data_resource.dart';
import 'package:buldm/features/profile/domain/repo/ProfileRepository.dart';
import 'package:dio/dio.dart';

class Profilerepoimp extends ProfileRepository {
  final ProfileRemoteDataResource profileRemoteDataResource;

  Profilerepoimp({required this.profileRemoteDataResource});

  @override
  Future<Response> updateProfile({
    required Map<String, dynamic>? profileData,
    required String userId,
    required String token,
  }) {
    return profileRemoteDataResource.updateProfile(
      profileData: profileData,
      userId: userId,
      token: token,
    );
  }

  @override
  Future<void> deleteProfile() {
    // Implement delete profile logic here
    throw UnimplementedError();
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) {
    // Implement change password logic here
    throw UnimplementedError();
  }

  @override
  Future<Response> fetchPost({
    required String token,
    required String userId,
  }) {
    return profileRemoteDataResource.fetchPost(token: token, userId: userId);
  }
}
