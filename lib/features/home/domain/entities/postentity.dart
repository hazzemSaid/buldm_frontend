import 'package:buldm/features/home/domain/entities/LocationEntity.dart';
import 'package:buldm/features/home/domain/entities/PredictedItemEntity.dart';

abstract class PostEntity {
  final String title;
  final String description;
  final List<String> images;
  final LocationEntity location;
  final String status; // "lost", "found", or "claimed"
  final String category;
  final List<PredictedItemEntity> predictedItems;
  final String user_id;
  final String contactInfo;
  final DateTime when;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PostEntity({
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
