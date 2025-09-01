// features/home/data/datasource/remote_post_data_source.dart
import 'package:buldm/core/failure/failure.dart';
import 'package:buldm/features/auth/data/model/usermodel.dart';
import 'package:buldm/features/home/data/models/commentsmodel.dart';
import 'package:buldm/features/home/data/models/post_model.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';

abstract class RemotePostDataSource {
  Future<Either<Failure, void>> createPost(FormData data, String token);
  Future<Either<Failure, PostModel>> updatePost(
      String token, String postId, Map<String, dynamic> data);
  Future<Either<Failure, void>> deletePost(String postId, String token);
  Future<Map<String, PostModel>> getPosts({
    String? category,
    String? status,
    String? userId,
    String? searchQuery,
    int? limit,
    int? page,
    required String token,
  });
  Future<PostModel> getPostById(String postId, String token);
  Future<Map<String, PostModel>> getPostsByUserId(String userId);
  Future<Map<String, PostModel>> getPostsByCategory(String category);
  Future<Map<String, PostModel>> getPostsByStatus(String status);
  Future<Map<String, dynamic>> getPostsByLocation(
    double latitude,
    double longitude,
    double radius,
  );
  Future<UserModel> getUserById(String userId);
  Future<Either<Failure, Set<String>>> getLikesByPostId(String postId);
  Future<Either<Failure, List<CommentModel>>> getCommentsByPostId({
    required String postId,
    required int page,
    required int limit,
  });
  Future<Either<Failure, bool>> setLike(String postId, String userId);
  Future<Either<Failure, CommentModel>> setComment(
      String postId, String content);
  Future<Either<Failure, CommentModel>> setCommentReply(
      String postId, String parentCommentId, String content);
}

class RemotePostDataSourceImpl implements RemotePostDataSource {
  final Dio dio;

  RemotePostDataSourceImpl({required this.dio});

  @override
  Future<Either<Failure, void>> createPost(FormData data, String token) async {
    try {
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
        return Right(null);
      }
      return Left(Failure(error: 'Failed to create post'));
    } on DioException catch (e) {
      return Left(Failure(error: e.message!));
    }
  }

  @override
  Future<Either<Failure, void>> deletePost(String postId, String token) async {
    final response = await dio.delete('/post/$postId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ));
    if (response.statusCode == 200 || response.statusCode == 204) {
      return Right(null);
    }
    return Left(Failure(error: 'Failed to delete post'));
  }

  @override
  Future<PostModel> getPostById(String postId, String token) async {
    try {
      final response = await dio.get(
        '/post/$postId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return PostModel.fromJson(data);
      } else {
        throw Exception('Failed to fetch post');
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
  @override
  Future<Map<String, PostModel>> getPosts({
    String? category,
    String? status,
    String? userId,
    String? searchQuery,
    int? limit,
    int? page,
    required String token,
  }) async {
    try {
      final qp = <String, dynamic>{
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
        if (category != null && category.isNotEmpty) 'category': category,
        if (status != null && status.isNotEmpty) 'status': status,
        if (userId != null && userId.isNotEmpty) 'userId': userId,
        if (searchQuery != null && searchQuery.isNotEmpty)
          'searchQuery': searchQuery,
      };
      final response = await dio.get(
        '/post',
        queryParameters: qp,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        if (data is! List) {
          throw Exception('Malformed response: data is not a list');
        }
        final Map<String, PostModel> byId = <String, PostModel>{};
        for (final item in data) {
          final post = PostModel.fromJson(item);
          byId[post.id] = post;
        }
        return byId;
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
  Future<Map<String, PostModel>> getPostsByCategory(String category) {
    // TODO: implement getPostsByCategory
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getPostsByLocation(
      double latitude, double longitude, double radius) {
    // TODO: implement getPostsByLocation
    throw UnimplementedError();
  }

  @override
  Future<Map<String, PostModel>> getPostsByStatus(String status) {
    // TODO: implement getPostsByStatus
    throw UnimplementedError();
  }

  @override
  Future<Map<String, PostModel>> getPostsByUserId(String userId) {
    // TODO: implement getPostsByUserId
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, PostModel>> updatePost(
    String token,
    String postId,
    Map<String, dynamic> data,
  ) async {
    final response = await dio.put('/post/$postId',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Right(PostModel.fromJson(response.data['data']));
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
  Future<Either<Failure, List<CommentModel>>> getCommentsByPostId({
    required String postId,
    required int page,
    required int limit,
  }) async {
    final response = await dio.get('/post/$postId/comment', queryParameters: {
      'page': page,
      'limit': limit,
    });
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
    } else {
      return Left(Failure(error: 'Failed to fetch likes'));
    }
  }

  @override
  Future<Either<Failure, CommentModel>> setCommentReply(
      String postId, String parentCommentId, String content) async {
    try {
      final response =
          await dio.post('/post/$postId/comment/$parentCommentId', data: {
        'comment': content,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        final String? id = (data['_id'] ?? data['id'])?.toString();
        final String? userId =
            (data['user']?['id'] ?? data['userId'])?.toString();
        final String? parentId = data['parentCommentId']?.toString();
        final createdAtRaw = data['createdAt']?.toString();
        final createdAt =
            createdAtRaw != null ? DateTime.tryParse(createdAtRaw) : null;
        if (id == null || userId == null) {
          return Left(Failure(error: 'Malformed response: missing id/userId'));
        }
        return Right(
          CommentModel(
            comment: content,
            userId: userId,
            postId: postId,
            createdAt: createdAt ?? DateTime.now(),
            id: id,
            parentCommentId: parentId ?? parentCommentId,
          ),
        );
      } else {
        return Left(Failure(error: 'Failed to set comment'));
      }
    } catch (e) {
      return Left(Failure(error: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> setLike(String postId, String userId) async {
    final response = await dio.post('/post/$postId/like');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Right(response.data['data']['isliked']);
    } else {
      return Left(Failure(error: 'Failed to set like'));
    }
  }

  @override
  Future<Either<Failure, CommentModel>> setComment(
      String postId, String content) async {
    try {
      final response = await dio.post('/post/$postId/comment', data: {
        'comment': content,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        final String? id = (data['_id'] ?? data['id'])?.toString();
        final String? userId =
            (data['user']?['id'] ?? data['userId'])?.toString();
        final String? parentId = data['parentCommentId']?.toString();
        final createdAtRaw = data['createdAt']?.toString();
        final createdAt =
            createdAtRaw != null ? DateTime.tryParse(createdAtRaw) : null;
        if (id == null || userId == null) {
          return Left(Failure(error: 'Malformed response: missing id/userId'));
        }
        return Right(
          CommentModel(
            comment: content,
            userId: userId,
            postId: postId,
            createdAt: createdAt ?? DateTime.now(),
            id: id,
            parentCommentId: parentId,
          ),
        );
      } else {
        return Left(Failure(error: 'Failed to set comment'));
      }
    } catch (e) {
      return Left(Failure(error: e.toString()));
    }
  }
}
