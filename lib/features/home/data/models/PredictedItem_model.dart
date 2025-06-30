import 'package:buldm/features/home/domain/entities/PredictedItemEntity.dart';

class PredictedItemModel extends PredictedItemEntity {
  PredictedItemModel({
    required super.label,
    required super.confidence,
    required super.category,
  });

  factory PredictedItemModel.fromJson(Map<String, dynamic> json) {
    return PredictedItemModel(
      label: json['label'] ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] ?? 'other',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'confidence': confidence,
      'category': category,
    };
  }
}
