enum ChatSender { doctor, patient }

/// Mensagem do chat entre paciente e equipe de saúde.
/// Persistido em `users/$uid/chat`.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.authorName,
    required this.createdAt,
  });

  final String id;
  final ChatSender sender;
  final String text;
  final String authorName;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'sender': sender.name,
        'text': text,
        'authorName': authorName,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory ChatMessage.fromSnapshot(String id, Object? raw) {
    final map = raw is Map ? Map<String, dynamic>.from(raw) : const {};
    return ChatMessage(
      id: id,
      sender: ChatSender.values.firstWhere(
        (s) => s.name == map['sender'],
        orElse: () => ChatSender.patient,
      ),
      text: (map['text'] as String?)?.trim() ?? '',
      authorName: (map['authorName'] as String?)?.trim() ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAt'] as num?)?.toInt() ?? 0,
      ),
    );
  }
}
