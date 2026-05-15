import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../router/app_router.dart';
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

  static const double _contentHeight = 64;

  @override
  Size get preferredSize => const Size.fromHeight(_contentHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: _contentHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              if (leadingAvatar != null) leadingAvatar!,
              if (showBack && leadingAvatar == null)
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRoutes.dashboard);
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
        ),
      ),
    );
  }
}
