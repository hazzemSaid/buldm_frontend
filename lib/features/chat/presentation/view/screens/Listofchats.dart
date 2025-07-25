import 'package:buldm/core/Dependency_njection/service_locator.dart';
import 'package:buldm/core/http/socket.io/socketserver.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_cubit.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_state.dart';
import 'package:buldm/features/chat/data/models/MessageModel.dart'
    show MessageModel;
import 'package:buldm/features/chat/data/models/contacntListmodel.dart';
import 'package:buldm/features/chat/presentation/view/screens/chatdetailsscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ConnectionStatus { connecting, connected, disconnected, error }

class ListOfChats extends StatefulWidget {
  const ListOfChats({super.key});

  @override
  State<ListOfChats> createState() => _ListOfChatsState();
}

class _ListOfChatsState extends State<ListOfChats> with WidgetsBindingObserver {
  late String currentUserId;
  List<ChatContactDirectory> messages = [];
  late SocketService socketService;
  ConnectionStatus connectionStatus = ConnectionStatus.connecting;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    try {
      currentUserId =
          (context.read<AuthCubit>().state as Authenticated).user.user_id;
      socketService = sl<SocketService>();
      _setupSocket();
    } catch (e) {
      setState(() {
        connectionStatus = ConnectionStatus.error;
        errorMessage = 'Failed to initialize: $e';
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground, reconnect if needed
        if (!socketService.isConnected) {
          _reconnect();
        }
        break;
      case AppLifecycleState.paused:
        // App going to background, could disconnect to save resources
        break;
      default:
        break;
    }
  }

  Future<void> _setupSocket() async {
    setState(() {
      connectionStatus = ConnectionStatus.connecting;
      errorMessage = null;
    });

    try {
      final connected = await socketService.connect();

      if (!connected) {
        throw Exception('Failed to connect to server');
      }

      socketService.registerUser(currentUserId);

      // Set up message listener - handle individual messages for contact list
      socketService.listenForMessages((Map<String, dynamic> data) {
        try {
          // Parse as MessageModel since that's what we're receiving
          final messageModel = MessageModel.fromJson(data);
          _onMessageReceived(messageModel);
        } catch (e) {
          print('Error parsing message in ListOfChats: $e');
          print('Received data: $data');
        }
      });

      setState(() {
        connectionStatus = ConnectionStatus.connected;
      });
    } catch (e) {
      setState(() {
        connectionStatus = ConnectionStatus.error;
        errorMessage = e.toString();
      });
      print('Error setting up socket: $e');
    }
  }

  Future<void> _reconnect() async {
    setState(() {
      connectionStatus = ConnectionStatus.connecting;
      errorMessage = null;
    });

    try {
      final success = await socketService.reconnect();
      if (success) {
        socketService.registerUser(currentUserId);
        setState(() {
          connectionStatus = ConnectionStatus.connected;
        });
      } else {
        throw Exception('Reconnection failed');
      }
    } catch (e) {
      setState(() {
        connectionStatus = ConnectionStatus.error;
        errorMessage = 'Reconnection failed: $e';
      });
    }
  }

  void _onMessageReceived(MessageModel newMessage) {
    if (!mounted) return;

    setState(() {
      // Determine the other user in this conversation
      final otherUserId =
          newMessage.from == currentUserId ? newMessage.to : newMessage.from;

      // Find existing conversation or create new one
      int index =
          messages.indexWhere((contact) => contact.userId == otherUserId);

      if (index != -1) {
        // Update existing conversation
        final existingContact = messages[index];
        final updatedMessages =
            List<MessageModel>.from(existingContact.messages);

        // Add new message if it's not already there
        final messageExists = updatedMessages.any((msg) =>
            msg.id == newMessage.id ||
            (msg.message == newMessage.message &&
                msg.timestamp == newMessage.timestamp &&
                msg.from == newMessage.from));

        if (!messageExists) {
          updatedMessages.add(newMessage);
          updatedMessages.sort((a, b) => (a.timestamp ?? DateTime.now())
              .compareTo(b.timestamp ?? DateTime.now()));
        }

        final updatedContact = ChatContactDirectory(
          userId: otherUserId,
          messages: updatedMessages,
          lastActivity: newMessage.timestamp,
        );

        messages[index] = updatedContact;
        // Move to top for recent activity
        final movedContact = messages.removeAt(index);
        messages.insert(0, movedContact);
      } else {
        // Create new conversation
        final newContact = ChatContactDirectory(
          userId: otherUserId,
          messages: [newMessage],
          lastActivity: newMessage.timestamp,
        );
        messages.insert(0, newContact);
      }
    });
  }

  String _getConversationId(ChatContactDirectory contact) {
    // Create a consistent conversation ID regardless of sender/receiver
    final participants = [currentUserId, contact.userId]..sort();
    return participants.join('_');
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) return 'now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    if (difference.inDays < 7) return '${difference.inDays}d';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  Widget _buildConnectionStatus() {
    switch (connectionStatus) {
      case ConnectionStatus.connecting:
        return Container(
          color: Colors.orange.withOpacity(0.1),
          padding: const EdgeInsets.all(8),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text('Connecting...', style: TextStyle(color: Colors.orange)),
            ],
          ),
        );
      case ConnectionStatus.connected:
        return const SizedBox.shrink();
      case ConnectionStatus.error:
        return Container(
          color: Colors.red.withOpacity(0.1),
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 16),
              const SizedBox(width: 8),
              const Text('Connection failed. ',
                  style: TextStyle(color: Colors.red)),
              GestureDetector(
                onTap: _reconnect,
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        );
      case ConnectionStatus.disconnected:
        return Container(
          color: Colors.grey.withOpacity(0.1),
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Disconnected. ',
                  style: TextStyle(color: Colors.grey)),
              GestureDetector(
                onTap: _reconnect,
                child: const Text(
                  'Reconnect',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildMessagesList() {
    if (connectionStatus == ConnectionStatus.connecting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (messages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Start a new conversation to see it here',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final otherUserId = message.userId;
        final lastMessage =
            message.messages.isNotEmpty ? message.messages.last : null;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                otherUserId.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              'User $otherUserId',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: lastMessage != null
                ? Text(
                    lastMessage.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey),
                  )
                : const Text('No messages'),
            trailing: lastMessage != null
                ? Text(
                    _formatTimestamp(lastMessage.timestamp ??
                        DateTime.fromMillisecondsSinceEpoch(0)),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  )
                : null,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailsScreen(
                    otherUserId: otherUserId,
                    currentUserId: currentUserId,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Don't dispose the socket service here as it's a singleton
    // Just disconnect if needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: Icon(
              connectionStatus == ConnectionStatus.connected
                  ? Icons.wifi
                  : Icons.wifi_off,
              color: connectionStatus == ConnectionStatus.connected
                  ? Colors.green
                  : Colors.red,
            ),
            onPressed: connectionStatus != ConnectionStatus.connected
                ? _reconnect
                : null,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildConnectionStatus(),
          Expanded(child: _buildMessagesList()),
        ],
      ),
    );
  }
}
