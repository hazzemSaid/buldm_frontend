import 'package:buldm/core/failure/failure.dart';
import 'package:buldm/features/auth/domain/entities/userentities.dart';
import 'package:buldm/features/home/data/models/comments.dart';
import 'package:buldm/features/home/data/models/post_model.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';

abstract class Postrepository {
  Future<List<PostModel>> getPosts({
    String? category,
    String? status,
    String? userId,
    String? searchQuery,
    int? limit,
    int? page,
    required token,
  });
  Future<PostModel> getPostById(String postId);
  Future<List<PostModel>> getPostsByUserId(String userId);
  Future<List<PostModel>> getPostsByCategory(String category);
  Future<List<PostModel>> getPostsByStatus(String status);
  Future<List<PostModel>> getPostsByLocation(
    double latitude,
    double longitude,
    double radius,
  );
  Future<Response> createPost(FormData data, String token);
  Future<Either<Failure, void>> updatePost(
      String postId, Map<String, dynamic> data);
  Future<Either<Failure, void>> deletePost(String postId);
  Future<List<PostModel>> getPostsBySearchQuery(String searchQuery);
  Future<List<PostModel>> getPostsByPredictedItem(String predictedItem);
  Future<List<PostModel>> getPostsByLocationAndCategory(
    double latitude,
    double longitude,
    double radius,
    String category,
  );
  Future<User> getUserById(String userId);
  Future<Either<Failure, Set<String>>> getLikesByPostId(String postId);
  Future<Either<Failure, List<CommentModel>>> getCommentsByPostId(
      String postId);
  Future<Either<Failure, void>> setLike(String postId, String userId);
  Future<Either<Failure, void>> setComment(String postId, String content);
  Future<Either<Failure, void>> setCommentReply(
      String postId, String parentCommentId, String content);
}
