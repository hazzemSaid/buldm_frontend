import 'package:buldm/features/auth/data/model/userprofilemodel.dart';
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
  final int repostsCount;
  //user id change to ->
  final String contactInfo;
  final DateTime when;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserProfileModel user;
  //user change to return
  final int commentsCount;
  final int likesCount;
  final bool isliked;
  const PostEntity({
    required this.isliked,
    required this.likesCount,
    required this.repostsCount,
    required this.id,
    required this.commentsCount,
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
/* {
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
            "likesCount": 0
        },*/
