// features/notifications/integration/notification_integration.dart
import 'package:buldm/features/notifications/services/notification_service.dart';
import 'package:buldm/core/Dependency_njection/service_locator.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_cubit.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_state.dart';

class NotificationIntegration {
  static final NotificationService _notificationService = NotificationService();

  // Create like notification
  static Future<void> createLikeNotification({
    required String postId,
    required String postOwnerId,
    String? userName,
  }) async {
    final authState = sl<AuthCubit>().state;
    if (authState is Authenticated) {
      final currentUserId = authState.user.user_id;

      // Don't notify yourself
      if (currentUserId != postOwnerId) {
        await _notificationService.createLikeNotification(
          userId: currentUserId,
          userTo: postOwnerId,
          postId: postId,
          userName: userName ?? authState.user.name,
        );
      }
    }
  }

  // Create comment notification
  static Future<void> createCommentNotification({
    required String postId,
    required String postOwnerId,
    String? userName,
    String? commentText,
  }) async {
    final authState = sl<AuthCubit>().state;
    if (authState is Authenticated) {
      final currentUserId = authState.user.user_id;

      // Don't notify yourself
      if (currentUserId != postOwnerId) {
        await _notificationService.createCommentNotification(
          userId: currentUserId,
          userTo: postOwnerId,
          postId: postId,
          userName: userName ?? authState.user.name,
          commentText: commentText,
        );
      }
    }
  }

  // Create follow notification
  static Future<void> createFollowNotification({
    required String userToFollowId,
    String? userName,
  }) async {
    final authState = sl<AuthCubit>().state;
    if (authState is Authenticated) {
      final currentUserId = authState.user.user_id;

      // Don't notify yourself
      if (currentUserId != userToFollowId) {
        await _notificationService.createFollowNotification(
          userId: currentUserId,
          userTo: userToFollowId,
          userName: userName ?? authState.user.name,
        );
      }
    }
  }

  // Create mention notification
  static Future<void> createMentionNotification({
    required String postId,
    required String mentionedUserId,
    String? userName,
    String? commentText,
  }) async {
    final authState = sl<AuthCubit>().state;
    if (authState is Authenticated) {
      final currentUserId = authState.user.user_id;

      // Don't notify yourself
      if (currentUserId != mentionedUserId) {
        await _notificationService.createMentionNotification(
          userId: currentUserId,
          userTo: mentionedUserId,
          postId: postId,
          userName: userName ?? authState.user.name,
          commentText: commentText,
        );
      }
    }
  }

  // Create share notification
  static Future<void> createShareNotification({
    required String postId,
    required String postOwnerId,
    String? userName,
  }) async {
    final authState = sl<AuthCubit>().state;
    if (authState is Authenticated) {
      final currentUserId = authState.user.user_id;

      // Don't notify yourself
      if (currentUserId != postOwnerId) {
        await _notificationService.createShareNotification(
          userId: currentUserId,
          userTo: postOwnerId,
          postId: postId,
          userName: userName ?? authState.user.name,
        );
      }
    }
  }

  // Batch create notifications for multiple users
  static Future<void> batchCreateNotifications({
    required String event,
    required List<String> usersTo,
    String? postId,
    Map<String, dynamic>? additionalData,
  }) async {
    final authState = sl<AuthCubit>().state;
    if (authState is Authenticated) {
      final currentUserId = authState.user.user_id;

      await _notificationService.batchCreateNotifications(
        userId: currentUserId,
        event: event,
        usersTo: usersTo,
        postId: postId,
        additionalData: additionalData,
      );
    }
  }

  // Create notification with duplicate prevention
  static Future<void> createNotificationWithDuplicateCheck({
    required String event,
    required String userTo,
    String? postId,
    Map<String, dynamic>? additionalData,
    Duration? duplicateWindow,
  }) async {
    final authState = sl<AuthCubit>().state;
    if (authState is Authenticated) {
      final currentUserId = authState.user.user_id;

      // Don't notify yourself
      if (currentUserId != userTo) {
        await _notificationService.createNotificationWithDuplicateCheck(
          userId: currentUserId,
          event: event,
          userTo: userTo,
          postId: postId,
          additionalData: additionalData,
          duplicateWindow: duplicateWindow,
        );
      }
    }
  }
}
