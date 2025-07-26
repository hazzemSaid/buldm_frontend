// features/chat/data/models/MessageModel.dart
// MessageModel.dart - Updated to handle the new server format
class MessageModel {
  final String message;
  final String from;
  final String to;
  final DateTime? timestamp;
  final String? id;

  MessageModel({
    required this.message,
    required this.from,
    required this.to,
    this.timestamp,
    this.id,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handle the nested MessageEvent structure from your server
      if (json.containsKey('MessageEvent')) {
        final messageEvent = json['MessageEvent'] as Map<String, dynamic>;
        return MessageModel(
          message: messageEvent['message'] as String,
          from: messageEvent['from'] as String,
          to: messageEvent['to'] as String,
          timestamp: messageEvent['timestamp'] != null
              ? DateTime.parse(messageEvent['timestamp'] as String)
              : null,
          id: messageEvent['_id'] as String?,
        );
      }
      // Handle direct message format (for HTTP responses)
      else {
        return MessageModel(
          message: json['message'] as String,
          from: json['from'] as String,
          to: json['to'] as String,
          timestamp: json['timestamp'] != null
              ? (json['timestamp'] is String
                  ? DateTime.parse(json['timestamp'] as String)
                  : DateTime.fromMillisecondsSinceEpoch(
                      json['timestamp'] as int))
              : null,
          id: json['_id'] as String?,
        );
      }
    } catch (e) {
      print('Error parsing MessageModel from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'from': from,
      'to': to,
      'timestamp': timestamp?.toIso8601String(),
      'id': id,
    };
  }

  // Create a copy with updated fields
  MessageModel copyWith({
    String? message,
    String? from,
    String? to,
    DateTime? timestamp,
    String? id,
  }) {
    return MessageModel(
      message: message ?? this.message,
      from: from ?? this.from,
      to: to ?? this.to,
      timestamp: timestamp ?? this.timestamp,
      id: id ?? this.id,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageModel &&
        other.message == message &&
        other.from == from &&
        other.to == to &&
        other.timestamp == timestamp &&
        other.id == id;
  }

  @override
  int get hashCode {
    return message.hashCode ^
        from.hashCode ^
        to.hashCode ^
        timestamp.hashCode ^
        id.hashCode;
  }
}
