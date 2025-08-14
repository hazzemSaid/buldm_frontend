// Fixed version of your ListOfChats widget
import 'package:buldm/features/auth/domain/entities/userentities.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_cubit.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_state.dart';
import 'package:buldm/features/chat/data/datasource/firebase_chat_service.dart';
import 'package:buldm/features/chat/data/models/contacntListmodel.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_bloc.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_event.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_state.dart';
import 'package:buldm/features/profile/presentation/view/screens/OtherUserProfileScreen.dart';
import 'package:buldm/l10n/app_localizations.dart';
import 'package:buldm/routes/routes.dart';
import 'package:buldm/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ListOfChats extends StatefulWidget {
  const ListOfChats({super.key});

  @override
  State<ListOfChats> createState() => _ListOfChatsState();
}

class _ListOfChatsState extends State<ListOfChats> with WidgetsBindingObserver {
  late String currentUserId;
  late UserBloc _userBloc;
  final _chatService = FirebaseChatService.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    try {
      currentUserId =
          (context.read<AuthCubit>().state as Authenticated).user.user_id;
      _userBloc = context.read<UserBloc>();
    } catch (e) {
      print('Error initializing chat list: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // No-op for Firestore; streams auto-resume
        break;
      case AppLifecycleState.paused:
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _navigateToChat(String otherUserId, ViewerUser user) {
    context.push(
      paths[AppRoute.chat.name]!,
      extra: {
        'user': user,
        'currentUserId': currentUserId,
        'otherUserId': otherUserId,
      },
    );
  }

  // Method to load users for conversations
  void _loadUsersForConversations(List<ChatContactDirectory> conversations) {
    for (final conversation in conversations) {
      _userBloc.add(LoadUserEvent(userId: conversation.user));
    }
  }

  Widget _buildChatItem(ChatContactDirectory conversation, User user) {
    final localization = AppLocalizations.of(context)!;
    final lastMessage = conversation.lastMessage;
    final lastMessageText = lastMessage?.message ?? localization.noMessagesYet;
    final lastMessageTime = lastMessage?.timestamp;

    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            user.avatar.isNotEmpty ? NetworkImage(user.avatar) : null,
        backgroundColor: Colors.blue.shade100,
        child: user.avatar.isEmpty
            ? Text(
                user.name.isNotEmpty
                    ? user.name.substring(0, 1).toUpperCase()
                    : '?',
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Text(
        user.name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lastMessageText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          if (lastMessageTime != null)
            Text(
              _formatTime(lastMessageTime),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
        ],
      ),
      trailing: conversation.unreadCount > 0
          ? Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                conversation.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      onTap: () => _navigateToChat(
          conversation.user,
          ViewerUser(
              avatar: user.avatar,
              id: user.user_id,
              name: user.name,
              email: user.email)),
    );
  }

  Widget _buildLoadingChatItem(ChatContactDirectory conversation) {
    final localization = AppLocalizations.of(context)!;
    final lastMessage = conversation.lastMessage;
    final lastMessageText = lastMessage?.message ?? localization.noMessagesYet;
    final lastMessageTime = lastMessage?.timestamp;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade100,
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      title: const Text(
        'Loading...',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lastMessageText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          if (lastMessageTime != null)
            Text(
              _formatTime(lastMessageTime),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
        ],
      ),
      trailing: conversation.unreadCount > 0
          ? Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                conversation.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  // Connection status not needed with Firestore

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate =
        DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: theme.surface,
            floating: true,
            snap: true,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            iconTheme: IconThemeData(color: theme.primary),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Buldm",
                  style: AppTextStyles.headlineLarge(context).copyWith(
                      color: theme.primary, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {}); // trigger rebuild
                  },
                  icon: Icon(
                    Icons.refresh,
                    color: theme.primary,
                  ),
                ),
              ],
            ),
          ),
          StreamBuilder<List<ChatContactDirectory>>(
            stream: _chatService.streamUserChats(currentUserId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          localization.chatError(snapshot.error.toString()),
                          style:
                              const TextStyle(fontSize: 16, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final conversations = snapshot.data ?? [];

              // Load users for all conversations
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _loadUsersForConversations(conversations);
              });

              if (conversations.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          localization.noChatsFound,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          localization.startChattingWithFriends,
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverFillRemaining(
                child: Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await Future.delayed(
                              const Duration(milliseconds: 300));
                          setState(() {});
                        },
                        child: BlocBuilder<UserBloc, UserState>(
                          builder: (context, userState) {
                            return ListView.builder(
                              itemCount: conversations.length,
                              itemBuilder: (context, index) {
                                final conversation = conversations[index];
                                final userId = conversation.user;

                                if (userState is UserLoaded &&
                                    userState.users.containsKey(userId)) {
                                  final user = userState.users[userId]!;
                                  return _buildChatItem(conversation, user);
                                } else if (userState is UserError) {
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.red.shade100,
                                      child: const Icon(Icons.person_off,
                                          color: Colors.red),
                                    ),
                                    title: const Text('User not found'),
                                    subtitle: Text(
                                        'ID: ${userId.substring(0, 8)}...'),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.refresh),
                                      onPressed: () {
                                        _userBloc.add(LoadUserEvent(
                                          userId: userId,
                                          forceRefresh: true,
                                        ));
                                      },
                                    ),
                                    onTap: null,
                                  );
                                } else {
                                  return _buildLoadingChatItem(conversation);
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
