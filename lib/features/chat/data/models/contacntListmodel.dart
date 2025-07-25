// ContactListModel.dart - Updated for chat contacts
import 'package:buldm/features/chat/data/models/MessageModel.dart';

class ChatContactDirectory {
  final String userId;
  final List<MessageModel> messages;
  final DateTime? lastActivity;

  ChatContactDirectory({
    required this.userId,
    required this.messages,
    this.lastActivity,
  });

  factory ChatContactDirectory.fromJson(Map<String, dynamic> json) {
    try {
      // This should only be used for contact list, not individual messages
      return ChatContactDirectory(
        userId: json['userId'] as String,
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
      'userId': userId,
      'messages': messages.map((msg) => msg.toJson()).toList(),
      'lastActivity': lastActivity?.toIso8601String(),
    };
  }
}
