import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../glucose_log/presentation/glucose_providers.dart';
import '../data/glucose_analytics.dart';

/// Estatísticas para o período selecionado em /charts.
final glucoseStatsProvider =
    Provider.family<AsyncValue<GlucoseStats>, int>((ref, days) {
  final readings = ref.watch(recentGlucoseReadingsProvider);
  return readings.whenData((list) => computeStats(list, days: days));
});

/// Estatísticas dos últimos 7 dias para o card de IA do dashboard.
final dashboardGlucoseStatsProvider = Provider<AsyncValue<GlucoseStats>>(
  (ref) => ref.watch(glucoseStatsProvider(7)),
);
