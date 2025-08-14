import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buldm/features/chat/data/models/MessageModel.dart';
import 'package:buldm/features/chat/data/models/contacntListmodel.dart';

class FirebaseChatService {
  FirebaseChatService._();
  static final FirebaseChatService instance = FirebaseChatService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Deterministic chat id for two users
  String chatIdFor(String a, String b) {
    return (a.compareTo(b) <= 0) ? '${a}_$b' : '${b}_$a';
  }

  // Stream per-user chat summaries (for chat list UI)
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

        // Adapt to existing ChatContactDirectory by synthesizing a single last message
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

  // Stream full messages for a conversation
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

  // Send message and update chat summaries for both users
  Future<void> sendMessage({
    required String from,
    required String to,
    required String text,
  }) async {
    final chatId = chatIdFor(from, to);
    final chatRef = _db.collection('chats').doc(chatId);
    final msgRef = chatRef.collection('messages').doc();
    final now = FieldValue.serverTimestamp();

    await _db.runTransaction((txn) async {
      // Create chat doc if missing
      final chatSnap = await txn.get(chatRef);
      if (!chatSnap.exists) {
        txn.set(chatRef, {
          'members': [from, to],
          'createdAt': now,
        });
      }

      // Add message
      txn.set(msgRef, {
        'message': text,
        'from': from,
        'to': to,
        'timestamp': now,
      });

      // Update per-user chat summaries
      final userFromChat = _db
          .collection('users')
          .doc(from)
          .collection('chats')
          .doc(chatId);
      final userToChat = _db
          .collection('users')
          .doc(to)
          .collection('chats')
          .doc(chatId);

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
  }

  // Mark conversation read by user (optional)
  Future<void> markConversationRead({
    required String uid,
    required String otherUid,
  }) async {
    final chatId = chatIdFor(uid, otherUid);
    final doc = _db
        .collection('users')
        .doc(uid)
        .collection('chats')
        .doc(chatId);
    await doc.set({'unreadCount': 0}, SetOptions(merge: true));
  }
}
