import 'dart:math' as math;

import '../../glucose_log/data/glucose_reading.dart';

enum GlucoseRange { hipo, normal, elevada, hiper }

GlucoseRange rangeFor(int valueMgdl) {
  if (valueMgdl < 70) return GlucoseRange.hipo;
  if (valueMgdl <= 140) return GlucoseRange.normal;
  if (valueMgdl <= 180) return GlucoseRange.elevada;
  return GlucoseRange.hiper;
}

extension GlucoseRangeLabel on GlucoseRange {
  String get label => switch (this) {
        GlucoseRange.hipo => 'HIPO',
        GlucoseRange.normal => 'NORMAL',
        GlucoseRange.elevada => 'ELEVADA',
        GlucoseRange.hiper => 'HIPER',
      };
}

enum TrendDirection { melhorando, estavel, piorando, semDados }

extension TrendDirectionLabel on TrendDirection {
  String get label => switch (this) {
        TrendDirection.melhorando => 'MELHORANDO',
        TrendDirection.estavel => 'ESTÁVEL',
        TrendDirection.piorando => 'EM ALTA',
        TrendDirection.semDados => 'SEM DADOS',
      };
}

class GlucoseStats {
  const GlucoseStats({
    required this.count,
    required this.average,
    required this.min,
    required this.max,
    required this.stdDev,
    required this.timeInRangePct,
    required this.trend,
    required this.slopePerDay,
    required this.deltaFromPrevious,
  });

  /// Quantidade de leituras consideradas.
  final int count;

  /// Média em mg/dL (0 se sem dados).
  final double average;

  final int min;
  final int max;

  /// Desvio padrão amostral (0 se < 2 pontos).
  final double stdDev;

  /// Percentual de leituras na faixa normal (70-140) [0..100].
  final double timeInRangePct;

  final TrendDirection trend;

  /// Inclinação da regressão linear em mg/dL por dia.
  final double slopePerDay;

  /// Diferença em mg/dL vs período anterior do mesmo tamanho (null se insuficiente).
  final double? deltaFromPrevious;

  bool get hasData => count > 0;

  static const empty = GlucoseStats(
    count: 0,
    average: 0,
    min: 0,
    max: 0,
    stdDev: 0,
    timeInRangePct: 0,
    trend: TrendDirection.semDados,
    slopePerDay: 0,
    deltaFromPrevious: null,
  );
}

/// Filtra leituras dentro de [days] dias a partir de [now], e calcula estatísticas.
GlucoseStats computeStats(
  List<GlucoseReading> readings, {
  required int days,
  DateTime? now,
}) {
  final reference = now ?? DateTime.now();
  final cutoff = reference.subtract(Duration(days: days));
  final inRange = readings
      .where((r) => r.measuredAt.isAfter(cutoff))
      .toList(growable: false);
  if (inRange.isEmpty) return GlucoseStats.empty;

  final values = inRange.map((r) => r.valueMgdl).toList(growable: false);
  final sum = values.fold<int>(0, (a, b) => a + b);
  final avg = sum / values.length;
  final minV = values.reduce(math.min);
  final maxV = values.reduce(math.max);

  double stdDev = 0;
  if (values.length > 1) {
    final variance = values
            .map((v) => math.pow(v - avg, 2).toDouble())
            .fold<double>(0, (a, b) => a + b) /
        (values.length - 1);
    stdDev = math.sqrt(variance);
  }

  final inTarget = values.where((v) => v >= 70 && v <= 140).length;
  final tirPct = (inTarget / values.length) * 100;

  final slope = _slopePerDay(inRange);
  final trend = _classifyTrend(slope, stdDev);

  final previousCutoff = cutoff.subtract(Duration(days: days));
  final previous = readings
      .where((r) =>
          r.measuredAt.isAfter(previousCutoff) &&
          !r.measuredAt.isAfter(cutoff))
      .toList(growable: false);
  double? delta;
  if (previous.isNotEmpty) {
    final prevAvg =
        previous.fold<int>(0, (a, b) => a + b.valueMgdl) / previous.length;
    delta = avg - prevAvg;
  }

  return GlucoseStats(
    count: values.length,
    average: avg,
    min: minV,
    max: maxV,
    stdDev: stdDev,
    timeInRangePct: tirPct,
    trend: trend,
    slopePerDay: slope,
    deltaFromPrevious: delta,
  );
}

double _slopePerDay(List<GlucoseReading> readings) {
  if (readings.length < 2) return 0;
  final ms = readings.map((r) => r.measuredAt.millisecondsSinceEpoch).toList();
  final base = ms.reduce(math.min);
  final xs =
      ms.map((m) => (m - base) / Duration.millisecondsPerDay).toList();
  final ys = readings.map((r) => r.valueMgdl.toDouble()).toList();
  final n = xs.length;
  final meanX = xs.fold<double>(0, (a, b) => a + b) / n;
  final meanY = ys.fold<double>(0, (a, b) => a + b) / n;
  double num = 0;
  double den = 0;
  for (var i = 0; i < n; i++) {
    final dx = xs[i] - meanX;
    num += dx * (ys[i] - meanY);
    den += dx * dx;
  }
  if (den == 0) return 0;
  return num / den;
}

TrendDirection _classifyTrend(double slopePerDay, double stdDev) {
  if (slopePerDay.abs() < 1.5) return TrendDirection.estavel;
  if (slopePerDay < 0) return TrendDirection.melhorando;
  return TrendDirection.piorando;
}

/// Gera frase curta para o card de IA do dashboard.
String buildHeadline(GlucoseStats stats) {
  if (!stats.hasData) {
    return 'Registre algumas medições para ver insights.';
  }
  final avg = stats.average.round();
  switch (stats.trend) {
    case TrendDirection.melhorando:
      return 'Tendência de melhora — média de $avg mg/dL nos últimos dias.';
    case TrendDirection.piorando:
      return 'Atenção: glicemia em alta — média de $avg mg/dL.';
    case TrendDirection.estavel:
      return 'Glicemia estável em torno de $avg mg/dL.';
    case TrendDirection.semDados:
      return 'Registre algumas medições para ver insights.';
  }
}

/// Mensagem complementar baseada em time-in-range e estabilidade.
String? buildSecondaryInsight(GlucoseStats stats) {
  if (!stats.hasData) return null;
  if (stats.count < 3) {
    return 'Poucos dados ainda — registre mais medições para análises melhores.';
  }
  if (stats.timeInRangePct >= 70) {
    return '${stats.timeInRangePct.toStringAsFixed(0)}% das medições dentro da faixa alvo (70–140).';
  }
  if (stats.stdDev > 35) {
    return 'Variabilidade elevada — suas medições oscilam bastante (DP ${stats.stdDev.toStringAsFixed(0)}).';
  }
  return '${stats.timeInRangePct.toStringAsFixed(0)}% das medições dentro da faixa alvo.';
}
