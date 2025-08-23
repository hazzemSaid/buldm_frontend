// features/notifications/test_notification_helper.dart
import 'package:buldm/features/notifications/integration/notification_integration.dart';

class TestNotificationHelper {
  // Test method to create sample notifications
  static Future<void> createTestNotifications() async {
    try {
      // Test like notification
      await NotificationIntegration.createLikeNotification(
        postId: 'test_post_123',
        postOwnerId: 'test_user_456',
        userName: 'Test User',
      );

      // Test comment notification
      await NotificationIntegration.createCommentNotification(
        postId: 'test_post_123',
        postOwnerId: 'test_user_456',
        userName: 'Test User',
        commentText: 'This is a test comment!',
      );

      // Test follow notification
      await NotificationIntegration.createFollowNotification(
        userToFollowId: 'test_user_456',
        userName: 'Test User',
      );

      // Test mention notification
      await NotificationIntegration.createMentionNotification(
        postId: 'test_post_123',
        mentionedUserId: 'test_user_456',
        userName: 'Test User',
        commentText: 'Hey @test_user_456, check this out!',
      );

      // Test share notification
      await NotificationIntegration.createShareNotification(
        postId: 'test_post_123',
        postOwnerId: 'test_user_456',
        userName: 'Test User',
      );

      print('✅ Test notifications created successfully!');
    } catch (e) {
      print('❌ Error creating test notifications: $e');
    }
  }

  // Test method to create multiple notifications for testing badge count
  static Future<void> createMultipleNotifications() async {
    try {
      for (int i = 1; i <= 5; i++) {
        await NotificationIntegration.createLikeNotification(
          postId: 'test_post_$i',
          postOwnerId: 'test_user_456',
          userName: 'User $i',
        );

        // Add small delay between notifications
        await Future.delayed(Duration(milliseconds: 100));
      }

      print('✅ Multiple test notifications created successfully!');
    } catch (e) {
      print('❌ Error creating multiple notifications: $e');
    }
  }

  // Test method to create notifications with different event types
  static Future<void> createAllEventTypes() async {
    try {
      final events = [
        {
          'type': 'like',
          'postId': 'test_post_events',
          'postOwnerId': 'test_user_456',
          'userName': 'Event Test User',
        },
        {
          'type': 'comment',
          'postId': 'test_post_events',
          'postOwnerId': 'test_user_456',
          'userName': 'Event Test User',
          'commentText': 'Testing all event types!',
        },
        {
          'type': 'follow',
          'userToFollowId': 'test_user_456',
          'userName': 'Event Test User',
        },
        {
          'type': 'mention',
          'postId': 'test_post_events',
          'mentionedUserId': 'test_user_456',
          'userName': 'Event Test User',
          'commentText': 'Mentioning @test_user_456 in this test!',
        },
        {
          'type': 'share',
          'postId': 'test_post_events',
          'postOwnerId': 'test_user_456',
          'userName': 'Event Test User',
        },
      ];

      for (final event in events) {
        switch (event['type']) {
          case 'like':
            await NotificationIntegration.createLikeNotification(
              postId: event['postId']!,
              postOwnerId: event['postOwnerId']!,
              userName: event['userName'],
            );
            break;
          case 'comment':
            await NotificationIntegration.createCommentNotification(
              postId: event['postId']!,
              postOwnerId: event['postOwnerId']!,
              userName: event['userName'],
              commentText: event['commentText'],
            );
            break;
          case 'follow':
            await NotificationIntegration.createFollowNotification(
              userToFollowId: event['userToFollowId']!,
              userName: event['userName'],
            );
            break;
          case 'mention':
            await NotificationIntegration.createMentionNotification(
              postId: event['postId']!,
              mentionedUserId: event['mentionedUserId']!,
              userName: event['userName'],
              commentText: event['commentText'],
            );
            break;
          case 'share':
            await NotificationIntegration.createShareNotification(
              postId: event['postId']!,
              postOwnerId: event['postOwnerId']!,
              userName: event['userName'],
            );
            break;
        }

        // Add small delay between notifications
        await Future.delayed(Duration(milliseconds: 200));
      }

      print('✅ All event type notifications created successfully!');
    } catch (e) {
      print('❌ Error creating event type notifications: $e');
    }
  }
}

