import 'package:buldm/core/notifications/notification_service.dart';
import 'package:buldm/features/chat/data/models/MessageModel.dart';
import 'package:buldm/features/chat/data/models/contacntListmodel.dart';
import 'package:buldm/features/profile/presentation/view/screens/OtherUserProfileScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseChatService {
  FirebaseChatService._();
  static final FirebaseChatService instance = FirebaseChatService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String chatIdFor(String a, String b) {
    return (a.compareTo(b) <= 0) ? '${a}_$b' : '${b}_$a';
  }

  Stream<List<ChatContactDirectory>> streamUserChats(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('chats')
        .orderBy('lastTimestamp', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((d) {
        final data = d.data();
        final otherId = data['otherUserId'] as String;
        final lastMsg = data['lastMessage'] as String?;
        final lastTs = (data['lastTimestamp'] as Timestamp?);

        final messages = <MessageModel>[];
        if (lastMsg != null) {
          messages.add(
            MessageModel(
              message: lastMsg,
              from: data['lastFrom'] as String? ?? otherId,
              to: data['lastTo'] as String? ?? uid,
              timestamp: lastTs?.toDate(),
              id: d.id,
            ),
          );
        }

        return ChatContactDirectory(
          user: otherId,
          messages: messages,
          lastActivity: lastTs?.toDate(),
        );
      }).toList();
    });
  }

  Stream<List<MessageModel>> streamMessages(String uidA, String uidB) {
    final chatId = chatIdFor(uidA, uidB);
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              return MessageModel(
                message: data['message'] as String,
                from: data['from'] as String,
                to: data['to'] as String,
                timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
                id: d.id,
              );
            }).toList());
  }

  Future<void> sendMessage({
    required String from,
    required String to,
    required String text,
    required ViewerUser fromUser,
    required ViewerUser toUser,
  }) async {
    final chatId = chatIdFor(from, to);
    final chatRef = _db.collection('chats').doc(chatId);
    final msgRef = chatRef.collection('messages').doc();
    final now = FieldValue.serverTimestamp();

    await _db.runTransaction((txn) async {
      final chatSnap = await txn.get(chatRef);
      if (!chatSnap.exists) {
        txn.set(chatRef, {
          'members': [from, to],
          'createdAt': now,
        });
      }

      txn.set(msgRef, {
        'message': text,
        'from': from,
        'to': to,
        'timestamp': now,
      });

      final userFromChat =
          _db.collection('users').doc(from).collection('chats').doc(chatId);
      final userToChat =
          _db.collection('users').doc(to).collection('chats').doc(chatId);

      final summary = {
        'otherUserId': to,
        'lastMessage': text,
        'lastTimestamp': now,
        'lastFrom': from,
        'lastTo': to,
      };
      final summaryReverse = {
        'otherUserId': from,
        'lastMessage': text,
        'lastTimestamp': now,
        'lastFrom': from,
        'lastTo': to,
      };

      txn.set(userFromChat, summary, SetOptions(merge: true));
      txn.set(userToChat, summaryReverse, SetOptions(merge: true));
    });

    // إرسال الإشعار إذا المستقبل مش فاتح المحادثة
    try {
      final toDoc = await _db.collection('users').doc(to).get();
      // final fromDoc = await _db.collection('users').doc(from).get();
      final toData = toDoc.data() ?? {};

      if (toData['activeChatWith'] != from) {
        String? playerId = toData['onesignal_player_id'] as String?;
        playerId ??= toData['oneSignalPlayerId'] as String?;
        playerId ??= toData['playerId'] as String?;

        if (playerId == null || playerId.isEmpty) {
          print('⚠️ No OneSignal playerId for user $to. Skipping push.');
          return;
        }

        // Prefer domain user via usecase (through UserBloc layer)
        // User? fromUser;
        // try {
        //   final usecase = sl<Getuserbyid>();
        //   fromUser = await usecase(from);
        // } catch (_) {}

        // final fromData = fromDoc.data() ?? {};
        // String senderName = fromUser?.name ??
        //     (fromData['name'] as String?) ??
        //     (fromData['fullName'] as String?) ??
        //     (fromData['username'] as String?) ??
        //     'New message';
        // String senderAvatar = fromUser?.avatar ??
        //     (fromData['avatar'] as String?) ??
        //     (fromData['image'] as String?) ??
        //     (fromData['photoUrl'] as String?) ??
        //     '';

        print('➡️ Sending push to $to with playerId=$playerId');

        final success = await NotificationService.instance.sendChatNotification(
          toPlayerId: playerId,
          title: fromUser.name,
          message: text,
          sender: {
            'id': from,
            'name': fromUser.name,
            'avatar': fromUser.avatar,
          },
        );

        if (success) {
          print("📨 Notification delivered successfully");
        } else {
          print("🚫 Notification not sent");
        }
      } else {
        print('ℹ️ Skipping push: $to is in chat with $from');
      }
    } catch (e) {
      print('⚠️ Notification send flow error: ' + e.toString());
    }
  }

  Future<void> markConversationRead({
    required String uid,
    required String otherUid,
  }) async {
    final chatId = chatIdFor(uid, otherUid);
    final doc =
        _db.collection('users').doc(uid).collection('chats').doc(chatId);
    await doc.set({'unreadCount': 0}, SetOptions(merge: true));
  }
}
