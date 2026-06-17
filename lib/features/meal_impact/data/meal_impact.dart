import '../../glucose_log/data/glucose_reading.dart';
import '../../meal_log/data/meal_log.dart';

enum ImpactLevel { baixo, moderado, alto, semDados }

extension ImpactLevelLabel on ImpactLevel {
  String get label => switch (this) {
        ImpactLevel.baixo => 'BAIXO',
        ImpactLevel.moderado => 'MODERADO',
        ImpactLevel.alto => 'ALTO',
        ImpactLevel.semDados => 'SEM DADOS',
      };
}

/// Resultado do cruzamento de uma refeição com as medições de glicemia ao
/// redor dela. Tudo aqui é derivado de dados reais do usuário.
class MealImpact {
  const MealImpact({
    required this.level,
    required this.baselineMgdl,
    required this.peakMgdl,
    required this.deltaMgdl,
    required this.minutesToPeak,
    required this.window,
  });

  /// Glicemia antes da refeição (medição mais próxima anterior, ou a glicemia
  /// registrada junto da própria refeição).
  final int? baselineMgdl;

  /// Maior glicemia medida na janela pós-refeição.
  final int? peakMgdl;

  /// Variação pico - baseline (null se faltar baseline ou pico).
  final int? deltaMgdl;

  /// Minutos entre a refeição e o pico.
  final int? minutesToPeak;

  final ImpactLevel level;

  /// Medições usadas no mini-gráfico (ordem cronológica).
  final List<GlucoseReading> window;

  bool get hasData => deltaMgdl != null;

  static const empty = MealImpact(
    level: ImpactLevel.semDados,
    baselineMgdl: null,
    peakMgdl: null,
    deltaMgdl: null,
    minutesToPeak: null,
    window: [],
  );
}

const Duration _preWindow = Duration(hours: 2);
const Duration _postWindow = Duration(hours: 3);

/// Calcula o impacto glicêmico de [meal] a partir de [readings].
MealImpact computeMealImpact(MealLog meal, List<GlucoseReading> readings) {
  final eatenAt = meal.eatenAt;
  final preStart = eatenAt.subtract(_preWindow);
  final postEnd = eatenAt.add(_postWindow);

  // Baseline: medição mais próxima antes (ou no momento) da refeição.
  GlucoseReading? baselineReading;
  for (final r in readings) {
    if (!r.measuredAt.isAfter(eatenAt) && !r.measuredAt.isBefore(preStart)) {
      if (baselineReading == null ||
          r.measuredAt.isAfter(baselineReading.measuredAt)) {
        baselineReading = r;
      }
    }
  }
  // Fallback: glicemia anotada junto da refeição.
  final baseline = baselineReading?.valueMgdl ?? meal.glucoseMgdl;

  // Janela pós-refeição.
  final post = readings
      .where((r) => r.measuredAt.isAfter(eatenAt) && !r.measuredAt.isAfter(postEnd))
      .toList()
    ..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));

  GlucoseReading? peakReading;
  for (final r in post) {
    if (peakReading == null || r.valueMgdl > peakReading.valueMgdl) {
      peakReading = r;
    }
  }

  // Janela do gráfico: baseline (se houver) + medições pós.
  final window = <GlucoseReading>[
    if (baselineReading != null) baselineReading,
    ...post,
  ];

  if (baseline == null || peakReading == null) {
    return MealImpact(
      level: ImpactLevel.semDados,
      baselineMgdl: baseline,
      peakMgdl: peakReading?.valueMgdl,
      deltaMgdl: null,
      minutesToPeak: null,
      window: window,
    );
  }

  final delta = peakReading.valueMgdl - baseline;
  final minutesToPeak = peakReading.measuredAt.difference(eatenAt).inMinutes;

  return MealImpact(
    level: _levelFor(delta),
    baselineMgdl: baseline,
    peakMgdl: peakReading.valueMgdl,
    deltaMgdl: delta,
    minutesToPeak: minutesToPeak,
    window: window,
  );
}

ImpactLevel _levelFor(int delta) {
  if (delta < 30) return ImpactLevel.baixo;
  if (delta <= 60) return ImpactLevel.moderado;
  return ImpactLevel.alto;
}
