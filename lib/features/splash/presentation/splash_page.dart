import 'package:flutter/material.dart';

import '../../../core/widgets/glicare_loading.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: GlicareLoading.fullscreen(
        size: 96,
        message: 'Glicare',
      ),
    );
  }
}
