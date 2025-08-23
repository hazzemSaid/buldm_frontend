import 'package:equatable/equatable.dart';
import 'package:buldm/features/notifications/data/models/notification_model.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final Stream<List<NotificationModel>> notificationsStream;
  final Stream<int> unreadCountStream;

  const NotificationLoaded({
    required this.notificationsStream,
    required this.unreadCountStream,
  });

  @override
  List<Object?> get props => [notificationsStream, unreadCountStream];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}
