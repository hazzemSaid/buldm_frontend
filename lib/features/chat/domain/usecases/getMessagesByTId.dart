// features/chat/domain/usecases/getMessagesByTId.dart
import 'package:buldm/features/chat/data/models/MessageModel.dart';
import 'package:buldm/features/chat/domain/repo/chatrepo.dart';

class GetMessagesByTId {
  final ChatRepo chatRepo;

  GetMessagesByTId(this.chatRepo);

  Future<List<MessageModel>> call(String userid1, String userid2) {
    return chatRepo.getMessagesByTId(userid1, userid2);
  }
}
