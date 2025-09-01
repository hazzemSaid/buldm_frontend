// features/home/data/models/post_model.dart
import 'package:buldm/features/auth/data/model/userprofilemodel.dart';
import 'package:buldm/features/home/data/models/PredictedItem_model.dart';
import 'package:buldm/features/home/data/models/location_model.dart';
import 'package:buldm/features/home/domain/entities/postentity.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.commentsCount,
    required super.user,
    required super.title,
    required super.likesCount,
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
    required super.repostsCount,
    required super.updatedAt,
    required super.isliked,
  });
  PostModel copyWith({
    bool? isliked,
    String? id,
    int? commentsCount,
    String? title,
    String? description,
    int? likesCount,
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
    int? repostsCount,
    UserProfileModel? user,
  }) {
    return PostModel(
      isliked: isliked ?? this.isliked,
      repostsCount: repostsCount ?? this.repostsCount,
      user: user ?? this.user,
      id: id ?? this.id,
      commentsCount: commentsCount ?? this.commentsCount,
      title: title ?? this.title,
      likesCount: likesCount ?? this.likesCount,
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
    return PostModel(
      isliked: json['isLike'],
      id: json['_id'],
      commentsCount: json['commentsCount'],
      user: UserProfileModel.fromJson(json['user']),
      title: json['title'],
      likesCount: json['likesCount'],
      description: json['description'],
      images: List<String>.from(json['images']),
      location: LocationModel.fromJson(json['location']),
      status: json['status'],
      category: json['category'],
      predictedItems: List<PredictedItemModel>.from(
        json['predictedItems'].map((x) => PredictedItemModel.fromJson(x)),
      ),
      user_id: json['user_id'],
      contactInfo: json['contactInfo'],
      when: DateTime.parse(json['when']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      repostsCount: json['repostsCount'],
    );
  }
}
/*
            "_id": "68b05b6949d5a728d949fd2c",
            "repost": [],
            "title": "withe Wallet",
            "description": "black wallet found near the park",
            "images": [],
            "location": {
                "type": "Point",
                "coordinates": [
                    40.7128,
                    -74.006
                ],
                "placeName": "New York"
            },
            "status": "found",
            "category": "",
            "predictedItems": [],
            "user_id": "689a677320a1503a42519a23",
            "contactInfo": "",
            "when": "2025-08-28T13:36:41.792Z",
            "createdAt": "2025-08-28T13:36:41.783Z",
            "updatedAt": "2025-08-28T13:36:41.783Z",
            "__v": 0,
            "reposts": [],
            "repostsCount": 0,
            "user": {
                "_id": "689a677320a1503a42519a23",
                "name": "hazem",
                "avatar": "https://lh3.googleusercontent.com/a/ACg8ocLM2GW7-Zm8mwk57_MMTv76ClWVq-iXGtdaFkwZ9_mHZv0svJHb=s96-c"
            },
            "commentsCount": 0,
            "likesCount": 0*/
