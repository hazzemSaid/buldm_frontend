// core/services/notificationService.dart
import 'dart:convert';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buldm/core/Dependency_njection/service_locator.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_cubit.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_state.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initialize() async {
    try {
      // Enable verbose logging for debugging (remove in production)
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

      // Request notification permissions
      OneSignal.Notifications.requestPermission(true);

      // Set up notification click listener
      OneSignal.Notifications.addClickListener((event) {
        _handleNotificationClick(event);
      });

      // Set up subscription observer
      OneSignal.User.pushSubscription.addObserver((state) async {
        await _handleSubscriptionChange(state);
      });
    } catch (e) {
      print('Failed to initialize notification service: $e');
    }
  }

  Future<void> _handleSubscriptionChange(
      OSPushSubscriptionChangedState state) async {
    try {
      final id = state.current.id;
      final auth = sl<AuthCubit>().state;

      if (auth is Authenticated && id != null) {
        await OneSignal.login(auth.user.user_id);
        await _savePlayerIdToFirestore(auth.user.user_id, id);
      }
    } catch (e) {
      print('Failed to handle subscription change: $e');
    }
  }

  void _handleNotificationClick(OSNotificationClickEvent event) {
    try {
      final data = event.notification.additionalData ?? {};
      final type = data['type'] as String?;

      switch (type) {
        case 'chat':
          _handleChatNotification(data);
          break;
        case 'post_comment':
          _handlePostCommentNotification(data);
          break;
        default:
          print('Unknown notification type: $type');
      }
    } catch (e) {
      print('Failed to handle notification click: $e');
    }
  }

  void _handleChatNotification(Map<String, dynamic> data) {
    // Handle chat notification navigation
    final senderId = data['senderId'] as String?;
    if (senderId == null || senderId.isEmpty) return;

    // TODO: Implement navigation to chat screen
    print('Navigate to chat with sender: $senderId');
  }

  void _handlePostCommentNotification(Map<String, dynamic> data) {
    // Handle post comment notification navigation
    final postId = data['postId']?.toString();
    final commentId = data['commentId']?.toString();

    if (postId != null && postId.isNotEmpty) {
      // TODO: Implement navigation to post details
      print('Navigate to post: $postId, comment: $commentId');
    }
  }

  Future<void> _savePlayerIdToFirestore(String userId, String playerId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'onesignal_player_id': playerId,
        'oneSignalPlayerId': playerId,
        'playerId': playerId,
      }, SetOptions(merge: true));

      print('Saved OneSignal player ID for user: $userId');
    } catch (e) {
      print('Failed to save OneSignal player ID: $e');
    }
  }

  Future<void> loginUser(String userId) async {
    try {
      await OneSignal.login(userId);
      final playerId = OneSignal.User.pushSubscription.id;

      if (playerId != null) {
        await _savePlayerIdToFirestore(userId, playerId);
      }
    } catch (e) {
      print('Failed to login user to OneSignal: $e');
    }
  }

  Future<void> logoutUser() async {
    try {
      await OneSignal.logout();
    } catch (e) {
      print('Failed to logout user from OneSignal: $e');
    }
  }
}
