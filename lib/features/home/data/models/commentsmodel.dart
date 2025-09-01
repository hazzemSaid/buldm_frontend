// comments
import 'package:equatable/equatable.dart';

class CommentModel extends Equatable {
  final String comment;
  final String userId;
  final String postId;
  final DateTime createdAt;
  final String id;
  final String? parentCommentId;
  const CommentModel({
    required this.comment,
    required this.userId,
    required this.postId,
    required this.createdAt,
    required this.id,
    this.parentCommentId,
  });
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    // Accept various backend key shapes
    final dynamic parentRaw =
        json['parentCommentId'] ?? json['parentId'] ?? json['parent'];
    String? parentId;
    if (parentRaw is String) {
      parentId = parentRaw;
    } else if (parentRaw is Map<String, dynamic>) {
      parentId = parentRaw['_id']?.toString() ?? parentRaw['id']?.toString();
    }

    final createdAtStr = (json['createdAt'] ?? '').toString();
    final created = DateTime.tryParse(createdAtStr) ?? DateTime.now();

    return CommentModel(
      comment: json['comment']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      postId: json['postId']?.toString() ?? '',
      createdAt: created,
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      parentCommentId: parentId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comment': comment,
      'userId': userId,
      'postId': postId,
      'createdAt': createdAt.toIso8601String(),
      'id': id,
      'parentCommentId': parentCommentId,
    };
  }

  @override
  // TODO: implement props
  List<Object?> get props =>
      [comment, userId, postId, createdAt, id, parentCommentId];
  @override
  String toString() {
    return 'CommentModel(comment: $comment, userId: $userId, postId: $postId, createdAt: $createdAt, id: $id, parentCommentId: $parentCommentId)';
  }
}
