class MedicationLog {
  const MedicationLog({
    required this.id,
    required this.name,
    required this.takenAt,
    required this.createdAt,
    this.dosage,
    this.notes,
    this.scheduleId,
    this.expectedMinute,
  });

  final String id;
  final String name;
  final String? dosage;
  final String? notes;
  final String? scheduleId;
  final int? expectedMinute;
  final DateTime takenAt;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'name': name,
        'dosage': dosage,
        'notes': notes,
        'scheduleId': scheduleId,
        'expectedMinute': expectedMinute,
        'takenAt': takenAt.millisecondsSinceEpoch,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory MedicationLog.fromSnapshot(String id, Object? raw) {
    final map = raw is Map ? Map<String, dynamic>.from(raw) : const {};
    return MedicationLog(
      id: id,
      name: (map['name'] as String?)?.trim().isNotEmpty == true
          ? (map['name'] as String).trim()
          : 'Medicação',
      dosage: map['dosage'] as String?,
      notes: map['notes'] as String?,
      scheduleId: map['scheduleId'] as String?,
      expectedMinute: (map['expectedMinute'] as num?)?.toInt(),
      takenAt: DateTime.fromMillisecondsSinceEpoch(
        (map['takenAt'] as num?)?.toInt() ?? 0,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAt'] as num?)?.toInt() ?? 0,
      ),
    );
  }
}
