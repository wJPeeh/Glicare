enum ActivityType { caminhada, corrida, musculacao, bike, outro }

extension ActivityTypeLabel on ActivityType {
  String get label => switch (this) {
        ActivityType.caminhada => 'Caminhada',
        ActivityType.corrida => 'Corrida',
        ActivityType.musculacao => 'Musculação',
        ActivityType.bike => 'Bike',
        ActivityType.outro => 'Outro',
      };
}

class ActivityLog {
  const ActivityLog({
    required this.id,
    required this.type,
    required this.durationMinutes,
    required this.performedAt,
    required this.createdAt,
    this.notes,
  });

  final String id;
  final ActivityType type;
  final int durationMinutes;
  final String? notes;
  final DateTime performedAt;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'durationMinutes': durationMinutes,
        'notes': notes,
        'performedAt': performedAt.millisecondsSinceEpoch,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory ActivityLog.fromSnapshot(String id, Object? raw) {
    final map = raw is Map ? Map<String, dynamic>.from(raw) : const {};
    return ActivityLog(
      id: id,
      type: ActivityType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => ActivityType.outro,
      ),
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 0,
      notes: map['notes'] as String?,
      performedAt: DateTime.fromMillisecondsSinceEpoch(
        (map['performedAt'] as num?)?.toInt() ?? 0,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAt'] as num?)?.toInt() ?? 0,
      ),
    );
  }
}
