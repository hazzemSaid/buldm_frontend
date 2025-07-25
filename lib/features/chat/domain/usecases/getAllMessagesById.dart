import 'package:buldm/features/chat/data/models/contacntListmodel.dart';
import 'package:buldm/features/chat/domain/repo/chatrepo.dart';

class GetAllMessagesById {
  final ChatRepo chatRepo;

  GetAllMessagesById(this.chatRepo);

  Future<List<ChatContactDirectory>> call(String userId) {
    return chatRepo.getAllMessagesById(userId);
  }
}
