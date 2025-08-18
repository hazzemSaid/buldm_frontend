import 'package:buldm/core/failure/failure.dart';
import 'package:buldm/features/auth/data/model/usermodel.dart';
import 'package:buldm/features/home/data/models/comments.dart';
import 'package:buldm/features/home/data/models/post_model.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';

abstract class RemotePostDataSource {
  Future<Response> createPost(FormData data, String token);
  Future<Either<Failure, void>> updatePost(
      String postId, Map<String, dynamic> data);
  Future<Either<Failure, void>> deletePost(String postId);
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
  Future<Either<Failure, Set<String>>> getLikesByPostId(String postId);
  Future<Either<Failure, List<CommentModel>>> getCommentsByPostId(
      String postId);
  Future<Either<Failure, void>> setLike(String postId, String userId);
  Future<Either<Failure, void>> setComment(String postId, String content);
  Future<Either<Failure, void>> setCommentReply(
      String postId, String parentCommentId, String content);
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
  Future<Either<Failure, void>> deletePost(String postId) async {
    final response = await dio.delete('/post/$postId');
    if (response.statusCode == 200 || response.statusCode == 204) {
      return Right(null);
    }
    return Left(Failure(error: 'Failed to delete post'));
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
  Future<Either<Failure, void>> updatePost(
      String postId, Map<String, dynamic> data) async {
    final response = await dio.put('/post/$postId', data: data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Right(null);
    }
    return Left(Failure(error: 'Failed to update post'));
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

  @override
  Future<Either<Failure, List<CommentModel>>> getCommentsByPostId(
      String postId) async {
    final response = await dio.get('/post/$postId/comment');
    if (response.statusCode == 200) {
      return Right((response.data['data'] as List)
          .map((comment) => CommentModel.fromJson(comment))
          .toList());
    }
    return Left(Failure(error: 'Failed to fetch comments'));
  }

  @override
  Future<Either<Failure, Set<String>>> getLikesByPostId(String postId) async {
    final response = await dio.get('/post/$postId/like');
    if (response.statusCode == 200) {
      return Right(Set<String>.from(response.data['data']['usersIDS']));
    }
    return Left(Failure(error: 'Failed to fetch likes'));
  }

  @override
  Future<Either<Failure, void>> setCommentReply(
      String postId, String parentCommentId, String content) async {
    final response =
        await dio.post('/post/$postId/comment/$parentCommentId', data: {
      'comment': content,
    });
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Right(null);
    }
    return Left(Failure(error: 'Failed to set comment'));
  }

  @override
  Future<Either<Failure, void>> setLike(String postId, String userId) async {
    final response = await dio.post('/post/$postId/like');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Right(null);
    }
    return Left(Failure(error: 'Failed to set like'));
  }

  @override
  Future<Either<Failure, void>> setComment(
      String postId, String content) async {
    final response = await dio.post('/post/$postId/comment', data: {
      'comment': content,
    });
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Right(null);
    }
    return Left(Failure(error: 'Failed to set comment'));
  }
}
