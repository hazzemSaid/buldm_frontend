import 'package:buldm/features/home/data/models/PredictedItem_model.dart';
import 'package:buldm/features/home/data/models/location_model.dart';
import 'package:buldm/features/home/domain/entities/postentity.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.title,
    required super.description,
    required super.images,
    required super.location,
    required super.status,
    required super.category,
    required super.predictedItems,
    required super.userId,
    required super.contactInfo,
    required super.when,
    required super.createdAt,
    required super.updatedAt,
    required super.id,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      images: json['images'] == null
          ? []
          : List<String>.from(json['images'].whereType<String>()),
      location: LocationModel.fromJson(json['location'] ?? {}),
      status: json['status'] ?? '',
      category: json['category'] ?? '',
      predictedItems: json['predictedItems'] == null
          ? []
          : List<PredictedItemModel>.from(json['predictedItems']
              .map((item) => PredictedItemModel.fromJson(item))),
      userId: json['user_id'] ?? '',
      contactInfo: json['contactInfo'] ?? '',
      when: DateTime.tryParse(json['when'] ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'images': images,
      'location': (location as LocationModel).toJson(),
      'status': status,
      'category': category,
      'predictedItems': predictedItems
          .map((item) => (item as PredictedItemModel).toJson())
          .toList(),
      'user_id': userId,
      'contactInfo': contactInfo,
      'when': when.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'id': id,
    };
  }
}
