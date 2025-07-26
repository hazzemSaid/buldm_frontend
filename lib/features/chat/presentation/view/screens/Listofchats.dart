// features/chat/presentation/view/screens/Listofchats.dart
import 'package:buldm/core/Dependency_njection/service_locator.dart';
import 'package:buldm/features/auth/data/model/usermodel.dart';
import 'package:buldm/features/auth/domain/entities/userentities.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_cubit.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_state.dart';
import 'package:buldm/features/chat/data/models/contacntListmodel.dart';
import 'package:buldm/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:buldm/features/chat/presentation/bloc/chat_event.dart';
import 'package:buldm/features/chat/presentation/bloc/chat_state.dart';
import 'package:buldm/features/chat/presentation/view/screens/chatdetailsscreen.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_bloc.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_event.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ListOfChats extends StatefulWidget {
  const ListOfChats({super.key});

  @override
  State<ListOfChats> createState() => _ListOfChatsState();
}

class _ListOfChatsState extends State<ListOfChats> with WidgetsBindingObserver {
  late String currentUserId;
  late ChatBloc _chatBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    try {
      currentUserId =
          (context.read<AuthCubit>().state as Authenticated).user.user_id;
      _chatBloc = sl<ChatBloc>();

      // Connect to socket and register user
      _chatBloc.add(ConnectToSocket());
      _chatBloc.add(RegisterUser(currentUserId));

      // Load conversations
      _chatBloc.add(LoadConversations(currentUserId));
    } catch (e) {
      print('Error initializing chat list: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground, reconnect if needed
        _chatBloc.add(ConnectToSocket());
        break;
      case AppLifecycleState.paused:
        // App going to background, could disconnect to save resources
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

  void _navigateToChat(String otherUserId, User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailsScreen(
          currentUserId: currentUserId,
          otherUserId: otherUserId,
          user: user,
        ),
      ),
    );
  }

  Widget _buildChatItemLoading(ChatContactDirectory conversation, User user) {
    final lastMessage = conversation.lastMessage;
    final lastMessageText = lastMessage?.message ?? 'No messages yet';
    final lastMessageTime = lastMessage?.timestamp;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade100,
        child: Text(
          conversation.user.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: Colors.blue.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        'User ${conversation.user}',
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
      onTap: () => _navigateToChat(conversation.user, user),
    );
  }

  Widget _buildConnectionStatus(ChatState state) {
    if (state is SocketConnecting) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.orange,
        child: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Connecting to chat server...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    } else if (state is SocketError) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.red,
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Connection error: ${state.message}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () => _chatBloc.add(ConnectToSocket()),
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildChatItem(ChatContactDirectory conversation, User user) {
    final lastMessage = conversation.lastMessage;
    final lastMessageText = lastMessage?.message ?? 'No messages yet';
    final lastMessageTime = lastMessage?.timestamp;

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(user.avatar),
        backgroundColor: Colors.blue.shade100,
        child: Text(
          conversation.user.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: Colors.blue.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
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
      onTap: () => _navigateToChat(conversation.user, user),
    );
  }

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
    return BlocProvider.value(
      value: _chatBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _chatBloc.add(LoadConversations(currentUserId));
              },
            ),
          ],
        ),
        body: Column(
          children: [
            BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                return _buildConnectionStatus(state);
              },
            ),
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is ConversationsLoaded ||
                      state is ConversationsUpdated) {
                    final conversations = state is ConversationsLoaded
                        ? state.conversations
                        : (state as ConversationsUpdated).conversations;

                    if (conversations.isEmpty) {
                      return const Center(
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
                              'No conversations yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Start chatting with other users!',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        _chatBloc.add(LoadConversations(currentUserId));
                      },
                      child: BlocBuilder<UserBloc, UserState>(
                        builder: (context, state) {
                          return ListView.builder(
                            itemCount: conversations.length,
                            itemBuilder: (context, index) {
                              // Load user data for each conversation
                              context.read<UserBloc>().add(LoadUserEvent(
                                    userId: conversations[index].user,
                                  ));
                              final user = context
                                  .read<UserBloc>()
                                  .userCache[conversations[index].user];

                              if (state is UserLoaded && user != null) {
                                return _buildChatItem(
                                    conversations[index], user);
                              }
                              // Show loading placeholder while user data loads
                              return SizedBox();
                            },
                          );
                        },
                      ),
                    );
                  } else if (state is ChatError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${state.message}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              _chatBloc.add(LoadConversations(currentUserId));
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  return const Center(
                    child: Text('Loading conversations...'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
