// features/notifications/presentation/widgets/notification_tile.dart
import 'package:buldm/features/home/data/models/post_model.dart';
import 'package:buldm/features/home/persentation/bloc/post/post_bloc.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_bloc.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_state.dart';
import 'package:buldm/features/notifications/data/models/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onMarkAsRead;
  final VoidCallback onDelete;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onMarkAsRead,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Theme.of(context).colorScheme.error,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Theme.of(context).colorScheme.surface
              : Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead
                ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)
                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Avatar with BlocBuilder
                  BlocBuilder<UserBloc, UserState>(
                    builder: (context, userState) {
                      String? userName;
                      String? userAvatar;
                      if (userState is UserLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (userState is UserError) {
                        return Center(
                          child: Text(
                            userState.message,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        );
                      }
                      if (userState is UserLoaded) {
                        final user = userState.users[notification.userId];

                        if (user != null) {
                          userName = user.name;
                          userAvatar = user.avatar;
                        }
                      }

                      return CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        backgroundImage: (userAvatar != null &&
                                userAvatar.isNotEmpty &&
                                userAvatar.startsWith('http'))
                            ? NetworkImage(userAvatar) as ImageProvider
                            : null,
                        child: (userAvatar == null ||
                                userAvatar.isEmpty ||
                                !userAvatar.startsWith('http'))
                            ? Text(
                                (userName?.isNotEmpty == true
                                        ? userName!.substring(0, 1)
                                        : (notification.userId.isNotEmpty
                                            ? notification.userId[0]
                                            : 'U'))
                                    .toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                              )
                            : null,
                      );
                    },
                  ),
                  const SizedBox(width: 12),

                  // Notification Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: BlocBuilder<UserBloc, UserState>(
                                builder: (context, userState) {
                                  String displayName = 'someone';
                                  if (userState is UserLoading) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (userState is UserError) {
                                    return Center(
                                      child: Text(
                                        userState.message,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    );
                                  }

                                  if (userState is UserLoaded) {
                                    final user =
                                        userState.users[notification.userId];
                                    if (user != null && user.name.isNotEmpty) {
                                      displayName = user.name;
                                    }
                                  }

                                  return RichText(
                                    text: TextSpan(
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      children: [
                                        TextSpan(
                                          text: displayName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const TextSpan(text: ' '),
                                        TextSpan(
                                            text:
                                                notification.eventDisplayText),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.timeAgo,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),

                        // Post Preview for relevant notifications
                        if (notification.postId != null &&
                            (notification.event == 'like' ||
                                notification.event == 'comment' ||
                                notification.event == 'share' ||
                                notification.event == 'mention')) ...[
                          const SizedBox(height: 8),
                          BlocBuilder<PostBloc, PostState>(
                            builder: (context, postState) {
                              PostModel? post;

                              if (postState is PostLoaded) {
                                final postModel =
                                    postState.posts[notification.postId!];
                                if (postModel != null) {
                                  post = postModel;
                                }
                              }

                              if (post != null) {
                                return Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest
                                        .withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline
                                          .withValues(alpha: 0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Post image preview
                                      if (post.images.isNotEmpty) ...[
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: Image.network(
                                            post.images.first,
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .surfaceContainerHighest,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Icon(
                                                  Icons.image,
                                                  size: 16,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .outline,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      // Post content preview
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              post.description.length > 50
                                                  ? '${post.description.substring(0, 50)}...'
                                                  : post.description,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                                  ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Tap to view post',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .outline,
                                                    fontSize: 11,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Action Buttons
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'mark_read':
                          onMarkAsRead();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      if (!notification.isRead)
                        const PopupMenuItem(
                          value: 'mark_read',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline),
                              SizedBox(width: 8),
                              Text('Mark as read'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getEventIcon() {
    switch (notification.event) {
      case 'like':
        return FontAwesomeIcons.heart;
      case 'comment':
        return FontAwesomeIcons.comment;
      case 'follow':
        return FontAwesomeIcons.userPlus;
      case 'mention':
        return FontAwesomeIcons.at;
      case 'share':
        return FontAwesomeIcons.share;
      default:
        return FontAwesomeIcons.bell;
    }
  }
}
