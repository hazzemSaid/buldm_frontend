import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buldm/features/notifications/data/models/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get real-time notifications for a user
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('userTo', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  // Get unread notifications count
  Stream<int> getUnreadCountStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('userTo', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Create a new notification
  Future<void> createNotification({
    required String userId,
    required String event,
    required String userTo,
    String? postId,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'event': event,
        'userTo': userTo,
        'postId': postId,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'additionalData': additionalData,
      });
    } catch (e) {
      print('Error creating notification: $e');
      rethrow;
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  // Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection('notifications')
          .where('userTo', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in notifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  // Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow;
    }
  }

  // Get user data for notification display
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }
}
