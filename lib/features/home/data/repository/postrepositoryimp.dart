// features/home/data/repository/postrepositoryimp.dart
import 'package:buldm/core/failure/failure.dart';
import 'package:buldm/features/auth/domain/entities/userentities.dart';
import 'package:buldm/features/home/data/datasource/remote_post_data_source.dart';
import 'package:buldm/features/home/data/models/commentsmodel.dart';
import 'package:buldm/features/home/data/models/post_model.dart';
import 'package:buldm/features/home/domain/repository/postrepository.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';

class Postrepositoryimp extends Postrepository {
  final RemotePostDataSource remotePostDataSource;
  Postrepositoryimp({required this.remotePostDataSource});
  @override
  Future<Either<Failure, void>> createPost(FormData data, String token) {
    return remotePostDataSource.createPost(data, token);
  }

  @override
  Future<Either<Failure, void>> deletePost(String postId, String token) {
    return remotePostDataSource.deletePost(postId, token);
  }

  @override
  Future<PostModel> getPostById(String postId, String token) {
    return remotePostDataSource.getPostById(postId, token);
  }

  @override
  Future<Map<String, PostModel>> getPosts(
      {String? category,
      String? status,
      String? userId,
      String? searchQuery,
      int? limit,
      int? page,
      required token}) {
    return remotePostDataSource.getPosts(
      category: category,
      status: status,
      userId: userId,
      searchQuery: searchQuery,
      limit: limit,
      page: page,
      token: token,
    );
  }

  @override
  Future<Map<String, PostModel>> getPostsByCategory(String category) {
    // TODO: implement getPostsByCategory
    throw UnimplementedError();
  }

  @override
  Future<Map<String, PostModel>> getPostsByLocation(
      double latitude, double longitude, double radius) {
    // TODO: implement getPostsByLocation
    throw UnimplementedError();
  }

  @override
  Future<Map<String, PostModel>> getPostsByLocationAndCategory(
      double latitude, double longitude, double radius, String category) {
    // TODO: implement getPostsByLocationAndCategory
    throw UnimplementedError();
  }

  @override
  Future<Map<String, PostModel>> getPostsByPredictedItem(String predictedItem) {
    // TODO: implement getPostsByPredictedItem
    throw UnimplementedError();
  }

  @override
  Future<Map<String, PostModel>> getPostsBySearchQuery(String searchQuery) {
    // TODO: implement getPostsBySearchQuery
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
  ) {
    return remotePostDataSource.updatePost(token, postId, data);
  }

  @override
  Future<User> getUserById(String userId) {
    return remotePostDataSource.getUserById(userId);
  }

  @override
  Future<Either<Failure, Set<String>>> getLikesByPostId(
      {required String postId, int limit = 10, int page = 1}) {
    return remotePostDataSource.getLikesByPostId(
        postId: postId, limit: limit, page: page);
  }

  @override
  Future<Either<Failure, List<CommentModel>>> getCommentsByPostId({
    required String postId,
    required int page,
    required int limit,
  }) {
    return remotePostDataSource.getCommentsByPostId(
      postId: postId,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<Either<Failure, CommentModel>> setComment(
      String postId, String content) {
    return remotePostDataSource.setComment(postId, content);
  }

  @override
  Future<Either<Failure, CommentModel>> setCommentReply(
      String postId, String parentCommentId, String content) {
    return remotePostDataSource.setCommentReply(
        postId, parentCommentId, content);
  }

  @override
  Future<Either<Failure, bool>> setLike(String postId, String userId) {
    return remotePostDataSource.setLike(postId, userId);
  }
}
