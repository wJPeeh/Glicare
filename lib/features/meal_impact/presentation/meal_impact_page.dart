import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../core/widgets/glicare_app_bar.dart';
import '../../glucose_log/data/glucose_reading.dart';
import '../../glucose_log/presentation/glucose_providers.dart';
import '../../meal_log/data/meal_log.dart';
import '../../meal_log/presentation/meal_log_providers.dart';
import '../data/meal_impact.dart';

class MealImpactPage extends ConsumerWidget {
  const MealImpactPage({super.key, this.mealId});

  /// Refeição a analisar. Se nulo, usa a refeição mais recente.
  final String? mealId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealsAsync = ref.watch(recentMealLogsProvider);
    final readings =
        ref.watch(recentGlucoseReadingsProvider).asData?.value ??
            const <GlucoseReading>[];

    return Scaffold(
      appBar: GlicareAppBar(
        title: 'Alimentação & Glicemia',
        action: const Icon(Icons.share_outlined,
            color: AppColors.onSurfaceVariant),
      ),
      bottomNavigationBar: GlicareBottomNav(
        activeIndex: 1,
        onTap: (i) => glicareRootNavTap(context, i),
      ),
      body: mealsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _Message(
          icon: Icons.error_outline,
          title: 'Não foi possível carregar',
          subtitle: '$e',
        ),
        data: (meals) {
          if (meals.isEmpty) {
            return const _Message(
              icon: Icons.restaurant,
              title: 'Nenhuma refeição registrada',
              subtitle:
                  'Registre uma refeição para ver o impacto dela na sua glicemia.',
            );
          }
          final meal = mealId == null
              ? meals.first
              : meals.firstWhere(
                  (m) => m.id == mealId,
                  orElse: () => meals.first,
                );
          final impact = computeMealImpact(meal, readings);
          return _ImpactBody(meal: meal, impact: impact);
        },
      ),
    );
  }
}

class _ImpactBody extends StatelessWidget {
  const _ImpactBody({required this.meal, required this.impact});

  final MealLog meal;
  final MealImpact impact;

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(impact.level);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${_dayLabel(meal.eatenAt)} • ${meal.category.label} (${DateFormat('HH:mm').format(meal.eatenAt)})',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('dd/MM').format(meal.eatenAt),
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Impacto na Glicemia',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 24),

          // Itens consumidos (dados reais da refeição).
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(36),
              boxShadow: AppColors.softShadow(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Itens Consumidos',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                if (meal.items.isEmpty)
                  Text(
                    'Nenhum item detalhado nesta refeição.',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  )
                else
                  for (var i = 0; i < meal.items.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    _FoodLine(name: meal.items[i]),
                  ],
                if (meal.notes != null && meal.notes!.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    color: AppColors.outlineVariant.withValues(alpha: 0.15),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.notes,
                          size: 16, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          meal.notes!,
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Impacto na glicemia (calculado das medições reais).
          if (impact.hasData)
            _ImpactCard(impact: impact, accent: accent)
          else
            _NoImpactCard(impact: impact),

          if (impact.hasData) ...[
            const SizedBox(height: 16),
            _PeakCard(impact: impact),
            const SizedBox(height: 32),
            _TipCard(impact: impact),
          ],
        ],
      ),
    );
  }

  Color _accentFor(ImpactLevel level) => switch (level) {
        ImpactLevel.baixo => AppColors.secondary,
        ImpactLevel.moderado => AppColors.tertiary,
        ImpactLevel.alto => AppColors.error,
        ImpactLevel.semDados => AppColors.onSurfaceVariant,
      };

  String _dayLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(dt.year, dt.month, dt.day);
    if (d == today) return 'Hoje';
    if (d == today.subtract(const Duration(days: 1))) return 'Ontem';
    try {
      return DateFormat("d 'de' MMM", 'pt_BR').format(dt);
    } catch (_) {
      return DateFormat('dd/MM').format(dt);
    }
  }
}

class _ImpactCard extends StatelessWidget {
  const _ImpactCard({required this.impact, required this.accent});

  final MealImpact impact;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final window = impact.window;
    final values = window.map((r) => r.valueMgdl).toList();
    final maxV = values.isEmpty ? 1 : values.reduce((a, b) => a > b ? a : b);
    final minV = values.isEmpty ? 0 : values.reduce((a, b) => a < b ? a : b);
    final peakValue = impact.peakMgdl;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(36),
        boxShadow: AppColors.softShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'IMPACTO NA GLICEMIA',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1.6,
                ),
              ),
              const Spacer(),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              impact.level.label,
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: accent,
                letterSpacing: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(impact.deltaMgdl ?? 0) >= 0 ? '+' : ''}${impact.deltaMgdl}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  color: accent,
                  letterSpacing: -2,
                  height: 1,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'mg/dL',
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (window.length >= 2) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final r in window)
                  _ImpactBar(
                    height: _barHeight(r.valueMgdl, minV, maxV),
                    color: r.valueMgdl == peakValue
                        ? accent
                        : AppColors.surfaceContainerHigh,
                  ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Center(
            child: Text(
              impact.minutesToPeak != null
                  ? 'Pico aos ${impact.minutesToPeak} min após a refeição'
                  : 'Baseline ${impact.baselineMgdl} → pico ${impact.peakMgdl} mg/dL',
              style: GoogleFonts.manrope(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _barHeight(int value, int minV, int maxV) {
    if (maxV == minV) return 48;
    final t = (value - minV) / (maxV - minV);
    return 24 + t * 56; // 24..80
  }
}

class _PeakCard extends StatelessWidget {
  const _PeakCard({required this.impact});

  final MealImpact impact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(36),
        boxShadow: AppColors.primaryGlow(opacity: 0.2),
      ),
      child: Row(
        children: [
          const Icon(Icons.bloodtype, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Glicemia no pico',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${impact.peakMgdl}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        'mg/dL',
                        style: GoogleFonts.manrope(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            'Baseline ${impact.baselineMgdl}',
            style: GoogleFonts.manrope(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.impact});

  final MealImpact impact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.lightbulb, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dica Personalizada',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _tipFor(impact.level),
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    height: 1.5,
                    color:
                        AppColors.onSecondaryContainer.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _tipFor(ImpactLevel level) => switch (level) {
        ImpactLevel.baixo =>
          'Ótimo! Esta refeição teve impacto baixo na sua glicemia. Combinações com proteínas e fibras ajudam a manter esse padrão.',
        ImpactLevel.moderado =>
          'Impacto moderado. Para um pico menor, experimente iniciar pela salada/legumes e reduzir a porção de carboidratos simples.',
        ImpactLevel.alto =>
          'Impacto alto. Vale revisar a quantidade de carboidratos e priorizar fibras e proteínas. Se isso se repetir, converse com sua equipe de saúde.',
        ImpactLevel.semDados => '',
      };
}

class _NoImpactCard extends StatelessWidget {
  const _NoImpactCard({required this.impact});

  final MealImpact impact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(36),
        boxShadow: AppColors.softShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.query_stats, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            'Sem medições suficientes',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            impact.baselineMgdl == null
                ? 'Registre uma glicemia pouco antes da refeição e outra até 3h depois para calcularmos o impacto real.'
                : 'Falta uma medição de glicemia até 3h depois desta refeição para calcular o pico.',
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImpactBar extends StatelessWidget {
  const _ImpactBar({required this.height, required this.color});
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ),
    );
  }
}

class _FoodLine extends StatelessWidget {
  const _FoodLine({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.restaurant_menu, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: AppColors.secondary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
