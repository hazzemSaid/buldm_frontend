import 'package:buldm/core/Dependency_njection/service_locator.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final Dio _dio = sl<Dio>();

  /// Send a chat notification and return true if sent successfully, false otherwise
  Future<bool> sendChatNotification({
    required String toPlayerId,
    required String title,
    required String message,
    required Map<String, dynamic> sender,
  }) async {
    final url = '/notification';

    final senderId = (sender['id'] as String?) ?? '';
    final senderName = (sender['name'] as String?) ?? 'User';
    final senderAvatar = (sender['avatar'] as String?) ?? '';

    final androidChannelId = dotenv.env['ONESIGNAL_ANDROID_CHAT_CHANNEL_ID'];
    final payload = {
      'title': title,
      'message': message,
      'token': toPlayerId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'android_channel_id': androidChannelId,
      'android_sound': 'sound', // اسم ملف الصوت في res/raw بدون .mp3
      'data': {
        'type': 'chat',
        'senderId': senderId,
        'senderName': senderName,
        'senderAvatar': senderAvatar,
        'deeplink': '/chat',
      }
    };

    try {
      final fullUrl = url;
      final res = await _dio.post(
        url,
        data: payload,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (res.statusCode != null &&
          res.statusCode! >= 200 &&
          res.statusCode! < 300) {
        print('✅ Notification sent successfully -> $fullUrl');
        return true;
      } else {
        print(
            '⚠️ Notification failed with status ${res.statusCode} -> $fullUrl');
        return false;
      }
    } catch (e) {
      if (e is DioException) {
        final status = e.response?.statusCode;
        final data = e.response?.data;
        print(
            '❌ Notification POST failed (${status ?? 'no-status'}): ${data ?? e.message}');
      } else {
        print('❌ Notification POST failed: $e');
      }
      return false;
    }
  }
}
