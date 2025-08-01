import 'package:buldm/core/Dependency_njection/service_locator.dart';
import 'package:buldm/features/auth/data/datasource/localdatasource.dart';
import 'package:buldm/features/auth/data/model/usermodel.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_cubit.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_state.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

abstract class ProfileRemoteDataResource {
  Future<Response> updateProfile(
      {required Map<String, dynamic>? profileData,
      required String userId,
      required String token});

  Future<void> deleteProfile();

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

class ProfileRemoteDataResourceImpl implements ProfileRemoteDataResource {
  // Implementation of the methods defined in the interface
  final Dio dio;
  final AuthLocalDataSourceImpl authLocalDataSourceImpl;
  ProfileRemoteDataResourceImpl(
      {required this.dio, required this.authLocalDataSourceImpl});

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
    // If profileData contains an 'avatar' XFile, send as multipart/form-data
    if (profileData != null && profileData['avatar'] is XFile) {
      final avatarFile = profileData['avatar'] as XFile;
      final formData = FormData.fromMap({
        ...profileData..remove('avatar'),
        'avatar': await MultipartFile.fromFile(avatarFile.path),
      });
      final response = await dio.put(
        "/ID/$userId",
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      return response;
    } else {
      final response = await dio.put(
        "/ID/$userId",
        data: profileData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response;
    }
  }

  @override
  Future<Response> searchByName({required String name}) {
    // add token to headers
    final token = (sl<AuthCubit>().state as Authenticated).user.token;
    return dio.get('/user/find/$name',
        options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

  @override
  Future<Response> updateProfileAvatar({
    required String userId,
    required String token,
    required XFile imagePath,
  }) async {
    final response = await dio.put(
      "/user/ID/$userId",
      data: FormData.fromMap({
        'avatar': await MultipartFile.fromFile(imagePath.path),
      }),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    if (response.statusCode == 200) {
      //check if the response is successful
      final user = await authLocalDataSourceImpl.cacheUser(
        UserModel.fromJson(response.data['user']),
      );
    }
    return response;
  }
}
