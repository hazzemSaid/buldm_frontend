import 'package:buldm/features/chat/data/models/contacntListmodel.dart';

abstract class ChatRepo {
  Future<List<ChatContactDirectory>> getAllMessagesById(String userId);
  Future<List<ChatContactDirectory>> getMessagesByTId(
      String userid1, String userid2);
}
