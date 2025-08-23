// features/notifications/presentation/bloc/notification_event.dart
import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {
  final String userId;

  const LoadNotifications(this.userId);

  @override
  List<Object?> get props => [userId];
}

class MarkAsRead extends NotificationEvent {
  final String notificationId;

  const MarkAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllAsRead extends NotificationEvent {
  final String userId;

  const MarkAllAsRead(this.userId);

  @override
  List<Object?> get props => [userId];
}

class DeleteNotification extends NotificationEvent {
  final String notificationId;

  const DeleteNotification(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class CreateNotification extends NotificationEvent {
  final String userId;
  final String event;
  final String userTo;
  final String? postId;
  final Map<String, dynamic>? additionalData;

  const CreateNotification({
    required this.userId,
    required this.event,
    required this.userTo,
    this.postId,
    this.additionalData,
  });

  @override
  List<Object?> get props => [userId, event, userTo, postId, additionalData];
}
