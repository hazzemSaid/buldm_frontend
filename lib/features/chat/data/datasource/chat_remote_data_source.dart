import 'package:buldm/features/chat/data/models/contacntListmodel.dart';
import 'package:dio/dio.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatContactDirectory>> getAllMessagesById(String userId);
  Future<List<ChatContactDirectory>> getMessagesByTId(
      String userid1, String userid2);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio dio;
  ChatRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ChatContactDirectory>> getAllMessagesById(String userId) async {
    try {
      final response = await dio.get('/chat/users/$userId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        return data
            .map<ChatContactDirectory>(
                (json) => ChatContactDirectory.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      throw Exception('Error fetching messages: $e');
    }
  }

  @override
  Future<List<ChatContactDirectory>> getMessagesByTId(
      String userid1, String userid2) async {
    try {
      final response = await dio.get('/chat/users/$userid1/$userid2');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        return data
            .map<ChatContactDirectory>(
                (json) => ChatContactDirectory.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      throw Exception('Error fetching messages: $e');
    }
  }
}
