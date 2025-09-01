// features/notifications/services/notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buldm/features/notifications/data/models/notification_model.dart';
import 'package:buldm/features/notifications/data/repositories/notification_repository.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final NotificationRepository _repository = NotificationRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create notification for various events
  Future<void> createLikeNotification({
    required String userId,
    required String userTo,
    required String postId,
    String? userName,
  }) async {
    await _repository.createNotification(
      userId: userId,
      event: 'like',
      userTo: userTo,
      postId: postId,
      additionalData: {
        'userName': userName,
        'type': 'post_like',
      },
    );
  }

  Future<void> createCommentNotification({
    required String userId,
    required String userTo,
    required String postId,
    String? userName,
    String? commentText,
    required String commentId,
  }) async {
    await _repository.createNotification(
      userId: userId,
      event: 'comment',
      userTo: userTo,
      postId: postId,
      additionalData: {
        'userName': userName,
        'commentText': commentText,
        'commentId': commentId,
        'type': 'post_comment',
      },
    );
  }

  Future<void> createFollowNotification({
    required String userId,
    required String userTo,
    String? userName,
  }) async {
    await _repository.createNotification(
      userId: userId,
      event: 'follow',
      userTo: userTo,
      additionalData: {
        'userName': userName,
        'type': 'user_follow',
      },
    );
  }

  Future<void> createMentionNotification({
    required String userId,
    required String userTo,
    required String postId,
    String? userName,
    String? commentText,
  }) async {
    await _repository.createNotification(
      userId: userId,
      event: 'mention',
      userTo: userTo,
      postId: postId,
      additionalData: {
        'userName': userName,
        'commentText': commentText,
        'type': 'comment_mention',
      },
    );
  }

  Future<void> createShareNotification({
    required String userId,
    required String userTo,
    required String postId,
    String? userName,
  }) async {
    await _repository.createNotification(
      userId: userId,
      event: 'share',
      userTo: userTo,
      postId: postId,
      additionalData: {
        'userName': userName,
        'type': 'post_share',
      },
    );
  }

  // Get real-time notifications stream
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _repository.getNotificationsStream(userId);
  }

  // Get unread count stream for badge
  Stream<int> getUnreadCountStream(String userId) {
    return _repository.getUnreadCountStream(userId);
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _repository.markAsRead(notificationId);
  }

  // Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    await _repository.markAllAsRead(userId);
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await _repository.deleteNotification(notificationId);
  }

  // Get user data for notification display
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    return await _repository.getUserData(userId);
  }

  // Batch create notifications (for multiple users)
  Future<void> batchCreateNotifications({
    required String userId,
    required String event,
    required List<String> usersTo,
    String? postId,
    Map<String, dynamic>? additionalData,
  }) async {
    final batch = _firestore.batch();
    final notificationsRef = _firestore.collection('notifications');

    for (final userTo in usersTo) {
      if (userId != userTo) {
        // Don't notify yourself
        final docRef = notificationsRef.doc();
        batch.set(docRef, {
          'userId': userId,
          'event': event,
          'userTo': userTo,
          'postId': postId,
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': false,
          'additionalData': additionalData,
        });
      }
    }

    await batch.commit();
  }

  // Check if notification already exists (to prevent duplicates)
  Future<bool> notificationExists({
    required String userId,
    required String event,
    required String userTo,
    String? postId,
    Duration? timeWindow,
  }) async {
    final query = _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('event', isEqualTo: event)
        .where('userTo', isEqualTo: userTo);

    if (postId != null) {
      query.where('postId', isEqualTo: postId);
    }

    if (timeWindow != null) {
      final cutoffTime = DateTime.now().subtract(timeWindow);
      query.where('createdAt', isGreaterThan: Timestamp.fromDate(cutoffTime));
    }

    final snapshot = await query.limit(1).get();
    return snapshot.docs.isNotEmpty;
  }

  // Create notification with duplicate prevention
  Future<void> createNotificationWithDuplicateCheck({
    required String userId,
    required String event,
    required String userTo,
    String? postId,
    Map<String, dynamic>? additionalData,
    Duration? duplicateWindow,
  }) async {
    final exists = await notificationExists(
      userId: userId,
      event: event,
      userTo: userTo,
      postId: postId,
      timeWindow: duplicateWindow ?? const Duration(minutes: 5),
    );

    if (!exists) {
      await _repository.createNotification(
        userId: userId,
        event: event,
        userTo: userTo,
        postId: postId,
        additionalData: additionalData,
      );
    }
  }

  // Get notification statistics
  Future<Map<String, int>> getNotificationStats(String userId) async {
    final notifications = await _firestore
        .collection('notifications')
        .where('userTo', isEqualTo: userId)
        .get();

    final stats = <String, int>{};
    for (final doc in notifications.docs) {
      final event = doc.data()['event'] as String? ?? 'unknown';
      stats[event] = (stats[event] ?? 0) + 1;
    }

    return stats;
  }

  // Clean up old notifications (older than 30 days)
  Future<void> cleanupOldNotifications() async {
    final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
    final cutoffTimestamp = Timestamp.fromDate(cutoffDate);

    final oldNotifications = await _firestore
        .collection('notifications')
        .where('createdAt', isLessThan: cutoffTimestamp)
        .get();

    final batch = _firestore.batch();
    for (final doc in oldNotifications.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  Future<bool> hasSentNotification(
      {required String userId,
      required String userTo,
      required String postId,
      required String event,
      String? comment}) async {
    final query = _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('event', isEqualTo: event)
        .where('userTo', isEqualTo: userTo);
    if (comment != null) {
      query.where('commentText', isEqualTo: comment);
    }
    if (postId != null) {
      query.where('postId', isEqualTo: postId);
    }
    final snapshot = await query.limit(1).get();
    return snapshot.docs.isNotEmpty;
  }
}
