import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

class GlicareAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlicareAppBar({
    super.key,
    this.title,
    this.showBack = true,
    this.action,
    this.leadingAvatar,
  });

  final String? title;
  final bool showBack;
  final Widget? action;
  final Widget? leadingAvatar;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
      ),
      child: Row(
        children: [
          if (leadingAvatar != null) leadingAvatar!,
          if (showBack && leadingAvatar == null)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
          if (title != null) ...[
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                title!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -0.4,
                ),
              ),
            ),
          ] else
            const Spacer(),
          if (action != null) action!,
        ],
      ),
    );
  }
}
