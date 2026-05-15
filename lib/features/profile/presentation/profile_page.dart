import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glicare_app_bar.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/auth_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GlicareAppBar(title: 'Perfil'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProfileHeader(user: user),
            const SizedBox(height: 24),
            _SectionLabel('Contato'),
            const SizedBox(height: 12),
            _ContactCard(user: user),
            const SizedBox(height: 24),
            _SectionLabel('Conta'),
            const SizedBox(height: 12),
            _AccountCard(user: user),
            const SizedBox(height: 32),
            const _LogoutButton(),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    final displayName = (user.displayName?.trim().isNotEmpty ?? false)
        ? user.displayName!.trim()
        : (user.email?.split('@').first ?? 'Usuária');
    final photoUrl = user.photoURL;

    return Column(
      children: [
        Container(
          width: 112,
          height: 112,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(4),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerLow,
              border: Border.all(color: Colors.white, width: 3),
              image: photoUrl != null
                  ? DecorationImage(
                      image: NetworkImage(photoUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: photoUrl == null
                ? const Icon(
                    Icons.person,
                    color: AppColors.onSurfaceVariant,
                    size: 56,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          displayName,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        if (user.email != null) ...[
          const SizedBox(height: 4),
          Text(
            user.email!,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.onSurfaceVariant,
          letterSpacing: 1.8,
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    final phone = user.phoneNumber;
    return _Card(
      children: [
        _InfoRow(
          icon: Icons.mail_outline,
          label: 'E-mail',
          value: user.email ?? 'Não informado',
          trailing: user.email == null
              ? null
              : _VerifiedBadge(verified: user.emailVerified),
        ),
        const _Divider(),
        _InfoRow(
          icon: Icons.phone_outlined,
          label: 'Telefone',
          value: (phone != null && phone.isNotEmpty) ? phone : 'Não informado',
          muted: phone == null || phone.isEmpty,
        ),
      ],
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    final providers = user.providerData
        .map((p) => _providerLabel(p.providerId))
        .where((label) => label != null)
        .cast<String>()
        .toSet()
        .join(', ');
    final createdAt = user.metadata.creationTime;
    final lastSignIn = user.metadata.lastSignInTime;

    return _Card(
      children: [
        _InfoRow(
          icon: Icons.login,
          label: 'Provedor de login',
          value: providers.isEmpty ? 'Desconhecido' : providers,
        ),
        const _Divider(),
        _InfoRow(
          icon: Icons.event_outlined,
          label: 'Membro desde',
          value: createdAt != null ? _fmtDate(createdAt) : '—',
        ),
        const _Divider(),
        _InfoRow(
          icon: Icons.schedule,
          label: 'Último acesso',
          value: lastSignIn != null ? _fmtDateTime(lastSignIn) : '—',
        ),
        const _Divider(),
        _InfoRow(
          icon: Icons.fingerprint,
          label: 'ID',
          value: user.uid,
          monospace: true,
        ),
      ],
    );
  }

  static String? _providerLabel(String providerId) {
    switch (providerId) {
      case 'password':
        return 'E-mail e senha';
      case 'google.com':
        return 'Google';
      case 'facebook.com':
        return 'Facebook';
      case 'phone':
        return 'Telefone';
      case 'firebase':
        return null;
      default:
        return providerId;
    }
  }

  static String _fmtDate(DateTime dt) =>
      DateFormat('dd/MM/yyyy').format(dt.toLocal());
  static String _fmtDateTime(DateTime dt) =>
      DateFormat('dd/MM/yyyy HH:mm').format(dt.toLocal());
}

class _Card extends StatelessWidget {
  const _Card({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.softShadow(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: AppColors.outlineVariant.withValues(alpha: 0.2),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
    this.muted = false,
    this.monospace = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;
  final bool muted;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: monospace
                      ? GoogleFonts.robotoMono(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        )
                      : GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: muted
                              ? AppColors.onSurfaceVariant
                              : AppColors.onSurface,
                          fontStyle:
                              muted ? FontStyle.italic : FontStyle.normal,
                        ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge({required this.verified});
  final bool verified;

  @override
  Widget build(BuildContext context) {
    final color = verified ? AppColors.secondary : AppColors.tertiary;
    final icon = verified ? Icons.verified : Icons.error_outline;
    final label = verified ? 'Verificado' : 'Não verificado';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoutButton extends ConsumerWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () =>
            ref.read(authControllerProvider.notifier).signOut(),
        icon: const Icon(Icons.logout, size: 20),
        label: Text(
          'Sair da conta',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
