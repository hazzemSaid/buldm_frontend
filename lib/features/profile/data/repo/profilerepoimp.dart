import 'package:buldm/features/profile/data/datasource/profile_remote_data_resource.dart';
import 'package:buldm/features/profile/domain/repo/ProfileRepository.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class Profilerepoimp extends ProfileRepository {
  final ProfileRemoteDataResourceImpl profileRemoteDataResource;

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

  @override
  Future<Response> searchByName({
    required String name,
  }) {
    return profileRemoteDataResource.searchByName(name: name);
  }

  @override
  Future<Response> updateProfileAvatar({
    required String userId,
    required String token,
    required XFile imagePath,
  }) {
    return profileRemoteDataResource.updateProfileAvatar(
      userId: userId,
      token: token,
      imagePath: imagePath, // Pass the XFile object
    );
  }
}
