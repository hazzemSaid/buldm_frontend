import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserEvent extends UserEvent {
  final String userId;
  final bool forceRefresh;

  const LoadUserEvent({required this.userId, this.forceRefresh = false});

  @override
  List<Object?> get props => [userId, forceRefresh];
}
