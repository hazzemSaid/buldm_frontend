abstract class UserEvent {}

class LoadUserEvent extends UserEvent {
  final String userId;
  final bool forceRefresh;

  LoadUserEvent({
    required this.userId,
    this.forceRefresh = false,
  });
}

class LoadMultipleUsersEvent extends UserEvent {
  final List<String> userIds;
  final bool forceRefresh;

  LoadMultipleUsersEvent({
    required this.userIds,
    this.forceRefresh = false,
  });
}

// Event to clear all cached users (used on refresh)
class ClearUserCacheEvent extends UserEvent {}
