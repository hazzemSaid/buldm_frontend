import 'package:dio/dio.dart';

abstract class ProfileRemoteDataResource {
  Future<Response> updateProfile(
      {required Map<String, dynamic>? profileData,
      required String userId,
      required String token});

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

class ProfileRemoteDataResourceImpl implements ProfileRemoteDataResource {
  // Implementation of the methods defined in the interface
  final Dio dio;
  ProfileRemoteDataResourceImpl({required this.dio});

  @override
  Future<void> changePassword(
      {required String oldPassword, required String newPassword}) {
    // TODO: implement changePassword
    throw UnimplementedError();
  }

  @override
  Future<void> deleteProfile() {
    // TODO: implement deleteProfile
    throw UnimplementedError();
  }

  @override
  Future<Response> fetchPost(
      {required String userId, required String token}) async {
    //by using the dio can send request to fetch posts by using user id
    // {{BASE_URL}}/api/v1/post/user/6873f25dafbac6725379bdbd
    final response = await dio.get('/post/user/$userId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ));
    return response;
  }

  @override
  Future<Response> updateProfile(
      {Map<String, dynamic>? profileData,
      required String userId,
      required String token}) async {
    //put ID/:id
    final response = await dio.put("/ID/$userId",
        data: profileData,
        options: Options(headers: {'Authorization': 'Bearer $token'}));
    return response;
  }
}
