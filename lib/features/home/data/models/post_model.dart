import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_model.freezed.dart';
part 'post_model.g.dart';

@freezed
class Post with _$Post {
  const factory Post({
    required String title,
    required String description,
    List<String>? images,
    required Location location,
    required String status,
    @Default("other") String category,
    @Default([]) List<PredictedItem> predictedItems,
    @JsonKey(name: 'user_id') required String userId,
    @Default("") String contactInfo,
    @Default(null) DateTime? when,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}

@freezed
class Location with _$Location {
  const factory Location({
    @Default("Point") String type,
    required List<double> coordinates,
    @Default("") String placeName,
  }) = _Location;

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);
}

@freezed
class PredictedItem with _$PredictedItem {
  const factory PredictedItem({
    required String label,
    required double confidence,
    @Default("other") String category,
  }) = _PredictedItem;

  factory PredictedItem.fromJson(Map<String, dynamic> json) =>
      _$PredictedItemFromJson(json);
}
