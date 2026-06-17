import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glicare_app_bar.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/profile_photo_service.dart';
import '../data/user_profile.dart';
import 'profile_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(userProfileProvider);
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final profile = profileAsync.asData?.value ?? const UserProfile();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GlicareAppBar(title: 'Perfil'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProfileHeader(user: user, profile: profile),
            const SizedBox(height: 24),
            _SectionLabel('Contato'),
            const SizedBox(height: 12),
            _ContactCard(user: user, profile: profile),
            const SizedBox(height: 24),
            _SectionLabel('Saúde'),
            const SizedBox(height: 12),
            _NavTile(
              icon: Icons.account_balance,
              iconColor: AppColors.secondary,
              title: 'Minha Equipe (SUS)',
              subtitle: 'Unidade, médico e compartilhamento de dados',
              onTap: () => context.push(AppRoutes.susIntegration),
            ),
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

class _ProfileHeader extends ConsumerStatefulWidget {
  const _ProfileHeader({required this.user, required this.profile});
  final User user;
  final UserProfile profile;

  @override
  ConsumerState<_ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends ConsumerState<_ProfileHeader> {
  bool _uploading = false;

  String get _displayName {
    final dn = widget.user.displayName?.trim();
    if (dn != null && dn.isNotEmpty) return dn;
    return widget.user.email?.split('@').first ?? 'Usuária';
  }

  String? get _effectivePhotoUrl {
    if (widget.profile.hasCustomPhoto) return widget.profile.customPhotoUrl;
    return widget.user.photoURL;
  }

  Future<void> _changePhoto() async {
    final source = await showModalBottomSheet<PhotoSource>(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SheetTile(
                icon: Icons.photo_camera,
                label: 'Tirar foto',
                onTap: () => Navigator.of(ctx).pop(PhotoSource.camera),
              ),
              const SizedBox(height: 8),
              _SheetTile(
                icon: Icons.photo_library,
                label: 'Escolher da galeria',
                onTap: () => Navigator.of(ctx).pop(PhotoSource.gallery),
              ),
              if (widget.profile.hasCustomPhoto) ...[
                const SizedBox(height: 8),
                _SheetTile(
                  icon: Icons.delete_outline,
                  label: 'Remover foto',
                  destructive: true,
                  onTap: () => Navigator.of(ctx).pop(null),
                ),
              ],
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;
    if (source == null && !widget.profile.hasCustomPhoto) return;

    setState(() => _uploading = true);
    try {
      if (source == null) {
        await ref
            .read(profilePhotoServiceProvider)
            .deletePhoto(widget.user.uid);
        await ref.read(userProfileRepositoryProvider).setCustomPhotoUrl(
              uid: widget.user.uid,
              url: null,
            );
      } else {
        final url = await ref
            .read(profilePhotoServiceProvider)
            .pickAndUpload(uid: widget.user.uid, source: source);
        if (url != null) {
          await ref.read(userProfileRepositoryProvider).setCustomPhotoUrl(
                uid: widget.user.uid,
                url: url,
              );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao atualizar foto: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = _effectivePhotoUrl;
    return Column(
      children: [
        GestureDetector(
          onTap: _uploading ? null : _changePhoto,
          child: Stack(
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
                      ? Center(
                          child: Text(
                            _initials(_displayName),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: _uploading
                      ? const Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.camera_alt,
                          color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _displayName,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        if (widget.user.email != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.user.email!,
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

String _initials(String name) {
  final parts =
      name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
}

class _SheetTile extends StatelessWidget {
  const _SheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.error : AppColors.primary;
    return Material(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  color: destructive ? AppColors.error : AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppColors.softShadow(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 14, color: AppColors.outline),
            ],
          ),
        ),
      ),
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

class _ContactCard extends ConsumerWidget {
  const _ContactCard({required this.user, required this.profile});
  final User user;
  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phone = profile.phone ?? user.phoneNumber;
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
          trailing: IconButton(
            tooltip: phone == null || phone.isEmpty
                ? 'Adicionar telefone'
                : 'Editar telefone',
            icon: const Icon(Icons.edit, color: AppColors.primary, size: 18),
            onPressed: () => _editPhone(context, ref),
          ),
        ),
      ],
    );
  }

  Future<void> _editPhone(BuildContext context, WidgetRef ref) async {
    final newPhone = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => _PhoneEditor(initial: profile.phone),
    );
    if (newPhone == null) return;
    try {
      await ref.read(userProfileRepositoryProvider).setPhone(
            uid: user.uid,
            phone: newPhone.isEmpty ? null : newPhone,
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newPhone.isEmpty ? 'Telefone removido.' : 'Telefone atualizado.',
          ),
          backgroundColor: AppColors.secondary,
        ),
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

class _PhoneEditor extends StatefulWidget {
  const _PhoneEditor({this.initial});
  final String? initial;

  @override
  State<_PhoneEditor> createState() => _PhoneEditorState();
}

class _PhoneEditorState extends State<_PhoneEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          const SizedBox(height: 16),
          Text(
            widget.initial == null || widget.initial!.isEmpty
                ? 'Adicionar telefone'
                : 'Editar telefone',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
              _BrazilPhoneFormatter(),
            ],
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surfaceContainerLow,
              hintText: '(11) 91234-5678',
              hintStyle: GoogleFonts.manrope(color: AppColors.outline),
              prefixIcon:
                  const Icon(Icons.phone_outlined, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (widget.initial != null && widget.initial!.isNotEmpty) ...[
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(
                        color: AppColors.error.withValues(alpha: 0.4),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(''),
                    child: Text(
                      'Remover',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () =>
                      Navigator.of(context).pop(_controller.text.trim()),
                  child: Text(
                    'Salvar',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BrazilPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length && i < 11; i++) {
      if (i == 0) buffer.write('(');
      if (i == 2) buffer.write(') ');
      if (digits.length <= 10 ? i == 6 : i == 7) buffer.write('-');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
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
