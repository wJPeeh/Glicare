enum CareNoteType { dica, cuidado }

extension CareNoteTypeLabel on CareNoteType {
  String get label => switch (this) {
        CareNoteType.dica => 'Dica',
        CareNoteType.cuidado => 'Cuidado',
      };
}

/// Orientação escrita pelo médico (dica ou cuidado) e exibida no app do
/// paciente. Persistido em `users/$uid/care_notes`.
class CareNote {
  const CareNote({
    required this.id,
    required this.text,
    required this.type,
    required this.authorName,
    required this.createdAt,
  });

  final String id;
  final String text;
  final CareNoteType type;
  final String authorName;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'text': text,
        'type': type.name,
        'authorName': authorName,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory CareNote.fromSnapshot(String id, Object? raw) {
    final map = raw is Map ? Map<String, dynamic>.from(raw) : const {};
    return CareNote(
      id: id,
      text: (map['text'] as String?)?.trim() ?? '',
      type: CareNoteType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => CareNoteType.dica,
      ),
      authorName: (map['authorName'] as String?)?.trim().isNotEmpty == true
          ? (map['authorName'] as String).trim()
          : 'Equipe de saúde',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAt'] as num?)?.toInt() ?? 0,
      ),
    );
  }
}
