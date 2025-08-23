// features/notifications/presentation/bloc/notification_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:buldm/features/notifications/data/models/notification_model.dart';
import 'package:buldm/features/notifications/data/repositories/notification_repository.dart';
import 'package:buldm/features/notifications/presentation/bloc/notification_event.dart';
import 'package:buldm/features/notifications/presentation/bloc/notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _repository;

  NotificationBloc(this._repository) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkAsRead>(_onMarkAsRead);
    on<MarkAllAsRead>(_onMarkAllAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<CreateNotification>(_onCreateNotification);
  }

  void _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) {
    emit(NotificationLoading());

    try {
      final notificationsStream =
          _repository.getNotificationsStream(event.userId);
      final unreadCountStream = _repository.getUnreadCountStream(event.userId);

      emit(NotificationLoaded(
        notificationsStream: notificationsStream,
        unreadCountStream: unreadCountStream,
      ));
    } catch (e) {
      emit(NotificationError('Failed to load notifications: $e'));
    }
  }

  Future<void> _onMarkAsRead(
    MarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _repository.markAsRead(event.notificationId);
      // State will be updated automatically through the stream
    } catch (e) {
      emit(NotificationError('Failed to mark notification as read: $e'));
    }
  }

  Future<void> _onMarkAllAsRead(
    MarkAllAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _repository.markAllAsRead(event.userId);
      // State will be updated automatically through the stream
    } catch (e) {
      emit(NotificationError('Failed to mark all notifications as read: $e'));
    }
  }

  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _repository.deleteNotification(event.notificationId);
      // State will be updated automatically through the stream
    } catch (e) {
      emit(NotificationError('Failed to delete notification: $e'));
    }
  }

  Future<void> _onCreateNotification(
    CreateNotification event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _repository.createNotification(
        userId: event.userId,
        event: event.event,
        userTo: event.userTo,
        postId: event.postId,
        additionalData: event.additionalData,
      );
      // State will be updated automatically through the stream
    } catch (e) {
      emit(NotificationError('Failed to create notification: $e'));
    }
  }
}
