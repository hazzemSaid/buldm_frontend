// features/chat/presentation/view/screens/chatdetailsscreen.dart
import 'package:buldm/core/Dependency_njection/service_locator.dart';
import 'package:buldm/features/auth/data/model/usermodel.dart';
import 'package:buldm/features/auth/domain/entities/userentities.dart';
import 'package:buldm/features/chat/data/models/MessageModel.dart';
import 'package:buldm/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:buldm/features/chat/presentation/bloc/chat_event.dart';
import 'package:buldm/features/chat/presentation/bloc/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatDetailsScreen extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final User user;
  const ChatDetailsScreen({
    super.key,
    required this.user,
    required this.currentUserId,
    required this.otherUserId,
  });

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final ChatBloc _chatBloc;

  @override
  void initState() {
    super.initState();
    _chatBloc = sl<ChatBloc>();

    // Connect to socket and register user
    _chatBloc.add(ConnectToSocket());
    _chatBloc.add(RegisterUser(widget.currentUserId));

    // Load messages for this conversation (only once)
    _chatBloc.add(LoadMessages(widget.currentUserId, widget.otherUserId));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _chatBloc.add(SendMessage(
      message: content,
      fromUserId: widget.currentUserId,
      toUserId: widget.otherUserId,
    ));

    _messageController.clear();
    _scrollToBottom();
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    final theme = Theme.of(context).colorScheme;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isMe ? 64 : 12,
          right: isMe ? 12 : 64,
          top: 4,
          bottom: 4,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? theme.primary : theme.onPrimary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate =
        DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
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
              'Connecting...',
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return BlocProvider.value(
      value: _chatBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.user.avatar),
              ),
              Text(widget.user.name),
            ],
          ),
          backgroundColor: theme.primary,
          foregroundColor: theme.onPrimary,
        ),
        body: Column(
          children: [
            BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                return _buildConnectionStatus(state);
              },
            ),
            Expanded(
              child: BlocConsumer<ChatBloc, ChatState>(
                listener: (context, state) {
                  if (state is MessagesLoaded) {
                    _scrollToBottom();
                  } else if (state is ChatError) {
                    _showSnackBar(state.message, Colors.red);
                  }
                },
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is MessagesLoaded ||
                      state is ConversationSwitched) {
                    final messages = state is MessagesLoaded
                        ? (state as MessagesLoaded).messages
                        : (state as ConversationSwitched).messages;

                    if (messages.isEmpty) {
                      return const Center(
                        child: Text(
                          'No messages yet. Start the conversation!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8),
                      itemCount: messages.length,
                      reverse: false, // Normal order
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.from == widget.currentUserId;
                        return _buildMessageBubble(message, isMe);
                      },
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
                              _chatBloc.add(LoadMessages(
                                widget.currentUserId,
                                widget.otherUserId,
                              ));
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  return const Center(
                    child: Text('Loading messages...'),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  BlocBuilder<ChatBloc, ChatState>(
                    builder: (context, state) {
                      final isConnected =
                          state is SocketConnected || state is MessagesLoaded;
                      return IconButton(
                        onPressed: isConnected ? _sendMessage : null,
                        icon: const Icon(Icons.send),
                        color: isConnected ? theme.primary : Colors.grey,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
