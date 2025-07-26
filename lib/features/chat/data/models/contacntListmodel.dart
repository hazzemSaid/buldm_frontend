// features/chat/data/models/contacntListmodel.dart
// ContactListModel.dart - Updated for chat contacts
import 'package:buldm/features/chat/data/models/MessageModel.dart';

class ChatContactDirectory {
  final String user;
  final List<MessageModel> messages;
  final DateTime? lastActivity;

  ChatContactDirectory({
    required this.user,
    required this.messages,
    this.lastActivity,
  });

  factory ChatContactDirectory.fromJson(Map<String, dynamic> json) {
    try {
      // Handle the conversation format from your backend
      return ChatContactDirectory(
        user: json['user'] as String,
        messages: (json['messages'] as List<dynamic>?)
                ?.map(
                    (msg) => MessageModel.fromJson(msg as Map<String, dynamic>))
                .toList() ??
            [],
        lastActivity: json['lastActivity'] != null
            ? DateTime.parse(json['lastActivity'] as String)
            : null,
      );
    } catch (e) {
      print('Error parsing ChatContactDirectory from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'messages': messages.map((msg) => msg.toJson()).toList(),
      'lastActivity': lastActivity?.toIso8601String(),
    };
  }

  // Get the last message for display in chat list
  MessageModel? get lastMessage {
    if (messages.isEmpty) return null;
    return messages.reduce((a, b) =>
        (a.timestamp ?? DateTime.now()).isAfter(b.timestamp ?? DateTime.now())
            ? a
            : b);
  }

  // Get unread message count (you can implement this based on your needs)
  int get unreadCount {
    // This would need to be implemented based on your read/unread logic
    return 0;
  }
}
