import 'package:buldm/features/home/data/models/post_model.dart';
import 'package:dio/dio.dart';

abstract class RemotePostDataSource {
  Future<void> createPost(Map<String, dynamic> data);
  Future<void> updatePost(String postId, Map<String, dynamic> data);
  Future<void> deletePost(String postId);
  Future<List<PostModel>> getPosts({
    String? category,
    String? status,
    String? userId,
    String? searchQuery,
    int? limit,
    int? offset,
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
}

class RemotePostDataSourceImpl implements RemotePostDataSource {
  final Dio dio;
  static const String _baseUrl = 'http://10.0.2.2:3000';

  RemotePostDataSourceImpl({required this.dio});

  @override
  Future<void> createPost(Map<String, dynamic> data) {
    // TODO: implement createPost
    throw UnimplementedError();
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
    int? offset,
    required String token,
  }) async {
    try {
      final response = await dio.post(
        '$_baseUrl/api/v1/post',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return (response.data['posts'] as List)
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
}
