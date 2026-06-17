/// Dados da equipe de saúde / vínculo SUS do paciente.
///
/// Persistido em `users/$uid/care_team`. Tanto o app do paciente quanto o
/// painel web do médico leem desta mesma estrutura.
class CareTeam {
  const CareTeam({
    this.connected = false,
    this.ubsName,
    this.ubsNetwork,
    this.susCard,
    this.bond,
    this.doctorName,
    this.doctorSpecialty,
    this.doctorCrm,
    this.doctorLocation,
    this.shareEnabled = true,
    this.shareGlucose = true,
    this.shareMedication = true,
    this.shareMeals = true,
    this.accessCode,
    this.updatedAt,
  });

  /// Código curto (6 caracteres) que o paciente compartilha com o médico.
  final String? accessCode;

  /// Se o paciente declarou vínculo ativo com uma unidade de saúde.
  final bool connected;

  final String? ubsName;
  final String? ubsNetwork;
  final String? susCard;
  final String? bond;

  final String? doctorName;
  final String? doctorSpecialty;
  final String? doctorCrm;
  final String? doctorLocation;

  /// Chave-mestra de compartilhamento com a equipe.
  final bool shareEnabled;
  final bool shareGlucose;
  final bool shareMedication;
  final bool shareMeals;

  final DateTime? updatedAt;

  bool get hasUbs => (ubsName?.trim().isNotEmpty ?? false);
  bool get hasDoctor => (doctorName?.trim().isNotEmpty ?? false);
  bool get isConfigured => connected || hasUbs || hasDoctor;

  CareTeam copyWith({
    bool? connected,
    String? ubsName,
    String? ubsNetwork,
    String? susCard,
    String? bond,
    String? doctorName,
    String? doctorSpecialty,
    String? doctorCrm,
    String? doctorLocation,
    bool? shareEnabled,
    bool? shareGlucose,
    bool? shareMedication,
    bool? shareMeals,
    String? accessCode,
    DateTime? updatedAt,
  }) {
    return CareTeam(
      connected: connected ?? this.connected,
      ubsName: ubsName ?? this.ubsName,
      ubsNetwork: ubsNetwork ?? this.ubsNetwork,
      susCard: susCard ?? this.susCard,
      bond: bond ?? this.bond,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      doctorCrm: doctorCrm ?? this.doctorCrm,
      doctorLocation: doctorLocation ?? this.doctorLocation,
      shareEnabled: shareEnabled ?? this.shareEnabled,
      shareGlucose: shareGlucose ?? this.shareGlucose,
      shareMedication: shareMedication ?? this.shareMedication,
      shareMeals: shareMeals ?? this.shareMeals,
      accessCode: accessCode ?? this.accessCode,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'connected': connected,
        'ubsName': _clean(ubsName),
        'ubsNetwork': _clean(ubsNetwork),
        'susCard': _clean(susCard),
        'bond': _clean(bond),
        'doctorName': _clean(doctorName),
        'doctorSpecialty': _clean(doctorSpecialty),
        'doctorCrm': _clean(doctorCrm),
        'doctorLocation': _clean(doctorLocation),
        'shareEnabled': shareEnabled,
        'shareGlucose': shareGlucose,
        'shareMedication': shareMedication,
        'shareMeals': shareMeals,
        'accessCode': _clean(accessCode),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

  factory CareTeam.fromSnapshot(Object? raw) {
    if (raw is! Map) return const CareTeam();
    final map = Map<String, dynamic>.from(raw);
    return CareTeam(
      connected: (map['connected'] as bool?) ?? false,
      ubsName: _readString(map['ubsName']),
      ubsNetwork: _readString(map['ubsNetwork']),
      susCard: _readString(map['susCard']),
      bond: _readString(map['bond']),
      doctorName: _readString(map['doctorName']),
      doctorSpecialty: _readString(map['doctorSpecialty']),
      doctorCrm: _readString(map['doctorCrm']),
      doctorLocation: _readString(map['doctorLocation']),
      shareEnabled: (map['shareEnabled'] as bool?) ?? true,
      shareGlucose: (map['shareGlucose'] as bool?) ?? true,
      shareMedication: (map['shareMedication'] as bool?) ?? true,
      shareMeals: (map['shareMeals'] as bool?) ?? true,
      accessCode: _readString(map['accessCode']),
      updatedAt: map['updatedAt'] is num
          ? DateTime.fromMillisecondsSinceEpoch((map['updatedAt'] as num).toInt())
          : null,
    );
  }

  static String? _clean(String? v) {
    final t = v?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }

  static String? _readString(Object? v) {
    if (v is! String) return null;
    final t = v.trim();
    return t.isEmpty ? null : t;
  }
}
