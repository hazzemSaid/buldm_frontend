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
          id: messageEvent['id'] as String?,
        );
      }
      // Handle direct message format (for backward compatibility)
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
          id: json['id'] as String?,
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
}
