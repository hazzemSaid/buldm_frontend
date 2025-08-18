import 'package:buldm/core/failure/failure.dart';
import 'package:buldm/features/auth/domain/entities/userentities.dart';
import 'package:buldm/features/home/data/datasource/remote_post_data_source.dart';
import 'package:buldm/features/home/data/models/comments.dart';
import 'package:buldm/features/home/data/models/post_model.dart';
import 'package:buldm/features/home/domain/repository/postrepository.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';

class Postrepositoryimp extends Postrepository {
  final RemotePostDataSource remotePostDataSource;
  Postrepositoryimp({required this.remotePostDataSource});
  @override
  Future<Response> createPost(FormData data, String token) {
    return remotePostDataSource.createPost(data, token);
  }

  @override
  Future<Either<Failure, void>> deletePost(String postId) {
    return remotePostDataSource.deletePost(postId);
  }

  @override
  Future<PostModel> getPostById(String postId) {
    return remotePostDataSource.getPostById(postId);
  }

  @override
  Future<List<PostModel>> getPosts(
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
  Future<List<PostModel>> getPostsByCategory(String category) {
    // TODO: implement getPostsByCategory
    throw UnimplementedError();
  }

  @override
  Future<List<PostModel>> getPostsByLocation(
      double latitude, double longitude, double radius) {
    // TODO: implement getPostsByLocation
    throw UnimplementedError();
  }

  @override
  Future<List<PostModel>> getPostsByLocationAndCategory(
      double latitude, double longitude, double radius, String category) {
    // TODO: implement getPostsByLocationAndCategory
    throw UnimplementedError();
  }

  @override
  Future<List<PostModel>> getPostsByPredictedItem(String predictedItem) {
    // TODO: implement getPostsByPredictedItem
    throw UnimplementedError();
  }

  @override
  Future<List<PostModel>> getPostsBySearchQuery(String searchQuery) {
    // TODO: implement getPostsBySearchQuery
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
      String postId, Map<String, dynamic> data) {
    return remotePostDataSource.updatePost(postId, data);
  }

  @override
  Future<User> getUserById(String userId) {
    return remotePostDataSource.getUserById(userId);
  }

  @override
  Future<Either<Failure, Set<String>>> getLikesByPostId(String postId) {
    return remotePostDataSource.getLikesByPostId(postId);
  }

  @override
  Future<Either<Failure, List<CommentModel>>> getCommentsByPostId(
      String postId) {
    return remotePostDataSource.getCommentsByPostId(postId);
  }

  @override
  Future<Either<Failure, void>> setComment(String postId, String content) {
    return remotePostDataSource.setComment(postId, content);
  }

  @override
  Future<Either<Failure, void>> setCommentReply(
      String postId, String parentCommentId, String content) {
    return remotePostDataSource.setCommentReply(
        postId, parentCommentId, content);
  }

  @override
  Future<Either<Failure, void>> setLike(String postId, String userId) {
    return remotePostDataSource.setLike(postId, userId);
  }
}
