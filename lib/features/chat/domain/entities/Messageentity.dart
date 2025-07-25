/**const messageSchema = new mongoose.Schema({
  from: { type: String, required: true },
  to: { type: String, required: true },
  message: { type: String, required: true },
  timestamp: { type: Date, default: Date.now },
}); */
abstract class MessageEntity {
  final String from;
  final String to;
  final String message;
  final DateTime timestamp;

  MessageEntity({
    required this.from,
    required this.to,
    required this.message,
    required this.timestamp,
  });
}
