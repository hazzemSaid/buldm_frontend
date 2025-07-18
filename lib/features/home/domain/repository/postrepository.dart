import 'package:buldm/features/auth/domain/entities/userentities.dart';
import 'package:buldm/features/home/domain/entities/postentity.dart';
import 'package:dio/dio.dart';

abstract class Postrepository {
  Future<List<PostEntity>> getPosts({
    String? category,
    String? status,
    String? userId,
    String? searchQuery,
    int? limit,
    int? page,
    required token,
  });
  Future<PostEntity> getPostById(String postId);
  Future<List<PostEntity>> getPostsByUserId(String userId);
  Future<List<PostEntity>> getPostsByCategory(String category);
  Future<List<PostEntity>> getPostsByStatus(String status);
  Future<List<PostEntity>> getPostsByLocation(
    double latitude,
    double longitude,
    double radius,
  );
  Future<Response> createPost(FormData data, String token);
  Future<void> updatePost(String postId, Map<String, dynamic> data);
  Future<void> deletePost(String postId);
  Future<List<PostEntity>> getPostsBySearchQuery(String searchQuery);
  Future<List<PostEntity>> getPostsByPredictedItem(String predictedItem);
  Future<List<PostEntity>> getPostsByLocationAndCategory(
    double latitude,
    double longitude,
    double radius,
    String category,
  );
  Future<User> getUserById(String userId);
}
