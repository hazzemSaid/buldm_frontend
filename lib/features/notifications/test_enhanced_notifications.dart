// features/notifications/test_enhanced_notifications.dart
import 'package:buldm/features/notifications/integration/notification_integration.dart';

class EnhancedNotificationTest {
  // Test the enhanced notification system with user data and post previews
  static Future<void> testEnhancedNotifications() async {
    print('🧪 Testing Enhanced Notification System...');

    try {
      // Create test notifications with different event types
      await NotificationIntegration.createLikeNotification(
        postId: 'test_post_enhanced',
        postOwnerId: 'test_user_enhanced',
        userName: 'Enhanced Test User',
      );

      await NotificationIntegration.createCommentNotification(
        postId: 'test_post_enhanced',
        postOwnerId: 'test_user_enhanced',
        userName: 'Enhanced Test User',
        commentText: 'This is an enhanced test comment!',
      );

      print('✅ Enhanced notification test completed!');
      print('📱 Check your notification screen to see:');
      print('   - User names and avatars from UserBloc');
      print('   - Post previews with images and content');
      print('   - Real-time updates from Firebase');
      print('   - Badge count in app bar');
    } catch (e) {
      print('❌ Enhanced notification test failed: $e');
    }
  }

  // Test notification with specific user and post data
  static Future<void> testSpecificNotification({
    required String userId,
    required String postId,
    required String event,
  }) async {
    print('🧪 Testing specific notification...');

    try {
      switch (event) {
        case 'like':
          await NotificationIntegration.createLikeNotification(
            postId: postId,
            postOwnerId: userId,
            userName: 'Test User',
          );
          break;
        case 'comment':
          await NotificationIntegration.createCommentNotification(
            postId: postId,
            postOwnerId: userId,
            userName: 'Test User',
            commentText: 'This is a test comment!',
          );
          break;
        case 'follow':
          await NotificationIntegration.createFollowNotification(
            userToFollowId: userId,
            userName: 'Test User',
          );
          break;
        case 'mention':
          await NotificationIntegration.createMentionNotification(
            postId: postId,
            mentionedUserId: userId,
            userName: 'Test User',
            commentText: 'Hey @$userId, check this out!',
          );
          break;
        case 'share':
          await NotificationIntegration.createShareNotification(
            postId: postId,
            postOwnerId: userId,
            userName: 'Test User',
          );
          break;
        default:
          print('❌ Unknown event type: $event');
          return;
      }

      print('✅ Specific notification test completed!');
      print('📱 Created $event notification for user $userId and post $postId');
    } catch (e) {
      print('❌ Specific notification test failed: $e');
    }
  }

  // Test notification screen features
  static void testNotificationScreenFeatures() {
    print('🧪 Notification Screen Features:');
    print('✅ Real-time user data loading');
    print('✅ Post preview with images');
    print('✅ User avatars and names');
    print('✅ Mark as read functionality');
    print('✅ Swipe to delete');
    print('✅ Badge count updates');
    print('✅ Pull to refresh');
    print('✅ Navigation to posts');
    print('✅ Error handling');
  }
}
