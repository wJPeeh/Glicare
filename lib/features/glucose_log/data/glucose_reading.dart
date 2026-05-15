class GlucoseReading {
  const GlucoseReading({
    required this.id,
    required this.valueMgdl,
    required this.measuredAt,
    required this.createdAt,
    this.notes,
  });

  final String id;
  final int valueMgdl;
  final String? notes;
  final DateTime measuredAt;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'valueMgdl': valueMgdl,
        'notes': notes,
        'measuredAt': measuredAt.millisecondsSinceEpoch,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory GlucoseReading.fromSnapshot(String id, Object? raw) {
    final map = raw is Map ? Map<String, dynamic>.from(raw) : const {};
    return GlucoseReading(
      id: id,
      valueMgdl: (map['valueMgdl'] as num?)?.toInt() ?? 0,
      notes: map['notes'] as String?,
      measuredAt: DateTime.fromMillisecondsSinceEpoch(
        (map['measuredAt'] as num?)?.toInt() ?? 0,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAt'] as num?)?.toInt() ?? 0,
      ),
    );
  }
}
