# Notification System

A comprehensive real-time notification system for the Buldm app, built with Firebase and Flutter Bloc pattern.

## Features

- ✅ **Real-time notifications** using Firebase Firestore
- ✅ **In-app notification screen** with modern UI
- ✅ **Notification badge** showing unread count
- ✅ **Multiple notification types**: like, comment, follow, mention, share
- ✅ **Mark as read/unread** functionality
- ✅ **Delete notifications** with swipe gesture
- ✅ **Duplicate prevention** to avoid spam
- ✅ **Batch operations** for multiple notifications
- ✅ **Time-based cleanup** of old notifications

## Architecture

```
lib/features/notifications/
├── data/
│   ├── models/
│   │   └── notification_model.dart          # Notification data model
│   └── repositories/
│       └── notification_repository.dart     # Firebase operations
├── presentation/
│   ├── bloc/
│   │   ├── notification_bloc.dart          # Business logic
│   │   ├── notification_event.dart         # Events
│   │   └── notification_state.dart         # States
│   ├── view/
│   │   └── screens/
│   │       └── notification_screen.dart    # Main notification UI
│   └── widgets/
│       ├── notification_badge.dart         # Badge widget
│       └── notification_tile.dart          # Individual notification tile
├── services/
│   └── notification_service.dart           # High-level service
├── integration/
│   └── notification_integration.dart       # Easy integration helper
└── test_notification_helper.dart           # Testing utilities
```

## Firebase Structure

The notifications are stored in Firestore with the following structure:

```javascript
notifications/{notificationId}
{
  userId: "string",           // User who triggered the notification
  event: "string",            // Type: like, comment, follow, mention, share
  userTo: "string",           // User receiving the notification
  postId: "string?",          // Optional: related post ID
  createdAt: "timestamp",     // When notification was created
  isRead: "boolean",          // Read status
  additionalData: {           // Optional: extra data
    userName: "string",
    commentText: "string",
    type: "string"
  }
}
```

## Usage

### 1. Basic Integration

To send a notification when someone likes a post:

```dart
import 'package:buldm/features/notifications/integration/notification_integration.dart';

// When user likes a post
await NotificationIntegration.createLikeNotification(
  postId: post.id,
  postOwnerId: post.user_id,
  userName: currentUser.name,
);
```

### 2. Comment Notifications

To send a notification when someone comments:

```dart
await NotificationIntegration.createCommentNotification(
  postId: post.id,
  postOwnerId: post.user_id,
  userName: currentUser.name,
  commentText: commentText,
);
```

### 3. Follow Notifications

To send a notification when someone follows:

```dart
await NotificationIntegration.createFollowNotification(
  userToFollowId: userToFollow.id,
  userName: currentUser.name,
);
```

### 4. Mention Notifications

To send a notification when someone mentions a user:

```dart
await NotificationIntegration.createMentionNotification(
  postId: post.id,
  mentionedUserId: mentionedUser.id,
  userName: currentUser.name,
  commentText: commentText,
);
```

### 5. Share Notifications

To send a notification when someone shares a post:

```dart
await NotificationIntegration.createShareNotification(
  postId: post.id,
  postOwnerId: post.user_id,
  userName: currentUser.name,
);
```

## UI Components

### Notification Badge

The notification badge shows unread count in the app bar:

```dart
NotificationBadge(
  userId: currentUser.id,
  onTap: () {
    // Navigate to notification screen
  },
)
```

### Notification Screen

The main notification screen displays all notifications:

```dart
NotificationScreen()
```

## Testing

Use the test helper to create sample notifications:

```dart
import 'package:buldm/features/notifications/test_notification_helper.dart';

// Create test notifications
await TestNotificationHelper.createTestNotifications();

// Create multiple notifications for badge testing
await TestNotificationHelper.createMultipleNotifications();

// Create all event types
await TestNotificationHelper.createAllEventTypes();
```

## Firebase Setup

1. **Enable Firestore** in your Firebase project
2. **Set up security rules** for the notifications collection:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /notifications/{notificationId} {
      allow read, write: if request.auth != null && 
        (resource.data.userTo == request.auth.uid || 
         resource.data.userId == request.auth.uid);
    }
  }
}
```

3. **Create indexes** for efficient queries:
   - Collection: `notifications`
   - Fields: `userTo` (Ascending), `createdAt` (Descending)
   - Fields: `userTo` (Ascending), `isRead` (Ascending)

## Integration Examples

### Post Actions Integration

The notification system is already integrated with:

- **Like functionality**: Sends notification when user likes a post
- **Comment functionality**: Sends notification when user comments on a post

### Custom Integration

To integrate with other features:

```dart
// In your feature's bloc or service
import 'package:buldm/features/notifications/integration/notification_integration.dart';

// When an event occurs that should trigger a notification
await NotificationIntegration.createNotificationWithDuplicateCheck(
  event: 'custom_event',
  userTo: targetUserId,
  postId: relatedPostId,
  additionalData: {
    'customField': 'customValue',
  },
  duplicateWindow: Duration(minutes: 5), // Prevent duplicates within 5 minutes
);
```

## Advanced Features

### Batch Notifications

Send notifications to multiple users:

```dart
await NotificationIntegration.batchCreateNotifications(
  event: 'announcement',
  usersTo: ['user1', 'user2', 'user3'],
  additionalData: {
    'announcementText': 'Important announcement!',
  },
);
```

### Duplicate Prevention

The system automatically prevents duplicate notifications within a time window:

```dart
await NotificationIntegration.createNotificationWithDuplicateCheck(
  event: 'like',
  userTo: postOwnerId,
  postId: postId,
  duplicateWindow: Duration(minutes: 5), // Custom time window
);
```

## Performance Considerations

- **Pagination**: Notifications are limited to 50 per query
- **Indexing**: Proper Firestore indexes are required
- **Cleanup**: Old notifications are automatically cleaned up after 30 days
- **Caching**: The system uses streams for real-time updates

## Troubleshooting

### Common Issues

1. **Notifications not appearing**: Check Firebase security rules
2. **Badge not updating**: Ensure NotificationBloc is properly initialized
3. **Duplicate notifications**: Use `createNotificationWithDuplicateCheck`
4. **Performance issues**: Check Firestore indexes and query limits

### Debug Mode

Enable debug logging by checking the console output for:
- `📱 Notification sent to user`
- `⚠️ Notification error`
- `✅ Test notifications created`

## Future Enhancements

- [ ] Push notifications integration
- [ ] Notification preferences/settings
- [ ] Notification categories
- [ ] Rich media notifications
- [ ] Notification analytics
- [ ] Cross-platform sync
