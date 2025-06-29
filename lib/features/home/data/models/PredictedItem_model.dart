import 'package:buldm/features/home/domain/entities/PredictedItemEntity.dart';
import 'package:equatable/equatable.dart';

class PredicteditemModel extends PredictedItemEntity implements Equatable {
  PredicteditemModel(
      {required super.label, required super.confidence, super.category});
  factory PredicteditemModel.fromJson(Map<String, dynamic> json) {
    return PredicteditemModel(
      label: json['label'],
      confidence: json['confidence'],
      category: json['category'] ?? "other",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'confidence': confidence,
      'category': category,
    };
  }

  @override
  List<Object?> get props => [
        label,
        confidence,
        category,
      ];

  @override
  bool? get stringify => true;
}
