// features/chat/domain/repo/chatrepo.dart
import 'package:buldm/features/chat/data/models/contacntListmodel.dart';
import 'package:buldm/features/chat/data/models/MessageModel.dart';

abstract class ChatRepo {
  Future<List<ChatContactDirectory>> getAllMessagesById(String userId);
  Future<List<MessageModel>> getMessagesByTId(String userid1, String userid2);
}
