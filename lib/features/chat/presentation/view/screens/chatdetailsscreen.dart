import 'package:buldm/core/Dependency_njection/service_locator.dart';
import 'package:buldm/core/http/socket.io/socketserver.dart';
import 'package:buldm/features/chat/data/models/MessageModel.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class ChatDetailsScreen extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;

  const ChatDetailsScreen({
    super.key,
    required this.currentUserId,
    required this.otherUserId,
  });

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<MessageModel> _messages = [];
  late final SocketService _socketService;

  bool _isConnected = false;
  bool _isSending = false;
  StreamSubscription? _messageSubscription;

  @override
  void initState() {
    super.initState();
    _socketService = sl<SocketService>();
    _setupMessageListener();
    _checkConnection();
    _loadInitialMessages();
  }

  void _checkConnection() {
    setState(() {
      _isConnected = _socketService.isConnected;
    });

    // Periodically check connection status
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final connected = _socketService.isConnected;
      if (_isConnected != connected) {
        setState(() {
          _isConnected = connected;
        });
      }
    });
  }

  void _setupMessageListener() {
    _socketService.listenForMessages((data) {
      try {
        final message = MessageModel.fromJson(data);

        // Only add messages relevant to this conversation
        if ((message.from == widget.otherUserId &&
                message.to == widget.currentUserId) ||
            (message.from == widget.currentUserId &&
                message.to == widget.otherUserId)) {
          // Avoid duplicate messages by checking id first, then other properties
          final existingIndex = _messages.indexWhere((m) =>
              (m.id != null && message.id != null && m.id == message.id) ||
              (m.timestamp == message.timestamp &&
                  m.message == message.message &&
                  m.from == message.from));

          if (existingIndex == -1) {
            setState(() {
              _messages.add(message);
              _messages.sort((a, b) => (a.timestamp ?? DateTime.now())
                  .compareTo(b.timestamp ?? DateTime.now()));
            });
            _scrollToBottom();
          }
        }
      } catch (e) {
        print('Error parsing message in ChatDetailsScreen: $e');
        print('Received data: $data');
      }
    });
  }

  void _loadInitialMessages() async {
    // TODO: Load chat history from your backend/local storage
    // This is where you'd fetch previous messages between these two users
    print(
        'Loading initial messages between ${widget.currentUserId} and ${widget.otherUserId}');
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
    if (content.isEmpty || _isSending) return;

    if (!_isConnected) {
      _showSnackBar('Not connected to server', Colors.red);
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final message = MessageModel(
        message: content,
        from: widget.currentUserId,
        to: widget.otherUserId,
        timestamp: DateTime.now(),
      );

      final success =
          _socketService.sendMessage(widget.otherUserId, message.message);

      if (success) {
        setState(() {
          _messages.add(message);
        });
        _messageController.clear();
        _scrollToBottom();
      } else {
        _showSnackBar('Failed to send message', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error sending message: $e', Colors.red);
    } finally {
      setState(() {
        _isSending = false;
      });
    }
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
          color: isMe ? Colors.blue : Colors.grey[300],
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
              _formatTimestamp(message.timestamp ?? DateTime.now()),
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
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

  Widget _buildConnectionStatus() {
    if (_isConnected) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: Colors.red.withOpacity(0.1),
      padding: const EdgeInsets.all(8),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, color: Colors.red, size: 16),
          SizedBox(width: 8),
          Text(
            'Not connected to server',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                widget.otherUserId.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "User ${widget.otherUserId}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    _isConnected ? "Online" : "Offline",
                    style: TextStyle(
                      fontSize: 12,
                      color: _isConnected ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildConnectionStatus(),
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "No messages yet",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Send a message to start the conversation",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMe = message.from == widget.currentUserId;
                      return _buildMessageBubble(message, isMe);
                    },
                  ),
          ),
          Container(
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
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 8,
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    enabled: _isConnected && !_isSending,
                    decoration: InputDecoration(
                      hintText: _isConnected
                          ? 'Type your message...'
                          : 'Connecting...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color:
                        _isConnected && !_isSending ? Colors.blue : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white),
                    onPressed:
                        _isConnected && !_isSending ? _sendMessage : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
