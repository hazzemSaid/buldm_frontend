// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PostImpl _$$PostImplFromJson(Map<String, dynamic> json) => _$PostImpl(
      title: json['title'] as String,
      description: json['description'] as String,
      images:
          (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
      status: json['status'] as String,
      category: json['category'] as String? ?? "other",
      predictedItems: (json['predictedItems'] as List<dynamic>?)
              ?.map((e) => PredictedItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      userId: json['user_id'] as String,
      contactInfo: json['contactInfo'] as String? ?? "",
      when:
          json['when'] == null ? null : DateTime.parse(json['when'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$PostImplToJson(_$PostImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'images': instance.images,
      'location': instance.location,
      'status': instance.status,
      'category': instance.category,
      'predictedItems': instance.predictedItems,
      'user_id': instance.userId,
      'contactInfo': instance.contactInfo,
      'when': instance.when?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$LocationImpl _$$LocationImplFromJson(Map<String, dynamic> json) =>
    _$LocationImpl(
      type: json['type'] as String? ?? "Point",
      coordinates: (json['coordinates'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      placeName: json['placeName'] as String? ?? "",
    );

Map<String, dynamic> _$$LocationImplToJson(_$LocationImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'coordinates': instance.coordinates,
      'placeName': instance.placeName,
    };

_$PredictedItemImpl _$$PredictedItemImplFromJson(Map<String, dynamic> json) =>
    _$PredictedItemImpl(
      label: json['label'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      category: json['category'] as String? ?? "other",
    );

Map<String, dynamic> _$$PredictedItemImplToJson(_$PredictedItemImpl instance) =>
    <String, dynamic>{
      'label': instance.label,
      'confidence': instance.confidence,
      'category': instance.category,
    };
