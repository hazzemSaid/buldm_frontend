import 'package:buldm/features/home/data/datasource/remote_post_data_source.dart';
import 'package:buldm/features/home/domain/entities/postentity.dart';
import 'package:buldm/features/home/domain/repository/postrepository.dart';

class Postrepositoryimp extends Postrepository {
  final RemotePostDataSource remotePostDataSource;
  Postrepositoryimp({required this.remotePostDataSource});
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
  Future<PostEntity> getPostById(String postId) {
    // TODO: implement getPostById
    throw UnimplementedError();
  }

  @override
  Future<List<PostEntity>> getPosts(
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
  Future<List<PostEntity>> getPostsByCategory(String category) {
    // TODO: implement getPostsByCategory
    throw UnimplementedError();
  }

  @override
  Future<List<PostEntity>> getPostsByLocation(
      double latitude, double longitude, double radius) {
    // TODO: implement getPostsByLocation
    throw UnimplementedError();
  }

  @override
  Future<List<PostEntity>> getPostsByLocationAndCategory(
      double latitude, double longitude, double radius, String category) {
    // TODO: implement getPostsByLocationAndCategory
    throw UnimplementedError();
  }

  @override
  Future<List<PostEntity>> getPostsByPredictedItem(String predictedItem) {
    // TODO: implement getPostsByPredictedItem
    throw UnimplementedError();
  }

  @override
  Future<List<PostEntity>> getPostsBySearchQuery(String searchQuery) {
    // TODO: implement getPostsBySearchQuery
    throw UnimplementedError();
  }

  @override
  Future<List<PostEntity>> getPostsByStatus(String status) {
    // TODO: implement getPostsByStatus
    throw UnimplementedError();
  }

  @override
  Future<List<PostEntity>> getPostsByUserId(String userId) {
    // TODO: implement getPostsByUserId
    throw UnimplementedError();
  }

  @override
  Future<void> updatePost(String postId, Map<String, dynamic> data) {
    // TODO: implement updatePost
    throw UnimplementedError();
  }
}
