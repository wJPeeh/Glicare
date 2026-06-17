import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../core/widgets/glicare_app_bar.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../care_notes/data/care_note.dart';
import '../../care_notes/presentation/care_notes_providers.dart';
import '../data/care_team.dart';
import 'care_team_providers.dart';

class SusIntegrationPage extends ConsumerWidget {
  const SusIntegrationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamAsync = ref.watch(careTeamProvider);

    return Scaffold(
      appBar: const GlicareAppBar(title: 'Minha Equipe'),
      bottomNavigationBar: GlicareBottomNav(
        activeIndex: 4,
        onTap: (i) => glicareRootNavTap(context, i),
      ),
      body: teamAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Não foi possível carregar: $e'),
          ),
        ),
        data: (team) {
          if (!team.isConfigured) {
            return _NotConnected(
              onConfigure: () => _openEditSheet(context, ref, team),
            );
          }
          return _ConnectedView(team: team);
        },
      ),
    );
  }

  static Future<void> _openEditSheet(
    BuildContext context,
    WidgetRef ref,
    CareTeam team,
  ) async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;
    final result = await showModalBottomSheet<CareTeam>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _CareTeamForm(initial: team),
    );
    if (result == null) return;
    try {
      await ref.read(careTeamRepositoryProvider).save(uid: uid, team: result);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Equipe de saúde atualizada.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao salvar: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

class _ConnectedView extends ConsumerWidget {
  const _ConnectedView({required this.team});

  final CareTeam team;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cartão da unidade de saúde.
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(36),
              boxShadow: AppColors.softShadow(),
            ),
            clipBehavior: Clip.hardEdge,
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  color: team.connected
                      ? AppColors.secondary
                      : AppColors.onSurfaceVariant,
                  child: Row(
                    children: [
                      Icon(
                        team.connected
                            ? Icons.check_circle
                            : Icons.info_outline,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        team.connected
                            ? 'CONECTADO AO SUS'
                            : 'VÍNCULO CADASTRADO',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const Spacer(),
                      if (team.updatedAt != null)
                        Text(
                          'ATUALIZADO ${_formatSync(team.updatedAt!)}',
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.85),
                            letterSpacing: 1.2,
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  team.ubsName ?? 'Unidade não informada',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.onSurface,
                                    letterSpacing: -0.6,
                                  ),
                                ),
                                if (team.ubsNetwork != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    team.ubsNetwork!,
                                    style: GoogleFonts.manrope(
                                      fontSize: 13,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.account_balance,
                                color: AppColors.secondary),
                          ),
                        ],
                      ),
                      if (team.susCard != null || team.bond != null) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _SusInfoBox(
                                label: 'CARTÃO SUS',
                                value: team.susCard ?? '—',
                                valueColor: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SusInfoBox(
                                label: 'VÍNCULO',
                                value: team.bond ?? '—',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Código de compartilhamento para o painel web do médico.
          _ShareCodeCard(
            code: team.accessCode,
            onGenerate: () => _generateCode(context, ref),
          ),
          const SizedBox(height: 24),

          // Conversa com a equipe (chat em tempo real).
          _ChatButton(onTap: () => context.push(AppRoutes.chat)),
          const SizedBox(height: 24),

          // Dicas e cuidados enviados pelo médico.
          _CareNotesSection(),
          const SizedBox(height: 8),

          // Compartilhamento de dados.
          Row(
            children: [
              Text(
                'Compartilhamento de dados',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              const Spacer(),
              Switch(
                value: team.shareEnabled,
                onChanged: (v) => _persist(
                  context,
                  ref,
                  team.copyWith(shareEnabled: v),
                ),
                activeTrackColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(36),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SUA EQUIPE PODE VER:',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 12),
                _PermissionToggle(
                  icon: Icons.bloodtype,
                  label: 'Histórico de Glicemia',
                  tint: AppColors.primary,
                  value: team.shareGlucose,
                  enabled: team.shareEnabled,
                  onChanged: (v) =>
                      _persist(context, ref, team.copyWith(shareGlucose: v)),
                ),
                const SizedBox(height: 8),
                _PermissionToggle(
                  icon: Icons.medication,
                  label: 'Uso de Medicamentos',
                  tint: AppColors.secondary,
                  value: team.shareMedication,
                  enabled: team.shareEnabled,
                  onChanged: (v) =>
                      _persist(context, ref, team.copyWith(shareMedication: v)),
                ),
                const SizedBox(height: 8),
                _PermissionToggle(
                  icon: Icons.restaurant_menu,
                  label: 'Registro Alimentar',
                  tint: AppColors.tertiary,
                  value: team.shareMeals,
                  enabled: team.shareEnabled,
                  onChanged: (v) =>
                      _persist(context, ref, team.copyWith(shareMeals: v)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Médico responsável.
          if (team.hasDoctor) ...[
            Text(
              'Médico Responsável',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _DoctorCard(team: team),
            const SizedBox(height: 24),
          ],

          // Editar dados.
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.2), width: 2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(99)),
              ),
              onPressed: () =>
                  SusIntegrationPage._openEditSheet(context, ref, team),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(
                'Editar equipe de saúde',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _persist(
    BuildContext context,
    WidgetRef ref,
    CareTeam updated,
  ) async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;
    try {
      await ref.read(careTeamRepositoryProvider).save(uid: uid, team: updated);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao salvar: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _generateCode(BuildContext context, WidgetRef ref) async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;
    try {
      await ref.read(careTeamRepositoryProvider).ensureAccessCode(uid);
      // O stream do careTeamProvider atualiza a UI com o novo código.
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao gerar código: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  static String _formatSync(DateTime when) {
    final now = DateTime.now();
    final diff = now.difference(when);
    if (diff.inMinutes < 1) return 'AGORA';
    if (diff.inMinutes < 60) return 'HÁ ${diff.inMinutes}MIN';
    if (diff.inHours < 24) return 'HÁ ${diff.inHours}H';
    return 'EM ${DateFormat('dd/MM').format(when)}';
  }
}

class _ShareCodeCard extends StatelessWidget {
  const _ShareCodeCard({required this.code, required this.onGenerate});

  final String? code;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.vpn_key, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'CÓDIGO DE ACESSO DO MÉDICO',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Informe este código ao seu médico para ele acompanhar seus dados pelo painel web.',
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          if (code == null)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99)),
                ),
                onPressed: onGenerate,
                icon: const Icon(Icons.add, size: 18),
                label: Text(
                  'Gerar código de acesso',
                  style:
                      GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      code!,
                      style: GoogleFonts.robotoMono(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  style:
                      IconButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: code!));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Código copiado.')),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 18),
                  tooltip: 'Copiar',
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ChatButton extends StatelessWidget {
  const _ChatButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.secondary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
        ),
        onPressed: onTap,
        icon: const Icon(Icons.chat_bubble_outline, size: 20),
        label: Text(
          'Conversar com a equipe',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _CareNotesSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(careNotesProvider);
    final notes = notesAsync.asData?.value ?? const <CareNote>[];
    if (notes.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Orientações da equipe',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        for (final note in notes) ...[
          _CareNoteCard(note: note),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 14),
      ],
    );
  }
}

class _CareNoteCard extends StatelessWidget {
  const _CareNoteCard({required this.note});
  final CareNote note;

  @override
  Widget build(BuildContext context) {
    final isCuidado = note.type == CareNoteType.cuidado;
    final accent = isCuidado ? AppColors.tertiary : AppColors.secondary;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCuidado ? Icons.health_and_safety : Icons.lightbulb,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      note.type.label.toUpperCase(),
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: accent,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('dd/MM').format(note.createdAt),
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  note.text,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: AppColors.onSurface,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '— ${note.authorName}',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.team});

  final CareTeam team;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(36),
        boxShadow: AppColors.softShadow(opacity: 0.04),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppColors.background, width: 4),
                      boxShadow: AppColors.softShadow(opacity: 0.1),
                    ),
                    child: const Icon(Icons.person,
                        color: AppColors.onSurfaceVariant, size: 36),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.verified,
                          color: Colors.white, size: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.doctorName!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                        letterSpacing: -0.4,
                      ),
                    ),
                    if (team.doctorSpecialty != null ||
                        team.doctorCrm != null)
                      Text(
                        [
                          if (team.doctorSpecialty != null)
                            team.doctorSpecialty,
                          if (team.doctorCrm != null) 'CRM ${team.doctorCrm}',
                        ].join(' • '),
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    if (team.doctorLocation != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 14, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              team.doctorLocation!,
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotConnected extends StatelessWidget {
  const _NotConnected({required this.onConfigure});

  final VoidCallback onConfigure;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_balance,
                  size: 40, color: AppColors.secondary),
            ),
            const SizedBox(height: 20),
            Text(
              'Conecte-se à sua equipe de saúde',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cadastre sua unidade (UBS) e seu médico para compartilhar seu acompanhamento com a equipe.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99)),
                ),
                onPressed: onConfigure,
                icon: const Icon(Icons.add, size: 18),
                label: Text(
                  'Configurar agora',
                  style:
                      GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SusInfoBox extends StatelessWidget {
  const _SusInfoBox({required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: valueColor ?? AppColors.onSurface,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionToggle extends StatelessWidget {
  const _PermissionToggle({
    required this.icon,
    required this.label,
    required this.tint,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final Color tint;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: tint, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: enabled ? onChanged : null,
              activeTrackColor: AppColors.secondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Formulário de cadastro/edição da equipe de saúde.
class _CareTeamForm extends StatefulWidget {
  const _CareTeamForm({required this.initial});

  final CareTeam initial;

  @override
  State<_CareTeamForm> createState() => _CareTeamFormState();
}

class _CareTeamFormState extends State<_CareTeamForm> {
  late final TextEditingController _ubsName;
  late final TextEditingController _ubsNetwork;
  late final TextEditingController _susCard;
  late final TextEditingController _bond;
  late final TextEditingController _doctorName;
  late final TextEditingController _doctorSpecialty;
  late final TextEditingController _doctorCrm;
  late final TextEditingController _doctorLocation;
  late bool _connected;

  @override
  void initState() {
    super.initState();
    final t = widget.initial;
    _ubsName = TextEditingController(text: t.ubsName ?? '');
    _ubsNetwork = TextEditingController(text: t.ubsNetwork ?? '');
    _susCard = TextEditingController(text: t.susCard ?? '');
    _bond = TextEditingController(text: t.bond ?? '');
    _doctorName = TextEditingController(text: t.doctorName ?? '');
    _doctorSpecialty = TextEditingController(text: t.doctorSpecialty ?? '');
    _doctorCrm = TextEditingController(text: t.doctorCrm ?? '');
    _doctorLocation = TextEditingController(text: t.doctorLocation ?? '');
    _connected = t.connected;
  }

  @override
  void dispose() {
    _ubsName.dispose();
    _ubsNetwork.dispose();
    _susCard.dispose();
    _bond.dispose();
    _doctorName.dispose();
    _doctorSpecialty.dispose();
    _doctorCrm.dispose();
    _doctorLocation.dispose();
    super.dispose();
  }

  void _save() {
    final result = widget.initial.copyWith(
      connected: _connected,
      ubsName: _ubsName.text,
      ubsNetwork: _ubsNetwork.text,
      susCard: _susCard.text,
      bond: _bond.text,
      doctorName: _doctorName.text,
      doctorSpecialty: _doctorSpecialty.text,
      doctorCrm: _doctorCrm.text,
      doctorLocation: _doctorLocation.text,
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Equipe de saúde',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _connected,
                  onChanged: (v) => setState(() => _connected = v),
                  activeTrackColor: AppColors.secondary,
                  title: Text(
                    'Vínculo ativo com o SUS',
                    style:
                        GoogleFonts.manrope(fontWeight: FontWeight.w700),
                  ),
                ),
                const _FormLabel('Unidade de saúde (UBS)'),
                _Field(controller: _ubsName, hint: 'Ex.: UBS Santa Cecília'),
                _Field(
                    controller: _ubsNetwork,
                    hint: 'Rede / cidade (ex.: Rede Municipal • SP)'),
                _Field(controller: _susCard, hint: 'Cartão SUS'),
                _Field(controller: _bond, hint: 'Vínculo (ex.: Ativo)'),
                const SizedBox(height: 16),
                const _FormLabel('Médico responsável'),
                _Field(controller: _doctorName, hint: 'Nome do médico'),
                _Field(
                    controller: _doctorSpecialty,
                    hint: 'Especialidade (ex.: Endocrinologista)'),
                _Field(controller: _doctorCrm, hint: 'CRM'),
                _Field(
                    controller: _doctorLocation,
                    hint: 'Local de atendimento'),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(99)),
                    ),
                    onPressed: _save,
                    child: Text(
                      'Salvar',
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  const _FormLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.onSurfaceVariant,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.controller, required this.hint});
  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: AppColors.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
