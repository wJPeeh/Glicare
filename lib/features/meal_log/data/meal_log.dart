enum MealCategory { cafeManha, almoco, jantar, lanche }

extension MealCategoryLabel on MealCategory {
  String get label => switch (this) {
        MealCategory.cafeManha => 'Café da Manhã',
        MealCategory.almoco => 'Almoço',
        MealCategory.jantar => 'Jantar',
        MealCategory.lanche => 'Lanche',
      };
}

class MealLog {
  const MealLog({
    required this.id,
    required this.category,
    required this.items,
    required this.eatenAt,
    required this.createdAt,
    this.notes,
    this.glucoseMgdl,
  });

  final String id;
  final MealCategory category;
  final List<String> items;
  final String? notes;
  final int? glucoseMgdl;
  final DateTime eatenAt;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'category': category.name,
        'items': items,
        'notes': notes,
        'glucoseMgdl': glucoseMgdl,
        'eatenAt': eatenAt.millisecondsSinceEpoch,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory MealLog.fromSnapshot(String id, Object? raw) {
    final map = raw is Map ? Map<String, dynamic>.from(raw) : const {};
    final rawItems = map['items'];
    final items = rawItems is List
        ? rawItems.map((e) => e.toString()).toList()
        : <String>[];
    return MealLog(
      id: id,
      category: MealCategory.values.firstWhere(
        (c) => c.name == map['category'],
        orElse: () => MealCategory.almoco,
      ),
      items: items,
      notes: map['notes'] as String?,
      glucoseMgdl: (map['glucoseMgdl'] as num?)?.toInt(),
      eatenAt: DateTime.fromMillisecondsSinceEpoch(
        (map['eatenAt'] as num?)?.toInt() ?? 0,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAt'] as num?)?.toInt() ?? 0,
      ),
    );
  }
}
