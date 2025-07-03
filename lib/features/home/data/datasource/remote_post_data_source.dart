import 'package:buldm/features/auth/data/model/usermodel.dart';
import 'package:buldm/features/home/data/models/post_model.dart';
import 'package:dio/dio.dart';

abstract class RemotePostDataSource {
  Future<Response> createPost(FormData data, String token);
  Future<void> updatePost(String postId, Map<String, dynamic> data);
  Future<void> deletePost(String postId);
  Future<List<PostModel>> getPosts({
    String? category,
    String? status,
    String? userId,
    String? searchQuery,
    int? limit,
    int? page,
    required String token,
  });
  Future<PostModel> getPostById(String postId);
  Future<List<PostModel>> getPostsByUserId(String userId);
  Future<List<PostModel>> getPostsByCategory(String category);
  Future<List<PostModel>> getPostsByStatus(String status);
  Future<List<Map<String, dynamic>>> getPostsByLocation(
    double latitude,
    double longitude,
    double radius,
  );
  Future<UserModel> getUserById(String userId);
}

class RemotePostDataSourceImpl implements RemotePostDataSource {
  final Dio dio;

  RemotePostDataSourceImpl({required this.dio});

  @override
  Future<Response> createPost(FormData data, String token) async {
    // Convert List<MapEntry<String, String>> to Map<String, dynamic>

    print('Posting to: ${dio.options.baseUrl}/post');

    final response = await dio.post(
      '/post',
      data: data,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response;
    }
    throw Exception('Failed to create post: ${response.data['message']}');
  }

  @override
  Future<void> deletePost(String postId) {
    // TODO: implement deletePost
    throw UnimplementedError();
  }

  @override
  Future<PostModel> getPostById(String postId) {
    // TODO: implement getPostById
    throw UnimplementedError();
  }

  @override
  @override
  Future<List<PostModel>> getPosts({
    String? category,
    String? status,
    String? userId,
    String? searchQuery,
    int? limit,
    int? page,
    required String token,
  }) async {
    try {
      final response = await dio.get(
        '/post?page=$page&limit=$limit&category=$category&status=$status&userId=$userId&searchQuery=$searchQuery',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Response Data: ${response.data['data']}");
        return (response.data['data'] as List)
            .map((post) => PostModel.fromJson(post))
            .toList();
      } else {
        throw Exception('Failed to fetch posts');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? e.message);
      } else {
        throw Exception(e.message);
      }
    }
  }

  @override
  Future<List<PostModel>> getPostsByCategory(String category) {
    // TODO: implement getPostsByCategory
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> getPostsByLocation(
      double latitude, double longitude, double radius) {
    // TODO: implement getPostsByLocation
    throw UnimplementedError();
  }

  @override
  Future<List<PostModel>> getPostsByStatus(String status) {
    // TODO: implement getPostsByStatus
    throw UnimplementedError();
  }

  @override
  Future<List<PostModel>> getPostsByUserId(String userId) {
    // TODO: implement getPostsByUserId
    throw UnimplementedError();
  }

  @override
  Future<void> updatePost(String postId, Map<String, dynamic> data) {
    // TODO: implement updatePost
    throw UnimplementedError();
  }

  @override
  Future<UserModel> getUserById(String userId) async {
    // /user/6819ecfe592604de47d2a499
    try {
      final response = await dio.get(
        '/user/ID/$userId',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(response.data['user']);
      } else {
        throw Exception('Failed to fetch user');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? e.message);
      } else {
        throw Exception(e.message);
      }
    }
  }
}
