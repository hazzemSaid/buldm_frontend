import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String event;
  final String? postId;
  final DateTime createdAt;
  final String userTo;
  final bool isRead;
  final Map<String, dynamic>? additionalData;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.event,
    this.postId,
    required this.createdAt,
    required this.userTo,
    this.isRead = false,
    this.additionalData,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      event: data['event'] ?? '',
      postId: data['postId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      userTo: data['userTo'] ?? '',
      isRead: data['isRead'] ?? false,
      additionalData: data['additionalData'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'event': event,
      'postId': postId,
      'createdAt': Timestamp.fromDate(createdAt),
      'userTo': userTo,
      'isRead': isRead,
      'additionalData': additionalData,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? event,
    String? postId,
    DateTime? createdAt,
    String? userTo,
    bool? isRead,
    Map<String, dynamic>? additionalData,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      event: event ?? this.event,
      postId: postId ?? this.postId,
      createdAt: createdAt ?? this.createdAt,
      userTo: userTo ?? this.userTo,
      isRead: isRead ?? this.isRead,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  String get eventDisplayText {
    switch (event) {
      case 'like':
        return 'liked your post';
      case 'comment':
        return 'commented on your post';
      case 'follow':
        return 'started following you';
      case 'mention':
        return 'mentioned you in a comment';
      case 'share':
        return 'shared your post';
      default:
        return event;
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
