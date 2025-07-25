import 'package:buldm/features/chat/data/models/contacntListmodel.dart'
    show ChatContactDirectory;
import 'package:buldm/features/chat/domain/repo/chatrepo.dart' show ChatRepo;

class GetMessagesByTId {
  final ChatRepo chatRepo;

  GetMessagesByTId(this.chatRepo);

  Future<List<ChatContactDirectory>> call(String userid1, String userid2) {
    return chatRepo.getMessagesByTId(userid1, userid2);
  }
}
