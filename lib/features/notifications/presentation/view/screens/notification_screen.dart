// features/notifications/presentation/view/screens/notification_screen.dart
import 'package:buldm/core/Dependency_njection/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:buldm/features/notifications/data/models/notification_model.dart';
import 'package:buldm/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:buldm/features/notifications/presentation/bloc/notification_event.dart';
import 'package:buldm/features/notifications/presentation/bloc/notification_state.dart';
import 'package:buldm/features/notifications/presentation/widgets/notification_tile.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_cubit.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_state.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_bloc.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_event.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_state.dart';
import 'package:buldm/features/home/persentation/bloc/post/post_bloc.dart';
import 'package:buldm/features/home/data/models/post_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      context
          .read<NotificationBloc>()
          .add(LoadNotifications(authState.user.user_id));
    }
  }

  void _loadUserData(List<NotificationModel> notifications) {
    // Extract unique user IDs from notifications
    final userIds = notifications
        .map((notification) => notification.userId)
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    if (userIds.isNotEmpty) {
      print('👤 Loading user data for: $userIds');
      // Load all users at once using LoadMultipleUsersEvent
      context.read<UserBloc>().add(LoadMultipleUsersEvent(userIds: userIds));
    }
  }

  void _loadPostData(List<NotificationModel> notifications) {
    // Extract unique post IDs from notifications
    final postIds = notifications
        .map((notification) => notification.postId)
        .where((id) => id != null && id!.isNotEmpty)
        .toSet()
        .toList();

    if (postIds.isNotEmpty) {
      print('📝 Loading post data for: $postIds');
      // Load individual posts for each post ID
      for (final postId in postIds) {
        context.read<PostBloc>().add(LoadIndividualPostEvent(postId: postId!));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<UserBloc>.value(value: sl<UserBloc>()),
          BlocProvider<PostBloc>.value(value: sl<PostBloc>()),
        ],
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: const Text(
              'Notifications',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            actions: [
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, authState) {
                  if (authState is Authenticated) {
                    return StreamBuilder<int>(
                      stream: context.read<NotificationBloc>().state
                              is NotificationLoaded
                          ? (context.read<NotificationBloc>().state
                                  as NotificationLoaded)
                              .unreadCountStream
                          : Stream.value(0),
                      builder: (context, snapshot) {
                        final unreadCount = snapshot.data ?? 0;
                        if (unreadCount > 0) {
                          return TextButton(
                            onPressed: () {
                              context.read<NotificationBloc>().add(
                                    MarkAllAsRead(authState.user.user_id),
                                  );
                            },
                            child: Text(
                              'Mark all read',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          body: BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state is NotificationError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading notifications',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadNotifications,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is NotificationLoaded) {
                return StreamBuilder<List<NotificationModel>>(
                  stream: state.notificationsStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final notifications = snapshot.data!;

                    // Load user and post data when notifications change
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      print(
                          '📱 Loading data for ${notifications.length} notifications');
                      _loadUserData(notifications);
                      _loadPostData(notifications);
                    });

                    if (notifications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FontAwesomeIcons.bell,
                              size: 64,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No notifications yet',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'When you get notifications, they\'ll appear here',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        _loadNotifications();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return NotificationTile(
                            notification: notification,
                            onTap: () {
                              _handleNotificationTap(notification);
                            },
                            onMarkAsRead: () {
                              context.read<NotificationBloc>().add(
                                    MarkAsRead(notification.id),
                                  );
                            },
                            onDelete: () {
                              _showDeleteDialog(notification);
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              }

              return const Center(
                child: Text('No notifications'),
              );
            },
          ),
        ));
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Mark as read when tapped
    context.read<NotificationBloc>().add(MarkAsRead(notification.id));

    // Navigate based on notification type
    switch (notification.event) {
      case 'like':
      case 'comment':
      case 'share':
        if (notification.postId != null) {
          // Try to get the post from PostBloc state
          final postState = context.read<PostBloc>().state;
          if (postState is PostLoaded) {
            final postModel = postState.posts[notification.postId!];
            if (postModel != null) {
              // Navigate to post details - you can implement your own navigation here
              print('Navigate to post: ${notification.postId}');
              // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetailScreen(post: postModel)));
            } else {
              // Post not loaded yet, load it first
              context
                  .read<PostBloc>()
                  .add(LoadIndividualPostEvent(postId: notification.postId!));
              print('Loading post: ${notification.postId}');
            }
          }
        }
        break;
      case 'follow':
        // Navigate to user profile
        // TODO: Implement navigation to user profile
        print('Navigate to user profile: ${notification.userId}');
        break;
      case 'mention':
        if (notification.postId != null) {
          // Same as like/comment/share - navigate to post
          final postState = context.read<PostBloc>().state;
          if (postState is PostLoaded) {
            final postModel = postState.posts[notification.postId!];
            if (postModel != null) {
              print('Navigate to post with mention: ${notification.postId}');
              // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetailScreen(post: postModel)));
            } else {
              context
                  .read<PostBloc>()
                  .add(LoadIndividualPostEvent(postId: notification.postId!));
              print('Loading post for mention: ${notification.postId}');
            }
          }
        }
        break;
    }
  }

  void _showDeleteDialog(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notification'),
        content:
            const Text('Are you sure you want to delete this notification?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<NotificationBloc>().add(
                    DeleteNotification(notification.id),
                  );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
