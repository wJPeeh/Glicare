class MedicationSchedule {
  const MedicationSchedule({
    required this.id,
    required this.name,
    required this.dosage,
    required this.daysOfWeek,
    required this.timesOfDay,
    required this.pushEnabled,
    required this.active,
    required this.createdAt,
    this.pillsPerDose,
    this.pillsRemaining,
    this.prescriberName,
    this.confirmed = true,
  });

  final String id;
  final String name;
  final String dosage;
  final List<int> daysOfWeek;
  final List<int> timesOfDay;
  final bool pushEnabled;
  final bool active;
  final int? pillsPerDose;
  final int? pillsRemaining;
  final DateTime createdAt;

  /// Nome do médico que prescreveu (quando criado pelo painel clínico).
  final String? prescriberName;

  /// Falso enquanto uma prescrição do médico aguarda confirmação do paciente.
  final bool confirmed;

  bool get isPrescribed =>
      prescriberName != null && prescriberName!.trim().isNotEmpty;

  /// Prescrição do médico ainda não confirmada pelo paciente.
  bool get isPendingPrescription => isPrescribed && !confirmed;

  bool get tracksStock =>
      pillsPerDose != null && pillsPerDose! > 0 && pillsRemaining != null;

  int? get daysOfStockRemaining {
    if (!tracksStock || timesOfDay.isEmpty || daysOfWeek.isEmpty) return null;
    final dosesPerWeek = timesOfDay.length * daysOfWeek.length;
    if (dosesPerWeek == 0) return null;
    final dosesRemaining = pillsRemaining! ~/ pillsPerDose!;
    return (dosesRemaining * 7 / dosesPerWeek).round();
  }

  bool occursOn(DateTime day) {
    return active && daysOfWeek.contains(day.weekday);
  }

  MedicationSchedule copyWith({
    String? name,
    String? dosage,
    List<int>? daysOfWeek,
    List<int>? timesOfDay,
    bool? pushEnabled,
    bool? active,
    int? pillsPerDose,
    int? pillsRemaining,
    bool clearStock = false,
    String? prescriberName,
    bool? confirmed,
  }) {
    return MedicationSchedule(
      id: id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      timesOfDay: timesOfDay ?? this.timesOfDay,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      active: active ?? this.active,
      pillsPerDose: clearStock ? null : (pillsPerDose ?? this.pillsPerDose),
      pillsRemaining:
          clearStock ? null : (pillsRemaining ?? this.pillsRemaining),
      createdAt: createdAt,
      prescriberName: prescriberName ?? this.prescriberName,
      confirmed: confirmed ?? this.confirmed,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'dosage': dosage,
        'daysOfWeek': daysOfWeek,
        'timesOfDay': timesOfDay,
        'pushEnabled': pushEnabled,
        'active': active,
        'pillsPerDose': pillsPerDose,
        'pillsRemaining': pillsRemaining,
        'prescriberName': prescriberName,
        'confirmed': confirmed,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory MedicationSchedule.fromSnapshot(String id, Object? raw) {
    final map = raw is Map ? Map<String, dynamic>.from(raw) : const {};
    return MedicationSchedule(
      id: id,
      name: (map['name'] as String?)?.trim().isNotEmpty == true
          ? (map['name'] as String).trim()
          : 'Medicação',
      dosage: (map['dosage'] as String?) ?? '',
      daysOfWeek: _intList(map['daysOfWeek'], fallback: const [1, 2, 3, 4, 5, 6, 7]),
      timesOfDay: _intList(map['timesOfDay']),
      pushEnabled: (map['pushEnabled'] as bool?) ?? false,
      active: (map['active'] as bool?) ?? true,
      pillsPerDose: (map['pillsPerDose'] as num?)?.toInt(),
      pillsRemaining: (map['pillsRemaining'] as num?)?.toInt(),
      prescriberName: (map['prescriberName'] as String?)?.trim().isNotEmpty == true
          ? (map['prescriberName'] as String).trim()
          : null,
      confirmed: (map['confirmed'] as bool?) ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAt'] as num?)?.toInt() ?? 0,
      ),
    );
  }

  static List<int> _intList(Object? raw, {List<int> fallback = const []}) {
    if (raw is! List) return List<int>.from(fallback);
    final values = raw
        .whereType<num>()
        .map((n) => n.toInt())
        .toList()
      ..sort();
    return values.isEmpty ? List<int>.from(fallback) : values;
  }
}

String formatMinutes(int minutes) {
  final h = (minutes ~/ 60).toString().padLeft(2, '0');
  final m = (minutes % 60).toString().padLeft(2, '0');
  return '$h:$m';
}

const Map<int, String> weekdayShortLabels = {
  1: 'Seg',
  2: 'Ter',
  3: 'Qua',
  4: 'Qui',
  5: 'Sex',
  6: 'Sáb',
  7: 'Dom',
};
