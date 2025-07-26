// features/chat/data/repo/chatrepoimp.dart
import 'package:buldm/features/chat/data/datasource/chat_remote_data_source.dart';
import 'package:buldm/features/chat/data/models/contacntListmodel.dart';
import 'package:buldm/features/chat/data/models/MessageModel.dart';
import 'package:buldm/features/chat/domain/repo/chatrepo.dart';

class ChatRepoImpl implements ChatRepo {
  final ChatRemoteDataSource chatRemoteDataSource;

  ChatRepoImpl(this.chatRemoteDataSource);

  @override
  Future<List<ChatContactDirectory>> getAllMessagesById(String userId) {
    return chatRemoteDataSource.getAllMessagesById(userId);
  }

  @override
  Future<List<MessageModel>> getMessagesByTId(String userid1, String userid2) {
    return chatRemoteDataSource.getMessagesByTId(userid1, userid2);
  }
}
