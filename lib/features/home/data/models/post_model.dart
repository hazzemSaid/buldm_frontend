import 'package:buldm/features/auth/data/model/usermodel.dart';
import 'package:buldm/features/home/data/models/PredictedItem_model.dart';
import 'package:buldm/features/home/data/models/comments.dart';
import 'package:buldm/features/home/data/models/location_model.dart';
import 'package:buldm/features/home/domain/entities/postentity.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.commentsCount,
    required super.comments,
    required super.likes,
    required super.user,
    required super.title,
    required super.description,
    required super.images,
    required super.location,
    required super.status,
    required super.category,
    required super.predictedItems,
    required super.user_id,
    required super.contactInfo,
    required super.when,
    required super.createdAt,
    required super.updatedAt,
  });
  PostModel copyWith({
    String? id,
    int? commentsCount,
    List<CommentModel>? comments,
    Set<String>? likes,
    UserModel? user,
    String? title,
    String? description,
    List<String>? images,
    LocationModel? location,
    String? status,
    String? category,
    List<PredictedItemModel>? predictedItems,
    String? user_id,
    String? contactInfo,
    DateTime? when,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      commentsCount: commentsCount ?? this.commentsCount,
      comments: comments ?? this.comments,
      likes: likes ?? this.likes,
      user: user ?? this.user,
      title: title ?? this.title,
      description: description ?? this.description,
      images: images ?? this.images,
      location: location ?? this.location,
      status: status ?? this.status,
      category: category ?? this.category,
      predictedItems: predictedItems ?? this.predictedItems,
      user_id: user_id ?? this.user_id,
      contactInfo: contactInfo ?? this.contactInfo,
      when: when ?? this.when,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Normalize likes structure: can be
    // 1) List<String>
    // 2) List<Map> where each map may contain 'usersIDs': List<String>
    // 3) Map { usersIDs: List<String>, ... }
    final dynamic likesRaw = json['likes'];
    Set<String> likesSet = <String>{};
    if (likesRaw is List) {
      if (likesRaw.isNotEmpty && likesRaw.first is String) {
        // Simple array of user IDs
        likesSet = likesRaw.whereType<String>().toSet();
      } else if (likesRaw.isNotEmpty && likesRaw.first is Map) {
        // Array of objects; extract all usersIDs arrays and union them
        for (final item in likesRaw.whereType<Map>()) {
          final dynamic users = item['usersIDs']; // nested usersIDs
          if (users is List) {
            likesSet.addAll(users.whereType<String>());
          }
        }
      }
    } else if (likesRaw is Map<String, dynamic>) {
      final usersIDs =
          (likesRaw['usersIDs'] as List?)?.whereType<String>().toSet() ?? {};
      likesSet = usersIDs;
    }

    // Normalize comments structure: can be List or {count, recent}
    final dynamic commentsRaw = json['recentComments'];
    List<CommentModel> commentsList = [];
    int commentsCount = 0;
    if (commentsRaw is List) {
      commentsList = List<CommentModel>.from(commentsRaw
          .map((x) => CommentModel.fromJson(x as Map<String, dynamic>)));
      commentsCount = json['commentsCount'] ?? commentsList.length;
    } else if (commentsRaw is Map<String, dynamic>) {
      final recent = (commentsRaw as List?) ?? [];
      commentsList = List<CommentModel>.from(
          recent.map((x) => CommentModel.fromJson(x as Map<String, dynamic>)));
      commentsCount = (commentsRaw['count'] is int)
          ? commentsRaw['count'] as int
          : commentsList.length;
    }

    return PostModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      likes: likesSet,
      commentsCount: commentsCount,
      comments: commentsList,
      user: UserModel.fromJson(json['user'] ?? {}),
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
      user_id: json['user_id'] ?? '',
      contactInfo: json['contactInfo'] ?? '',
      when: DateTime.tryParse(json['when'] ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commentsCount': commentsCount,
      'comments': comments.map((x) => x.toJson()).toList(),
      'likes': likes,
      'user': user.toJson(),
      'title': title,
      'description': description,
      'images': images,
      'location': (location as LocationModel).toJson(),
      'status': status,
      'category': category,
      'predictedItems': predictedItems
          .map((item) => (item as PredictedItemModel).toJson())
          .toList(),
      'user_id': user_id,
      'contactInfo': contactInfo,
      'when': when.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
