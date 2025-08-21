import 'package:buldm/features/auth/data/model/usermodel.dart';
import 'package:buldm/features/home/data/models/comments.dart';
import 'package:buldm/features/home/data/models/location_model.dart';
import 'package:buldm/features/home/domain/entities/PredictedItemEntity.dart';

abstract class PostEntity {
  final String title;
  final String id;
  final String description;
  final List<String> images;
  final LocationModel location;
  final String status; // "lost", "found", or "claimed"
  final String category;
  final List<PredictedItemEntity> predictedItems;
  final String user_id;
  final String contactInfo;
  final DateTime when;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel user;
  final int commentsCount;
  final List<CommentModel> comments;
  final Set<String> likes;
  const PostEntity({
    required this.id,
    required this.commentsCount,
    required this.comments,
    required this.likes,
    required this.user,
    required this.title,
    required this.description,
    required this.images,
    required this.location,
    required this.status,
    required this.category,
    required this.predictedItems,
    required this.user_id,
    required this.contactInfo,
    required this.when,
    required this.createdAt,
    required this.updatedAt,
  });
}
