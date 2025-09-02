// features/home/domain/repository/postrepository.dart
import 'package:buldm/core/failure/failure.dart';
import 'package:buldm/features/auth/domain/entities/userentities.dart';
import 'package:buldm/features/home/data/models/commentsmodel.dart';
import 'package:buldm/features/home/data/models/post_model.dart';
import 'package:buldm/features/home/persentation/bloc/post/post_bloc.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';

abstract class Postrepository {
  Future<Map<String, PostModel>> getPosts({
    String? category,
    String? status,
    String? userId,
    String? searchQuery,
    int? limit,
    int? page,
    required token,
  });
  Future<PostModel> getPostById(String postId, String token);
  Future<Map<String, PostModel>> getPostsByUserId(String userId);
  Future<Map<String, PostModel>> getPostsByCategory(String category);
  Future<Map<String, PostModel>> getPostsByStatus(String status);
  Future<Map<String, PostModel>> getPostsByLocation(
    double latitude,
    double longitude,
    double radius,
  );
  Future<Either<Failure, void>> createPost(FormData data, String token);
  Future<Either<Failure, PostModel>> updatePost(
    String token,
    String postId,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, void>> deletePost(String postId, String token);

  Future<Map<String, PostModel>> getPostsBySearchQuery(String searchQuery);
  Future<Map<String, PostModel>> getPostsByPredictedItem(String predictedItem);
  Future<Map<String, PostModel>> getPostsByLocationAndCategory(
    double latitude,
    double longitude,
    double radius,
    String category,
  );
  Future<User> getUserById(String userId);
  Future<Either<Failure, Set<String>>> getLikesByPostId(
      {required String postId, int limit = 10, int page = 1});
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
