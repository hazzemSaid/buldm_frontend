//like
import 'package:equatable/equatable.dart';

class LikeModel extends Equatable {
  final String userId;
  final String postId;
  final DateTime createdAt;
  final String id;
  const LikeModel({
    required this.userId,
    required this.postId,
    required this.createdAt,
    required this.id,
  });
  factory LikeModel.fromJson(Map<String, dynamic> json) {
    return LikeModel(
      userId: json['userId'] ?? '',
      postId: json['postId'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? ''),
      id: json['_id'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'postId': postId,
      'createdAt': createdAt.toIso8601String(),
      'id': id,
    };
  }

  @override
  List<Object?> get props => [userId, postId, createdAt, id];
  @override
  String toString() {
    return 'LikeModel(userId: $userId, postId: $postId, createdAt: $createdAt, id: $id)';
  }

  LikeModel copyWith({
    String? userId,
    String? postId,
    DateTime? createdAt,
    String? id,
  }) {
    return LikeModel(
      userId: userId ?? this.userId,
      postId: postId ?? this.postId,
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
    );
  }
}
