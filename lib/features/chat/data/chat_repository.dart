import 'package:firebase_database/firebase_database.dart';

import 'chat_message.dart';

class ChatRepository {
  ChatRepository(this._db);

  final FirebaseDatabase _db;

  DatabaseReference _ref(String uid) => _db.ref('users/$uid/chat');

  Stream<List<ChatMessage>> watch(String uid, {int limit = 200}) {
    return _ref(uid)
        .orderByChild('createdAt')
        .limitToLast(limit)
        .onValue
        .map((event) {
      final raw = event.snapshot.value;
      if (raw is! Map) return <ChatMessage>[];
      return raw.entries
          .map((e) => ChatMessage.fromSnapshot(e.key as String, e.value))
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    });
  }

  Future<void> send({
    required String uid,
    required ChatSender sender,
    required String text,
    required String authorName,
  }) {
    final msg = ChatMessage(
      id: '',
      sender: sender,
      text: text.trim(),
      authorName: authorName,
      createdAt: DateTime.now(),
    );
    return _ref(uid).push().set(msg.toJson());
  }
}
